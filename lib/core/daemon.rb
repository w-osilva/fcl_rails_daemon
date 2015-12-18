module FclRailsDaemon
  class Daemon

    cattr_reader :comandos_validos
    @@pids_file = File.join(DAEMON_ROOT, DAEMON_CONFIG['pids_file'])
    @@comandos_validos = ['start', 'stop', 'restart', 'status']


    def initialize(task: nil, log: nil)
      raise "Não foi definida o nome da task no construtor do comando" unless task
      @daemon ||= nil
      @task = task
      @log = (log) ?  File.join(DAEMON_ROOT, log) : File.join(DAEMON_ROOT, DAEMON_CONFIG['default_log'])
    end

    def self.pids
      f = File.open(@@pids_file, 'rb')
      f.read
    end

    def self.help
      raise "Não foi implementado o método self.help no comando"
    end

    def log
      puts "#{@log} (#{@task})"
    end

    def run(&block)
      @daemon = Daemons.call(multiple: true) do
        # força a saída para o output definido
        $stdout.reopen(@log, 'a')
        $stderr.reopen(@log, 'a')
        $stdout.sync = true

        block.call
      end
    end

    def start
      pid = get_pid @task
      if running?(pid)
        puts "proc: processo com pid #{pid} está rodando. (#{@task})"
        return
      end
      run
      set_pid(@task, @daemon.pid.pid) if @daemon
    end

    def stop
      pid = get_pid @task

      unless running? pid
        puts "proc: processo não está rodando. (#{@task})"
        return
      end
      kill pid
    end

    def restart
      stop
      start
    end

    def status
      pid = get_pid @task
      if running? pid
        puts "proc: processo com pid #{pid} está rodando. (#{@task}) "
      else
        puts "proc: processo não está rodando. (#{@task}) "
      end
    end

    private
    def get_pid(task)
      pids = YAML.load_file(@@pids_file)
      (pids.has_key?(task)) ? pids[task] : nil
    end

    def set_pid(task, pid)
      pids = YAML.load_file(@@pids_file)
      pids[task] = pid
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
          set_pid(@task, nil)
          status = true
        rescue Errno::ESRCH
          puts "proc: não existe processo com pid #{pid}. (#{@task})"
          status = false
        ensure
          if status == false
            puts "proc: processo com pid #{pid} está parado. (#{@task})"
          else
            puts "proc: processo com pid #{pid} foi parado. (#{@task})"
          end
        end
      else
        puts "proc: não existe processo com pid #{pid}. (#{@task})"
      end
    end

  end
end
