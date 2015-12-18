module FclRailsDaemon
  class Registrador
    @@comandos ||= {}

    def self.add(comando: nil, classe: nil)
      raise "Comando não definido" unless comando
      raise "Classe não definida" unless classe
      @@comandos[comando] = classe
    end

    def self.load
      @@comandos
    end

  end
end