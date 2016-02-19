module FclRailsDaemon
  class CommandGenerator

    def self.create(command)
      command_camel = ActiveSupport::Inflector.camelize(command)
      command_undescore = ActiveSupport::Inflector.underscore(command)
      content = get_content(command)
      file = File.join(DAEMON_ROOT, DAEMON_CONFIG['command_path'], command_undescore + '.rb' )

      if File.exist?(file)
        puts " ༼ つ ◕_◕ ༽つ OOOPS... Command already exists.   "
      else
        File.open(file, 'wb') {|f| f.write(content) }

        file_record = File.join(DAEMON_ROOT, DAEMON_CONFIG['register_file'] )
        content_to_register = "\nFclRailsDaemon::Recorder.add(command: '#{command_undescore}', class_reference: #{command_camel})"
        File.open(file_record, 'a+') {|f| f << content_to_register }

        puts " ༼ つ ◕_◕ ༽つ OK... Command created and registered!!!   "
        puts "New command: #{file}    "
        puts "Commands registered: #{file_record}    "
      end
      exit
    end

    def self.get_content(command)
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
      description: "This command is a sample, write here a valid description - Run every 10 seconds",
      sample: ["--command #{command_undescore} |start|stop|restart|status|"]
    }
  end

    # Is necessary to implement the method "run"
  def run
    # Call the run method of the parent class (super) through a block that will contain your code
    # You can optionally provide the parameter "loop" and "sleep" for the command to run repeatedly
    super(loop: true, sleep:10) do
      puts "Running "+ @command +" :)"
    end
  end

end
      FILE
      content
    end

  end
end