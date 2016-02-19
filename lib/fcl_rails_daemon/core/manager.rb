module FclRailsDaemon
  class Manager
    @@commands = FclRailsDaemon::Recorder.load

    def self.run(argv)
      self.pids if argv.include?('--pids')
      self.logs if argv.include?('--logs')
      self.set_process_name(argv) if (argv.include?('--command') && argv.include?('--process_name'))
      self.create_command(argv) if argv.include?('--create')
      self.help(ARGV) unless self.valid?(argv)

      command ||= nil
      action = argv.last
      if argv.include?('--command')
        i = argv.index('--command') + 1
        command = argv[i]
      end
      registered = self.get_registered command
      registered.each { |command| command.send(action) }
    end

    def self.help(argv)
      action = argv.last
      command ||= nil
      if (argv.include?('--command') && argv.include?('--help'))
        i = argv.index('--command') + 1
        command = argv[i]
      end
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
      i = argv.index('--create') + 1
      command = argv[i]
      unless command
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The command name has not been defined    "
        exit
      end
      if Daemon.commands_valid.include? command
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The command can not be named #{command}    "
        exit
      end
      FclRailsDaemon::CommandGenerator.create(command)
      exit
    end

    def self.set_process_name(argv)
      i = argv.index('--command') + 1
      command = argv[i]
      i = argv.index('--process_name') + 1
      name = argv[i]
      if Daemon.commands_valid.include? command
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The command can not be named #{command}    "
        exit
      end
      if Daemon.commands_valid.include? name
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The process can not be named #{command}    "
        exit
      end
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

  end
end
