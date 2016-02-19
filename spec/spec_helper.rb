$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'fcl_rails_daemon/setup'
(FclRailsDaemon::Setup.new).configure
require 'fcl_rails_daemon'
