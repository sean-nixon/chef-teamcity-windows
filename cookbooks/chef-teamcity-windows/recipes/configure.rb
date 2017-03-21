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

# ::Chef:Recipe.send(:include, Windows::Helper)

# start_server_script = win_friendly_path("#{start_script_path}")

# execute "Server Start Script" do
#    command start_server_script 
# end