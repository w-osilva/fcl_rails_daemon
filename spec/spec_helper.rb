$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'fcl_rails_daemon/setup'
(FclRailsDaemon::Setup.new).configure
require 'fcl_rails_daemon'

RSpec.configure do |config|
  config.before(:all, &:silence_output)
  config.after(:all, &:enable_output)
end

public
# Redirects stderr and stdout to /dev/null.
def silence_output
  @orig_stderr = $stderr
  @orig_stdout = $stdout

  # redirect stderr and stdout to /dev/null
  $stderr = File.new('/dev/null', 'w')
  $stdout = File.new('/dev/null', 'w')
end

# Replace stdout and stderr so anything else is output correctly.
def enable_output
  $stderr = @orig_stderr
  $stdout = @orig_stdout
  @orig_stderr = nil
  @orig_stdout = nil
end
