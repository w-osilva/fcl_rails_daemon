require 'fileutils'
require 'active_support'
require 'fcl_rails_daemon/config'
require 'fcl_rails_daemon/core/command_generator'

module FclRailsDaemon
  class Setup

    attr_reader :base, :config_dir, :config_file, :commands_dir, :command_sample_file, :logs_dir, :pids_dir, :pids_file

    def initialize
      @base = DAEMON_ROOT
      @config_dir = File.join(@base, DAEMON_CONFIG['config_path'])
      @config_file = File.join(@config_dir, 'fcl_rails_daemon.rb')

      @commands_dir = File.join(@base, DAEMON_CONFIG['command_path'])
      @command_sample_file = File.join(@commands_dir, 'command_sample.rb')

      @logs_dir = File.join(@base, "log")

      @pids_dir = File.join(@base, "tmp/pids")
      @pids_file = File.join(@base, DAEMON_CONFIG['pids_file'])
    end

    def configure
      create_config
      create_command_sample
      create_pids
      create_logs
    end

    def create_config
      content = <<-FILE
# To register commands use the FclRailsDaemon::Recorder class
#  :command is the command name
#  :class_reference is the class to which it is
#
# FclRailsDaemon::Recorder.add(command: 'command_sample', class_reference: CommandSample)

      FILE
      FileUtils.mkdir_p(@config_dir) unless File.directory?(@config_dir)
      File.open(@config_file, 'wb') {|f| f.write(content) } unless File.exist?(@config_file)
    end

    def create_command_sample
      content = FclRailsDaemon::CommandGenerator.get_content("command_sample")
      FileUtils.mkdir_p(@commands_dir) unless File.directory?(@commands_dir)
      File.open(@command_sample_file, 'wb') {|f| f.write(content) } unless File.exists?(@command_sample_file)
    end

    def create_pids
      FileUtils.mkdir_p(@pids_dir) unless File.directory?(@pids_dir)
      File.open(@pids_file, 'wb') {|f| f << "fcl_rails_daemon:" } unless File.exist?(@pids_file)
    end

    def create_logs
      FileUtils.mkdir_p(@logs_dir) unless File.directory?(@logs_dir)
    end


  end
end