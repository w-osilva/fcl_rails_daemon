require "rails"
require "fcl_rails_daemon/version"
require "fcl_rails_daemon/config"
require 'fileutils'
require 'yaml'
require 'daemons'
require 'active_support'

module FclRailsDaemon end
require_relative "core/daemon"
require_relative "core/recorder.rb"
require_relative "core/manager.rb"

# Load commands files
command_dir = File.join(DAEMON_ROOT, DAEMON_CONFIG['command_path'])
raise " ༼ つ ◕_◕ ༽つ OOOPS... Could not find the command directory. Run 'fcld --configure'   " unless File.directory? command_dir

Dir[File.join(command_dir, "**/*.rb")].each {|file| load file }

load File.join(DAEMON_ROOT, "config", "fcl_rails_daemon.rb")

