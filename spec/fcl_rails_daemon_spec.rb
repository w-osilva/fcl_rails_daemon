require 'spec_helper'

describe FclRailsDaemon do

  before(:all) do
    @setup = FclRailsDaemon::Setup.new
    @setup.configure
  end

  after(:all) do
    FileUtils.rm_rf @setup.config_dir
    FileUtils.rm_rf @setup.logs_dir
    FileUtils.rm_rf @setup.pids_dir
    FileUtils.rm_rf @setup.command_sample_file
  end

  describe "Environment Variables" do
    it 'has a version number' do
      expect(FclRailsDaemon::VERSION).not_to be nil
    end
    context "Config" do
      it 'has a root path defined' do
        expect(DAEMON_ROOT).instance_of? String
      end
      it 'has config collection defined' do
        expect(DAEMON_CONFIG).instance_of? Hash
      end
    end
  end

  describe "#{FclRailsDaemon::CommandGenerator.inspect}" do
    it 'creation of the a command' do
      FclRailsDaemon::CommandGenerator.create "new_command"
      path = File.join(@setup.commands_dir, "new_command.rb")
      expect(File.exist?(path)).to eq(true)
      FileUtils.rm_rf(path)
    end
  end

end
