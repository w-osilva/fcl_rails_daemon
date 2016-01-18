COMMAND = {'fcld' => false}
DAEMON_ROOT = File.expand_path("")
DAEMON_CONFIG = {
  "pids_file" => 'tmp/pids/fcld.yml',
  "default_log" => 'log/fcld.log',
  "command_prefix" => 'fcld',
  "command_path" => 'lib/fcl_rails_daemon',
  "config_path" => 'config',
  "register_file" => 'config/fcl_rails_daemon.rb'
}