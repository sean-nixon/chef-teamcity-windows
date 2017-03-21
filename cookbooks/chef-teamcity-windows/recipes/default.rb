#
# Cookbook:: chef-teamcity-windows
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.

# Shorten hashes
log "<== Setting up teamcity variable to #{node[:teamcity_windows]}===>"
teamcity = node[:teamcity_windows]
log "<== Setting debug level to #{teamcity[:debug]} ==>"
$debug = teamcity[:debug]

# Install Java 8 JDK
log "<=== Running Java recipe to install JDK ====>" if $debug
include_recipe 'java::default'

# Set logging level to debug
Chef::Log.level = :debug if $debug

log "<== Running install recipe ==>" if $debug
include_recipe 'chef-teamcity-windows::install'
log "<== Running configure recipe ==>" if $debug
include_recipe 'chef-teamcity-windows::configure'


