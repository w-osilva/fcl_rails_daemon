module FclRailsDaemon
  class Gerenciador
    @@comandos = Registrador.load

    def self.run(argv)

      if argv.include?('--pids')
        puts Daemon.pids
        exit
      end

      if argv.include?('--logs')
        registrados = self.get_registrados nil
        registrados.each { |comando| comando.send('log') }
        exit
      end

      self.criar_comando(argv) if argv.include?('--create')

      self.help(ARGV) unless self.valid?(argv)

      task ||= nil
      acao = argv.last
      if argv.include?('--task')
        i = argv.index('--task') + 1
        task = argv[i]
      end
      registrados = self.get_registrados task
      registrados.each { |comando| comando.send(acao) }
    end


    def self.help(argv)
      acao = argv.last
      task ||= nil
      if (argv.include?('--task') && argv.include?('--help'))
        i = argv.index('--task') + 1
        task = argv[i]
      end
      helpers = self.get_helpers(task)
      self.show helpers
    end

    def self.valid?(argv)
      Daemon.comandos_validos.include?(argv.last) && !(argv.include?('--help'))
    end

    private
    def self.show(helpers)
      prefixo = DAEMON_CONFIG['command_prefix']

      puts "\n------------------------------------------------------------------------------------------------------------\n"
      puts "  FOOTSTATSD\n"
      puts "------------------------------------------------------------------------------------------------------------\n"
      puts "  * Use a opção --help para ver os manual para os comandos\n"
      puts "    #{prefixo} --help\n\n"
      puts "  * Use a opção start| stop | restart | status para controlar todos processos de uma vez\n"
      puts "    #{prefixo} start\n\n"
      puts "  * Use a opção --pids para ver os pids de processos\n"
      puts "    #{prefixo} --pids\n\n"
      puts "  * Use a opção --logs para ver os arquivos de log configurados para os comandos\n"
      puts "    #{prefixo} --logs\n\n"
      puts "  * Use a opção --task nome_comando start | stop | restart | status para controlar processos individualmente\n"
      puts "    #{prefixo} --task comando start\n\n"
      puts "------------------------------------------------------------------------------------------------------------\n"
      puts "  LISTA DE TASKS\n"
      puts "------------------------------------------------------------------------------------------------------------\n"

      helpers.each do |h|
        puts "  * #{h[:descricao]}"
        h[:exemplo].each do |e|
          puts "   #{e}"
        end
        puts ""
      end
      exit
    end

    def self.get_registrados(task = nil)
      lista = []
      @@registrados ||= {}
      if task
        raise "Comando não registrado # #{task} #" unless @@comandos.has_key? task
        @@registrados[task] = (@@registrados.has_key? task) ? @@registrados[task] : @@comandos[task].new
        lista << @@registrados[task]
        return lista
      end
      @@comandos.each do |k, c|
        lista << @@registrados[k] = (@@registrados.has_key? k) ? @@registrados[k] : c.new
      end
      lista
    end

    def self.get_helpers(task = nil)
      lista = []
      @@helpers ||= {}
      if task
        raise "Comando não registrado # #{task} #" unless @@comandos.has_key? task
        @@helpers[task] = (@@helpers.has_key? task) ? @@helpers[task] : @@comandos[task].help
        lista << @@helpers[task]
        return lista
      end
      @@comandos.each do |k, c|
        lista << @@helpers[k] = c.help unless @@helpers.has_key?(k)
      end
      lista
    end

    def self.criar_comando(argv)

      i = argv.index('--create') + 1
      comando = argv[i]
      unless comando
        puts "O nome do comando não foi definido"
        exit
      end
      if Daemon.comandos_validos.include? comando
        puts "O comando não pode ter o nome #{comando}"
        exit
      end

      comando_camel = ActiveSupport::Inflector.camelize(comando)
      comando_undescore = ActiveSupport::Inflector.underscore(comando)

      conteudo = <<-FILE
class #{comando_camel} < FclRailsDaemon::Daemon

  # Obrigatóriamente é necessário implementar o método "initialize"
  def initialize
    # Definir o parametro "task" (nome que será referenciado no comando digitado no terminal).
    #
    # O parametro "log" é opcional mas sugiro que seja definido um log para cada comando para evitar que muitos comandos
    # escrevam no log deafult (caso tenha# muitos comandos)
    super(task: "#{comando_undescore}", log: "log/#{comando_undescore}.log")
  end

  # Obrigatóriamente é necessário implementar o método self.help
  def self.help
    # Retornar Hash com "descricao" e "exemplo"
    {
      descricao: "Descrição do comando #{comando_undescore} :) - Executado a cada 1 min",
      exemplo: ["--task #{comando_undescore} start | stop | restart | status"]
    }
  end

  # Obrigatóriamente é necessário implementar o método run
  def run
    # Chamar o método run da classe pai (super) passando um bloco que vai conter seu código
    super do
      # Caso deseje que o seu comando fique executando repetidamente coloque dentro de um loop
      loop do
        # Escreva seu código aqui!!
        # Não use Process.exit(true), exit(), abort() em seu codigo pois infere na morte do processo do Daemon
        puts "Está executando #{comando_undescore}!  :)"

        # Espera em segundos antes de executar seu comando outra vez
        # Util no caso de simular um processo cronológico (esse exemplo vai executar o comando a cada 10 segundos)
        sleep(10)
      end
    end
  end

end
      FILE

      arquivo = File.join(DAEMON_ROOT, DAEMON_CONFIG['command_path'], comando_undescore + '.rb' )

      if File.exist?(arquivo)
        puts "Comando já existe..."
      else
        File.open(arquivo, 'wb') {|f| f.write(conteudo) }

        arquivo_registro = File.join(DAEMON_ROOT, DAEMON_CONFIG['register_file'] )
        conteudo_registrar = "\nFclRailsDaemon::Registrador.add(comando: '#{comando_undescore}', classe: #{comando_camel})"
        File.open(arquivo_registro, 'a+') {|f| f << conteudo_registrar }

        puts "Comando criado e registrado... "
        puts "Arquivo: #{arquivo} "
        puts "Registro: #{arquivo_registro} "
      end
      exit
    end

  end
end
