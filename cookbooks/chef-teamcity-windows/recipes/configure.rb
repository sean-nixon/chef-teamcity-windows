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
::Chef::Recipe.send(:include, Windows::Helper)

TEAMCITY_SERVER_INSTALL_DIR = teamcity['server']['install_dir'].freeze
TEAMCITY_SERVER_PATH = ::File.join(TEAMCITY_SERVER_INSTALL_DIR, 'teamcity').freeze
TEAMCITY_SERVER_BIN_PATH = ::File.join(TEAMCITY_SERVER_PATH, 'bin').freeze
TEAMCITY_SERVER_START_SCRIPT = ::File.join(TEAMCITY_SERVER_BIN_PATH, 'runAll.bat').freeze
WINDOWS_TEAMCITY_SERVER_START_SCRIPT = win_friendly_path("#{TEAMCITY_SERVER_START_SCRIPT}")
TEAMCITY_SERVER_START_COMMAND = "#{WINDOWS_TEAMCITY_SERVER_START_SCRIPT} start"



# log "<=== Executing command #{TEAMCITY_SERVER_START_COMMAND} ===>" if $debug
# execute "Server Start Script" do    
#     command TEAMCITY_SERVER_START_COMMAND
#     cwd TEAMCITY_SERVER_BIN_PATH
# end