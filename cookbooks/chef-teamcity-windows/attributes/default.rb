# Cookbook Name:: chef-teamcity-windows
# Recipe:: default

node.default['teamcity_windows']['debug'] = true
node.default['teamcity_windows']['url'] = 'https://download.jetbrains.com/teamcity/TeamCity-10.0.5.tar.gz'
node.default['teamcity_windows']['version'] = '10.0.5'
node.default['teamcity_windows']['server']['basedir'] = "C:/teamcity"

node.default['java']['jdk_version'] = '8'
node.default['java']['jdk_minor_version'] = '121'
node.force_default['java']['java_home'] = "C:/Program Files (x86)/Java/jdk1.#{node.default[:java][:jdk_version]}.0_#{node.default[:java][:jdk_minor_version]}"
node.default['java']['oracle']['accept_oracle_download_terms'] = true
node.default['java']['windows']['url'] = 'http://download.oracle.com/otn-pub/java/jdk/8u121-b13/e9e7ea248e2c4826b92b3f075a80e441/jdk-8u121-windows-i586.exe'
node.default['java']['windows']['remove_obsolete'] = true
node.default['java']['windows']['package_name'] = "Java(TM) SE Development Kit #{node.default[:java][:jdk_version]} (32-bit)"

