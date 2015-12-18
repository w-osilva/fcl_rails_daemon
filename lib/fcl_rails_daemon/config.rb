DAEMON_ROOT = File.expand_path("")

DAEMON_CONFIG = {
  "pids_file" => 'tmp/pids/fcld.yml',
  "default_log" => 'log/fcld.log',
  "command_prefix" => 'fcld',
  "command_path" => 'lib/fcld_comandos',
  "register_file" => 'config/fcld_rails_daemon.rb'
}