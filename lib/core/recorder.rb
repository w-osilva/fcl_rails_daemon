module FclRailsDaemon
  class Recorder
    @@commands ||= {}

    def self.add(command: nil, class_reference: nil)
      raise " ༼ つ ◕_◕ ༽つ OOOPS... Attribute 'command' does not set." unless command
      raise " ༼ つ ◕_◕ ༽つ OOOPS... Attribute 'ref_class' does not set." unless class_reference
      @@commands[command] = class_reference
    end

    def self.load
      @@commands
    end

  end
end