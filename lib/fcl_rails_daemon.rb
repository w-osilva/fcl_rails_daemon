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
require File.join(DAEMON_ROOT, "config", "fcl_rails_daemon", "config.rb")
