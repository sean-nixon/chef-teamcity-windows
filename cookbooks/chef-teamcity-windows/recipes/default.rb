#
# Cookbook:: chef-teamcity-windows
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Shorten hashes
teamcity = node[:teamcity_windows]
$debug = teamcity[:debug]

# Set logging level to debug
Chef::Log.level = :debug if $debug

include_recipe 'chef-teamcity-windows::install'
include_recipe 'chef-teamcity-windows::configure'


