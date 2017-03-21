#
# Cookbook:: chef-teamcity-windows
# Recipe:: install
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Shorten hashes
teamcity = node[:teamcity_windows]
$debug = teamcity[:debug]

# Set logging level to debug
Chef::Log.level = :debug

# Install Java 8 JDK
log "<=== Running Java recipe to install JDK ====>" if $debug
include_recipe 'java::default'

log "<=== Running 7-zip recipe ===>" if $debug
include_recipe 'seven_zip::default'

log "<== Downloading and extracting teamcity archive ==>" if $debug
seven_zip_archive 'teamcity_source' do
  path      'C:\TeamCity'
  source    "#{teamcity[:url]}"
  overwrite true
  timeout   120
end


