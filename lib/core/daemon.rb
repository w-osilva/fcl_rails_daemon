module FclRailsDaemon
  class Daemon
    cattr_reader :commands_valid
    @@pids_file = File.join(DAEMON_ROOT, DAEMON_CONFIG['pids_file'])
    @@commands_valid = ['start', 'stop', 'restart', 'status']

    def initialize(command: nil, log: nil)
      raise " ༼ つ ◕_◕ ༽つ OOOPS... It was not set the 'command' name in the command initialize." unless command
      @daemon ||= nil
      @command = command
      @log = (log) ?  File.join(DAEMON_ROOT, log) : File.join(DAEMON_ROOT, DAEMON_CONFIG['default_log'])
    end

    def self.pids
      f = File.open(@@pids_file, 'rb')
      f.read
    end

    def self.help
      raise " ༼ つ ◕_◕ ༽つ OOOPS... It was not implemented 'self.help' method in command"
    end

    def logs
      puts "#{@log} - (#{@command})"
    end

    def run(&block)
      #Load environment file (rails project)
      if COMMAND['fcld']
        env_file = File.join(DAEMON_ROOT, "config", "environment.rb")
        raise " ༼ つ ◕_◕ ༽つ OOOPS... Could not find the Rails environment file.    " unless File.exist? env_file
        require env_file
      end

      @daemon = Daemons.call(multiple: true) do
        # Force the output to the defined log
        $stdout.reopen(@log, 'a')
        $stderr.reopen(@log, 'a')
        $stdout.sync = true

        block.call
      end
    end

    def start
      pid = get_pid @command
      if running?(pid)
        puts "proc: processo com pid #{pid} está rodando. (#{@command})"
        return
      end
      run
      set_pid(@command, @daemon.pid.pid) if @daemon
    end

    def stop
      pid = get_pid @command

      unless running? pid
        puts "proc: processo não está rodando. (#{@command})"
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
        puts "proc: processo com pid #{pid} está rodando. (#{@command}) "
      else
        puts "proc: processo não está rodando. (#{@command}) "
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
          puts "proc: não existe processo com pid #{pid}. (#{@command})"
          status = false
        ensure
          if status == false
            puts "proc: processo com pid #{pid} está parado. (#{@command})"
          else
            puts "proc: processo com pid #{pid} foi parado. (#{@command})"
          end
        end
      else
        puts "proc: não existe processo com pid #{pid}. (#{@command})"
      end
    end

  end
end
