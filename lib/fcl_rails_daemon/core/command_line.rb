module FclRailsDaemon
  class CommandLine

    def self.parse_option(option, argv)
      i = argv.index(option) + 1
      argv[i]
    end

  end
end
