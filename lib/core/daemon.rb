module FclRailsDaemon
  class Daemon
    cattr_reader :commands_valid
    attr_accessor :process_name
    attr_accessor :log_file

    @@pids_file = File.join(DAEMON_ROOT, DAEMON_CONFIG['pids_file'])
    @@commands_valid = ['start', 'stop', 'restart', 'status']

    def initialize(command: nil, log: nil, process_name: nil)
      raise " ༼ つ ◕_◕ ༽つ OOOPS... It was not set the 'command' name in the command initialize." unless command
      @daemon ||= nil
      @command = command
      @log_file = (log) ?  File.join(DAEMON_ROOT, log) : File.join(DAEMON_ROOT, DAEMON_CONFIG['default_log'])
      @process_name = (process_name) ? process_name : command
    end

    def self.pids
      f = File.open(@@pids_file, 'rb')
      f.read
    end

    def self.help
      raise " ༼ つ ◕_◕ ༽つ OOOPS... It was not implemented 'self.help' method in command"
    end

    def run(&block)
      #Load environment file (rails project)
      if COMMAND['fcld']
        env_file = File.join(DAEMON_ROOT, "config", "environment.rb")
        raise " ༼ つ ◕_◕ ༽つ OOOPS... Could not find the Rails environment file.    " unless File.exist? env_file
        require env_file
      end

      @daemon = Daemons.call(multiple: true, app_name: @process_name) do
        #set process_name
        Process.setproctitle(@process_name)

        # Force the output to the defined log
        $stdout.reopen(@log_file, 'a')
        $stderr.reopen(@log_file, 'a')
        $stdout.sync = true

        block.call
      end
    end

    def start
      pid = get_pid @command
      if running?(pid)
        puts "#{@process_name}: process with pid #{pid} is already running."
        return
      end
      run
      set_pid(@command, @daemon.pid.pid) if @daemon
    end

    def stop
      pid = get_pid @command

      unless running? pid
        puts "#{@process_name}: process is not running."
        return
      end
      kill pid
    end

    def restart
      stop
      start
    end

    def status
      pid = get_pid @command
      if running? pid
        puts "#{@process_name}: process with pid #{pid} is running."
      else
        puts "#{@process_name}: process is not running."
      end
    end

    private
    def get_pid(command)
      pids = YAML.load_file(@@pids_file)
      (pids.has_key?(command)) ? pids[command] : nil
    end

    def set_pid(command, pid)
      pids = YAML.load_file(@@pids_file)
      pids[command] = pid
      File.open(@@pids_file, 'wb') do |f|
        f <<  pids.to_yaml
      end
    end

    def running?(pid)
      status = false
      if pid
        begin
          Process.getpgid(pid)
          status = true
        rescue Errno::ESRCH
          status = false
        end
      end
      status
    end

    def kill(pid)
      status = false
      if pid
        begin
          Process.kill("KILL", pid)
          set_pid(@command, nil)
          status = true
        rescue Errno::ESRCH
          puts "#{@process_name}: there is no process with pid #{pid}."
          status = false
        ensure
          if status == false
            puts "#{@process_name}: process is not running."
          else
            puts "#{@process_name}: process was stopped."
          end
        end
      else
        puts "#{@process_name}: there is no process with pid #{pid}."
      end
    end

  end
end
