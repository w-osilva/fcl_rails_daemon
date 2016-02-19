require "fcl_rails_daemon/setup"
require 'yaml'
require 'daemons'

module FclRailsDaemon end

require "fcl_rails_daemon/core/daemon"
require "fcl_rails_daemon/core/recorder.rb"
require "fcl_rails_daemon/core/manager.rb"

# Load commands files
command_dir = File.join(DAEMON_ROOT, DAEMON_CONFIG['command_path'])
raise " ༼ つ ◕_◕ ༽つ OOOPS... Could not find the command directory. Run 'fcld --configure'   " unless File.directory? command_dir

Dir[File.join(command_dir, "**/*.rb")].each {|file| load file }

load File.join(DAEMON_ROOT, "config", "fcl_rails_daemon.rb")
