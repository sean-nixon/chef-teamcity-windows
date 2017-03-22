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

TEAMCITY_VERSION = teamcity[:version]

TEAMCITY_SERVER_INSTALL_DIR = teamcity['server']['install_dir']
TEAMCITY_SERVER_PATH = ::File.join(TEAMCITY_SERVER_INSTALL_DIR, 'TeamCity')
TEAMCITY_SERVER_TAR = "TeamCity-#{TEAMCITY_VERSION}.tar"
TEAMCITY_SERVER_SOURCE_PATH = ::File.join(TEAMCITY_SERVER_INSTALL_DIR, TEAMCITY_SERVER_TAR)
TEAMCITY_SERVER_BIN_PATH = ::File.join(TEAMCITY_SERVER_PATH, 'bin')
TEAMCITY_SERVER_DATA_PATH = teamcity['server']['data_dir']
TEAMCITY_SERVER_SERVICE_NAME = 'TeamCity'
TEAMCITY_AGENT_BIN_PATH = ::File.join(TEAMCITY_SERVER_PATH, 'buildAgent/bin')
TEAMCITY_AGENT_SERVICE_NAME = 'TCBuildAgent'
TEAMCITY_SERVER_PORT = teamcity['server']['port']
TEAMCITY_AGENT_PORT = teamcity['server']['port']

instance = search("aws_opsworks_instance", "self:true").first

log "<=== Public DNS Address is  #{instance['public_dns']} ===>" if $debug
PUBLIC_DNS = "#{instance['public_dns']}"

# TEAMCITY_DB_USERNAME = teamcity['server']['database']['username'].freeze
# TEAMCITY_DB_PASSWORD = teamcity['server']['database']['password'].freeze
# TEAMCITY_DB_CONNECTION_URL = teamcity['server']['database']['connection_url'].freeze
# TEAMCITY_SERVER_EXECUTABLE = "#{TEAMCITY_PATH}/bin/teamcity-server.sh".freeze
# TEAMCITY_BIN_PATH = "#{TEAMCITY_PATH}/bin".freeze
# TEAMCITY_DATA_PATH = "#{TEAMCITY_PATH}/.BuildServer".freeze
# TEAMCITY_LIB_PATH = "#{TEAMCITY_DATA_PATH}/lib".freeze
# TEAMCITY_JDBC_PATH = "#{TEAMCITY_LIB_PATH}/jdbc".freeze
# TEAMCITY_CONFIG_PATH = "#{TEAMCITY_DATA_PATH}/config".freeze
# TEAMCITY_BACKUP_PATH = "#{TEAMCITY_DATA_PATH}/backup".freeze
# TEAMCITY_DATABASE_PROPS_NAME = 'database.properties'.freeze
# TEAMCITY_DATABASE_PROPS_PATH = "#{TEAMCITY_CONFIG_PATH}/#{TEAMCITY_DATABASE_PROPS_NAME}".freeze
# TEAMCITY_JAR_URI = teamcity['server']['database']['jar'].freeze
# TEAMCITY_BACKUP_FILE = teamcity['server']['backup']
# TEAMCITY_JAR_NAME = ::File.basename(URI.parse(TEAMCITY_JAR_URI).path).freeze




log "<=== Running 7-zip recipe ===>" if $debug
include_recipe 'seven_zip::default'

log "<== Downloading and extracting teamcity gz archive: path = #{TEAMCITY_SERVER_INSTALL_DIR} ==>" if $debug
seven_zip_archive 'teamcity_tar_gz' do
  path      TEAMCITY_SERVER_INSTALL_DIR # C:\
  source    "http://download.jetbrains.com/teamcity/TeamCity-#{TEAMCITY_VERSION}.tar.gz"
  overwrite true
  timeout   120
end

if (! ::File.exist?(TEAMCITY_SERVER_BIN_PATH))
    log "<== Downloading and extracting teamcity tar archive: path = #{TEAMCITY_SERVER_INSTALL_DIR}, source = #{TEAMCITY_SERVER_SOURCE_PATH}  ==>" if $debug
    seven_zip_archive 'teamcity_tar' do
      path      TEAMCITY_SERVER_INSTALL_DIR # C:\
      source    TEAMCITY_SERVER_SOURCE_PATH # Default is C:\TeamCity-#{TEAMCITY_VERSION}.tar
      timeout   30
    end
end

log "<=== Installing team server service named #{TEAMCITY_SERVER_SERVICE_NAME} with command #{TEAMCITY_SERVER_BIN_PATH}/teamcity-server.bat service install /runAsSystem ===>" if $debug
execute 'install teamcity server service' do
  command "#{TEAMCITY_SERVER_BIN_PATH}/teamcity-server.bat service install /runAsSystem"
  action :run
  cwd "#{TEAMCITY_SERVER_BIN_PATH}"
  not_if { ::Win32::Service.exists?("#{TEAMCITY_SERVER_SERVICE_NAME}") }
end

log "<=== Installing team server service named #{TEAMCITY_AGENT_SERVICE_NAME} with command #{TEAMCITY_AGENT_BIN_PATH}/service.install.bat ===>" if $debug
execute 'install teamcity service' do
  command "#{TEAMCITY_AGENT_BIN_PATH}/service.install.bat"
  action :run
  cwd "#{TEAMCITY_AGENT_BIN_PATH}"
  not_if { ::Win32::Service.exists?("#{TEAMCITY_AGENT_SERVICE_NAME}") }
end

log "<=== Enabling #{TEAMCITY_SERVER_SERVICE_NAME} service ===>" if $debug
service TEAMCITY_SERVER_SERVICE_NAME do
  supports start: true, stop: true, restart: true, status: true
  action [:enable, :start]
end

log "<=== Enabling #{TEAMCITY_AGENT_SERVICE_NAME} service ===>" if $debug
service TEAMCITY_AGENT_SERVICE_NAME do
  supports start: true, stop: true, restart: true, status: true
  action [:enable, :start]
end

windows_firewall_rule 'TeamCity Server' do
  localport TEAMCITY_SERVER_PORT
  protocol 'TCP'
  firewall_action :allow
end

windows_firewall_rule 'TeamCity Agent' do
  localport TEAMCITY_AGENT_PORT
  protocol 'TCP'
  firewall_action :allow
end

# template "#{DATA_DIR_CONFIG_PATH}" do
#     source "teamcity-startup.properties.erb"
#     variables({
#         data_dir: 
#     })
# end
