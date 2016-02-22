require 'spec_helper'

describe FclRailsDaemon do

  before(:each) do
    @setup = FclRailsDaemon::Setup.new
    @setup.configure
  end

  after(:each) do
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
    subject(:create_command) do
      FclRailsDaemon::CommandGenerator.create "new_command"
      file = File.join(@setup.commands_dir, "new_command.rb")
    end
    subject(:remove_command) do
      file = File.join(@setup.commands_dir, "new_command.rb")
      FileUtils.rm_rf(file) if File.exist? file
    end
    it 'creation of the a command' do
      path = create_command
      expect(File.exist? path).to eq(true)
      remove_command
    end

    subject(:register_command) do
      FclRailsDaemon::CommandGenerator.register "new_command"
      record = "FclRailsDaemon::Recorder.add(command: 'new_command', class_reference: NewCommand)"
    end
    it 'register a command' do
      record = register_command
      content = File.read(FclRailsDaemon::CommandGenerator.file_record)
      expect(content).to include record
    end

    subject(:unregister_command) { FclRailsDaemon::CommandGenerator.unregister "new_command" }
    it 'unregister a command' do
      record = register_command
      FclRailsDaemon::CommandGenerator.unregister "new_command"
      content = File.read(FclRailsDaemon::CommandGenerator.file_record)
      expect(content).not_to include record
    end
  end

  describe "#{FclRailsDaemon::Recorder}" do
    it "register new command" do
      FclRailsDaemon::Recorder.add(command: 'new_command', class_reference: String )
      expect(FclRailsDaemon::Recorder.load).to include "new_command"
    end
  end

  describe "#{FclRailsDaemon::Daemon}" do
    let(:new_command) do
      FclRailsDaemon::CommandGenerator.create "new_command"
      file = File.join(@setup.commands_dir, "new_command.rb")
    end
    let(:destroy_new_command) { FclRailsDaemon::CommandGenerator.destroy "new_command" }
    subject(:start_new_command) { `#{"bundle exec fcld --command new_command start"}` }
    subject(:stop_new_command) { `#{"bundle exec fcld --command new_command stop"}` }

    it "start a command" do
      new_command
      enable_output
      output = start_new_command
      expect(output).to include("new_command", "started")

      silence_output
      stop_new_command
      destroy_new_command
    end

    it "stop a command" do
      new_command
      start_new_command
      enable_output
      output = stop_new_command
      expect(output).to include("new_command", "stopped")

      silence_output
      destroy_new_command
    end
  end



end
