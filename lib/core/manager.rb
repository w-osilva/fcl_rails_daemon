module FclRailsDaemon
  class Manager
    @@commands = FclRailsDaemon::Recorder.load

    def self.run(argv)

      if argv.include?('--pids')
        puts Daemon.pids
        exit
      end

      if argv.include?('--logs')
        registered = self.get_registered nil
        registered.each { |command| command.send('log') }
        exit
      end

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
      self.show helpers
    end

    def self.valid?(argv)
      Daemon.commands_valid.include?(argv.last) && !(argv.include?('--help'))
    end

    private
    def self.show(helpers)
      prefix = DAEMON_CONFIG['command_prefix']

      puts "\n------------------------------------------------------------------------------------------------------------\n"
      puts "  FCL_RAILS_DAEMON\n"
      puts "------------------------------------------------------------------------------------------------------------\n"
      puts "  * Use the --help option to view the manual ( --command to see the manual of a specific command)\n"
      puts "    #{prefix} --help\n"
      puts "    #{prefix} --command sample_command --help\n\n"
      puts "  * Use the --create option to create a new command"
      puts "    #{prefix} --create my_first_command\n\n"
      puts "  * Use the |start|stop|restart|status| option to control all processes at once"
      puts "    #{prefix} start\n\n"
      puts "  * Use the --command option --logs to control specific command"
      puts "    #{prefix} --command sample_command start\n\n"
      puts "  * Use the --pids option to see pids process for each command"
      puts "    #{prefix} --pids\n\n"
      puts "  * Use the --logs option --logs to see the log files set for each command"
      puts "    #{prefix} --logs\n\n"
      puts "------------------------------------------------------------------------------------------------------------\n"
      puts "  COMMANDS REGISTERED\n"
      puts "------------------------------------------------------------------------------------------------------------\n"

      helpers.each do |h|
        puts "  * #{h[:description]}"
        h[:sample].each do |e|
          puts "   #{e}"
        end
        puts ""
      end
      exit
    end

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
    super(command: "#{command_undescore}", log: "log/#{command_undescore}.log")
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

  end
end
