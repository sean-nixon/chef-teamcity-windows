#
# Cookbook:: chef-teamcity-windows
# Recipe:: install
#
# Copyright:: 2017, The Authors, All Rights Reserved.



# Shorten hashes
teamcity = node[:teamcity_windows]
$debug = teamcity[:debug]

TEAMCITY_VERSION = teamcity[:version]

TEAMCITY_SERVER_PATH = teamcity['server']['basedir']
TEAMCITY_SERVER_TAR = "TeamCity-#{TEAMCITY_VERSION}.tar".freeze
TEAMCITY_SERVER_SOURCE_PATH = ::File.join(TEAMCITY_SERVER_PATH, TEAMCITY_SERVER_TAR).freeze
TEAMCITY_SERVER_BIN_PATH = ::File.join(TEAMCITY_SERVER_PATH, 'bin').freeze


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


# Set logging level to debug
Chef::Log.level = :debug

log "<=== Running 7-zip recipe ===>" if $debug
include_recipe 'seven_zip::default'

log "<== Downloading and extracting teamcity gz archive: path = #{TEAMCITY_SERVER_TMP} ==>" if $debug
seven_zip_archive 'teamcity_tar_gz' do
  path      TEAMCITY_SERVER_PATH # C:\teamcity
  source    "http://download.jetbrains.com/teamcity/TeamCity-#{TEAMCITY_VERSION}.tar.gz"
  overwrite true
  timeout   120
end

if (! ::File.exist?(TEAMCITY_SERVER_BIN_PATH))
    log "<== Downloading and extracting teamcity tar archive: path = #{TEAMCITY_SERVER_BASE_DIR}, source = #{TEAMCITY_SERVER_TMP}  ==>" if $debug
    seven_zip_archive 'teamcity_tar' do
      path      TEAMCITY_SERVER_PATH # C:\teamcity
      source    TEAMCITY_SERVER_SOURCE_PATH # Default is C:\teamcity\TeamCity-#{TEAMCITY_VERSION}.tar
      timeout   30
    end
end


