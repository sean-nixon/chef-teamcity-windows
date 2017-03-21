#
# Author:: Kendrick Martin (<kendrick.martin@webtrends.com>)
# Cookbook Name:: java
# Recipe:: windows
#
# Copyright 2008-2012 Webtrends, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'uri'
log "<== Including recipe java::notify ==>"
include_recipe 'java::notify'

Chef::Log.fatal('No download url set for java installer.') unless node['java'] && node['java']['windows'] && node['java']['windows']['url']

pkg_checksum = node['java']['windows']['checksum']
aws_access_key_id = node['java']['windows']['aws_access_key_id']
aws_secret_access_key = node['java']['windows']['aws_secret_access_key']
aws_session_token = node['java']['windows']['aws_session_token']

s3_bucket = node['java']['windows']['bucket']
s3_remote_path = node['java']['windows']['remote_path']

log "<== Setting URI of cache file path ==>"
uri = ::URI.parse(node['java']['windows']['url'])
cache_file_path = File.join(Chef::Config[:file_cache_path], File.basename(::URI.unescape(uri.path)))

log "<== Testing if an S3 bucket is specified ==>"
if s3_bucket && s3_remote_path
  log "<== Attempting install using AWS S3 ==>"
  include_recipe 'aws::default' # install right_aws gem for aws_s3_file

  aws_s3_file cache_file_path do
    aws_access_key_id aws_access_key_id
    aws_secret_access_key aws_secret_access_key
    aws_session_token aws_session_token
    checksum pkg_checksum if pkg_checksum
    bucket s3_bucket
    remote_path s3_remote_path
    backup false
    action :create
  end
else
  ruby_block 'Enable Accessing cookies' do
    block do
      log "<== Setting access cookies for Oracle download ==>"
      # Chef::REST became Chef::HTTP in chef 11
      cookie_jar = Chef::REST::CookieJar if defined?(Chef::REST::CookieJar)
      cookie_jar = Chef::HTTP::CookieJar if defined?(Chef::HTTP::CookieJar)

      cookie_jar.instance["#{uri.host}:#{uri.port}"] = 'oraclelicense=accept-securebackup-cookie'
    end

    only_if { node['java']['oracle']['accept_oracle_download_terms'] }
  end

  log "<== Downloading installation file ==>"
  remote_file cache_file_path do
    checksum pkg_checksum if pkg_checksum
    source node['java']['windows']['url']
    backup false
    action :create
  end
end

log "<== Setting Java Home ==>"
if node['java'].attribute?('java_home')
  java_home_win = win_friendly_path(node['java']['java_home'])
  additional_options = if node['java']['jdk_version'] == '8'
                         # Seems that the jdk 8 EXE installer does not need anymore the /v /qn flags
                         "INSTALLDIR=\"#{java_home_win}\""
                       else
                         # The jdk 7 EXE installer expects escaped quotes, so we need to double escape
                         # them here. The final string looks like :
                         # /v"/qn INSTALLDIR=\"C:\Program Files\Java\""
                         "/v\"/qn INSTALLDIR=\\\"#{java_home_win}\\\"\""
                       end

  log "<== Java home is #{java_home_win} ==>"
  env 'JAVA_HOME' do
    value java_home_win
  end
log "<== Updating windows path for JDK bin ==>"
  # update path
  windows_path "#{java_home_win}\\bin" do
    action :add
  end
end

log "<== Setting additional options for the java install ==>"
if node['java']['windows'].attribute?('public_jre_home') && node['java']['windows']['public_jre_home']
  java_publicjre_home_win = win_friendly_path(node['java']['windows']['public_jre_home'])
  additional_options = "#{additional_options} /INSTALLDIRPUBJRE=\"#{java_publicjre_home_win}\""
end

log "<== Setting remove obsolete attribute for java install ==>"
if node['java']['windows'].attribute?('remove_obsolete') && node['java']['windows']['remove_obsolete']
  additional_options = "#{additional_options} REMOVEOUTOFDATEJRES=1"
end

log "<== Installing Java on Windows machine ==>"

windows_package node['java']['windows']['package_name'] do
  source cache_file_path
  checksum node['java']['windows']['checksum']
  action :install
  installer_type :custom
  options "/s #{additional_options}"
  notifies :write, 'log[jdk-version-changed]', :immediately
end

include_recipe 'java::oracle_jce' if node['java']['oracle']['jce']['enabled']
