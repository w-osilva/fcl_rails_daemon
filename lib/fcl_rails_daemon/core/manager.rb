module FclRailsDaemon
  class Manager
    @@commands = FclRailsDaemon::Recorder.load

    def self.run(argv)
      self.pids if argv.include?('--pids')
      self.logs if argv.include?('--logs')
      self.set_process_name(argv) if (argv.include?('--command') && argv.include?('--process_name'))
      self.create_command(argv) if argv.include?('--create')
      self.destroy_command(argv) if argv.include?('--destroy')
      self.help(ARGV) unless self.valid?(argv)

      command ||= nil
      command = CommandLine.parse_option('--command', argv) if argv.include?('--command')
      action = argv.last
      registered = self.get_registered command
      registered.each { |command| command.send(action) }
    end

    def self.help(argv)
      command ||= nil
      command = CommandLine.parse_option('--command', argv) if (argv.include?('--command') && argv.include?('--help'))
      helpers = self.get_helpers(command)
      self.show_helpers helpers
    end

    def self.valid?(argv)
      Daemon.commands_valid.include?(argv.last) && !(argv.include?('--help'))
    end

    private
    def self.get_registered(command = nil)
      list = []
      @@registered ||= {}
      if command
        raise " ༼ つ ◕_◕ ༽つ OOOPS... Command '#{command}' is not registered.    " unless @@commands.has_key? command
        @@registered[command] = (@@registered.has_key? command) ? @@registered[command] : @@commands[command].new
        list << @@registered[command]
        return list
      end
      @@commands.each do |k, c|
        list << @@registered[k] = (@@registered.has_key? k) ? @@registered[k] : c.new
      end
      list
    end

    def self.get_helpers(command = nil)
      list = []
      @@helpers ||= {}
      if command
        raise " ༼ つ ◕_◕ ༽つ OOOPS... Command '#{command}' is not registered.    " unless @@commands.has_key? command
        @@helpers[command] = (@@helpers.has_key? command) ? @@helpers[command] : @@commands[command].help
        list << @@helpers[command]
        return list
      end
      @@commands.each do |k, c|
        list << @@helpers[k] = c.help unless @@helpers.has_key?(k)
      end
      list
    end

    def self.show_helpers(helpers)
      prefix = DAEMON_CONFIG['command_prefix']

      puts "\n------------------------------------------------------------------------------------------------------------\n"
      puts "  FCL_RAILS_DAEMON\n"
      puts "------------------------------------------------------------------------------------------------------------\n"
      puts "  [start|stop|restart|status] option to control all processes at once"
      puts "    #{prefix} start\n\n"
      puts "  [--help] to view the manual \n"
      puts "    #{prefix} --help\n"
      puts "    [--command] to see the manual of a specific command\n"
      puts "      #{prefix} --command sample_command --help\n\n"
      puts "  [--env] to define the environment of the Rails application"
      puts "    #{prefix} --env production start\n\n"
      puts "  [--create] to create a new command"
      puts "    #{prefix} --create my_first_command\n\n"
      puts "  [--destroy] to destroy a command"
      puts "    #{prefix} --destroy my_first_command\n\n"
      puts "  [--command] to control specific command"
      puts "    #{prefix} --command sample_command start\n"
      puts "    [--process_name] to define a name for the process"
      puts "      #{prefix} --command sample_command --process_name my_process start\n\n"
      puts "  [--pids] option to see pids process for each command"
      puts "    #{prefix} --pids\n\n"
      puts "  [--logs] option to see the log files set for each command"
      puts "    #{prefix} --logs\n\n"
      puts "------------------------------------------------------------------------------------------------------------\n"
      puts "  COMMANDS REGISTERED\n"
      puts "------------------------------------------------------------------------------------------------------------\n"

      helpers.each do |h|
        puts "  #{h[:description]}"
        h[:sample].each do |e|
          puts "   #{e}"
        end
        puts ""
      end
      exit
    end

    def self.create_command(argv)
      command = CommandLine.parse_option('--create', argv)
      unless command
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The command name has not been defined    "
        exit
      end
      validate_command_name(command)
      FclRailsDaemon::CommandGenerator.create(command)
      exit
    end

    def self.destroy_command(argv)
      command = CommandLine.parse_option('--destroy', argv)
      unless command
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The command name has not been defined    "
        exit
      end
      validate_command_name command
      FclRailsDaemon::CommandGenerator.destroy(command)
      exit
    end

    def self.set_process_name(argv)
      command = CommandLine.parse_option('--command', argv)
      name = CommandLine.parse_option('--process_name', argv)
      validate_command_name command
      validate_process_name name
      registered = self.get_registered command
      registered.each { |command| command.process_name = name }
    end

    def self.logs
      registered = self.get_registered nil
      registered.each { |command| puts "#{command.process_name}: #{command.log_file}" }
      exit
    end

    def self.pids
      puts Daemon.pids
      exit
    end

    def self.validate_command_name(command)
      if Daemon.commands_valid.include? command
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The command can not be named #{command}    "
        exit
      end
    end

    def self.validate_process_name(process_name)
      if Daemon.commands_valid.include? process_name
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The process can not be named #{process_name}    "
        exit
      end
    end
  end
end
