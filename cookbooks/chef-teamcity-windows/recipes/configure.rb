#
# Cookbook:: chef-teamcity-windows
# Recipe:: configure
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Shorten hashes
teamcity = node[:teamcity_windows]
$debug = teamcity[:debug]

# Set logging level to debug
Chef::Log.level = :debug if $debug

