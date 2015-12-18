require "fcl_rails_daemon/version"
require "fcl_rails_daemon/config"
require 'fileutils'
require 'yaml'
require 'daemons'
require 'active_support'


module FclRailsDaemon end

require_relative "core/daemon"
comandos_dir = File.join(DAEMON_ROOT, DAEMON_CONFIG['command_path'])
if File.directory?(comandos_dir)
  Dir["#{comandos_dir}/*.rb"].each {|file| require file }
end
require_relative "core/registrador.rb"
require_relative "core/gerenciador.rb"

require File.join(DAEMON_ROOT, "config", "fcld_rails_daemon.rb")
