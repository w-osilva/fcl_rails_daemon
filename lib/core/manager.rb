module FclRailsDaemon
  class Manager
    @@commands = FclRailsDaemon::Recorder.load

    def self.run(argv)
      COMMAND['fcld'] = true
      self.set_env(argv) if argv.include?('--env')
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
        raise " ༼ つ ◕_◕ ༽つ OOOPS... Command '#{command}' is not registered." unless @@commands.has_key? command
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
        raise " ༼ つ ◕_◕ ༽つ OOOPS... Command '#{command}' is not registered." unless @@commands.has_key? command
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

    def self.set_env(argv)
      i = argv.index('--env') + 1
      env = argv[i]
      ENV['RAILS_ENV'] = env
    end

    def self.create_command(argv)
      i = argv.index('--create') + 1
      command = argv[i]
      unless command
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The command name has not been defined"
        exit
      end
      if Daemon.commands_valid.include? command
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The command can not be named #{command}"
        exit
      end

      command_camel = ActiveSupport::Inflector.camelize(command)
      command_undescore = ActiveSupport::Inflector.underscore(command)

      content = <<-FILE
class #{command_camel} < FclRailsDaemon::Daemon

  # Is necessary to implement the method "initialize"
  def initialize
    # Set the parameter "command" (name that will be referenced in the command entered in the terminal)
    # The parameter "log" is optional but suggest it is set a log for each command to prevent many commands write on deafult log (if you have many commands in your application)
    # The parameter "process_name" is optional (is the name that will be assigned to the process)
    super(command: "#{command_undescore}", log: "log/#{command_undescore}.log", process_name: "#{command_undescore}")
  end

  # Is necessary to implement the method "self.help"
  def self.help
    # Should return a hash with " description" and "example"
    {
      description: "This command is a sample - Run every 1 minute",
      sample: ["--command #{command_undescore} |start|stop|restart|status|"]
    }
  end

  # Is necessary to implement the method "run"
  def run
    # Call the run method of the parent class (super) through a block that will contain your code
    super do
      # If you want your command be running repeatedly put inside a loop
        @counter_sample = 0
        loop do
        # Write your code here !!!
        # Do not use Process.exit (true) , exit () , abort ( ) in your code because it infers the death of the Daemon process

        @counter_sample += 1
        puts "Running "+ @command +" for " + @counter_sample.to_s + " time :)"

        # Wait in seconds before running your command again
        sleep(10)
      end
    end
  end

end
      FILE

      file = File.join(DAEMON_ROOT, DAEMON_CONFIG['command_path'], command_undescore + '.rb' )

      if File.exist?(file)
        puts " ༼ つ ◕_◕ ༽つ OOOPS... Command already exists."
      else
        File.open(file, 'wb') {|f| f.write(content) }

        file_record = File.join(DAEMON_ROOT, DAEMON_CONFIG['register_file'] )
        content_to_register = "\nFclRailsDaemon::Recorder.add(command: '#{command_undescore}', ref_class: #{command_camel})"
        File.open(file_record, 'a+') {|f| f << content_to_register }

        puts " ༼ つ ◕_◕ ༽つ OK... Command created and registered!!! "
        puts "New command: #{file} "
        puts "Commands registered: #{file_record} "
      end
      exit
    end

    def self.set_process_name(argv)
      i = argv.index('--command') + 1
      command = argv[i]
      i = argv.index('--process_name') + 1
      name = argv[i]
      if Daemon.commands_valid.include? command
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The command can not be named #{command}"
        exit
      end
      if Daemon.commands_valid.include? name
        puts " ༼ つ ◕_◕ ༽つ OOOPS... The process can not be named #{command}"
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
