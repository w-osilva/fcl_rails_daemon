module FclRailsDaemon
  class ComandoExemplo < FclRailsDaemon::Daemon

    # Obrigatóriamente é necessário implementar o método "initialize" e definir o parametro "task" (nome que será
    # referenciado no comando digitado no terminal).
    #
    # O parametro "log" é opcional mas sugiro que seja definido um log para cada comando para evitar que muitos comandos
    # escrevam no mesmo arquivo ocasionando dificuldade em compreender qual saída pertence a qual comando (caso tenha
    # muitos comandos)
    def initialize
      super(task: 'meu_comando', log: 'log/meu_comando.log')
    end

    # Obrigatóriamente é necessário implementar o método self.help e retornar um Hash com "descricao" e "exemplo"
    def self.help
      {
        descricao: 'Executa meu comando :) - Executado a cada 1 min',
        exemplo: ['--task meu_comando start | stop | restart | status']
      }
    end

    # Obrigatóriamente é necessário implementar o método run e chamar o mesmo método run da classe pai (super) passando
    # um bloco que vai conter seu código
    def run
      super do

        # Caso deseje que o seu comando fique executando repetidamente coloque dentro de um loop
        loop do

          # Escreva seu código aqui!!
          # É importante que não exista nenhuma chamada para Process.exit(true), exit(), abort() pois infere na morte do
          # processo do Daemon
          puts "#{Time.now.to_s} - Está executando meu comando!  :)"

          # Espera em segundos antes de iniciar novamente
          # Util para que possa simular um processo cronológico (neste exemplo o comando será executado repetidamente
          # a cada 60 segundos)
          sleep(60)

        end

      end
    end

  end
end
