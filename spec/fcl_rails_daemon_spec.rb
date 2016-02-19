require 'spec_helper'

describe FclRailsDaemon do

  before(:all) do
    @setup = FclRailsDaemon::Setup.new
    @setup.configure
  end

  after(:all) do
    FileUtils.rm_rf @setup.config_dir
    FileUtils.rm_rf @setup.log_dir
    FileUtils.rm_rf @setup.pids_dir
    #FileUtils.rm_rf @setup.commands_dir
  end

  it 'has a version number' do
    expect(FclRailsDaemon::VERSION).not_to be nil
  end

  # describe "#{FclRailsDaemon::CommandGenerator.inspect}" do
  #   it 'verify creation of the a command' do
  #     expect(false).to eq(false)
  #   end
  # end

end
