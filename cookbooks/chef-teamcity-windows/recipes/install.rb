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
# log "<=== Running 7-zip recipe ===>" if $debug
# include_recipe 'seven_zip::default'

# seven_zip_archive 'seven_zip_source' do
#   path      'C:\TeamCity'
#   source    "#{teamcity[:url]}"
#   overwrite true
#   checksum  '3713aed72728eae8f6649e4803eba0b3676785200c76df6269034c520df4bbd5'
#   timeout   30
# end


