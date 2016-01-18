# FclRailsDaemon

This gem was developed to facilitate through the CLI management processes running ruby programs.

## Installation

From Gemfile

```ruby
gem 'fcl_rails_daemon'
```

Then run:

    $ bundle

Or only install:

    $ gem install fcl_rails_daemon


## Configuration

After installation you need to create the directories and configuration files for this run

    $ fcld --configure

Will be created:

 * *config/fcld_rails_daemon.rb* (File where the commands are recorded)
 * *tmp/pids/fcld.yml* (Pids file where the commands are recorded)
 * *lib/fcl_rails_daemon/command_sample.rb* (A command template)


## How to use?

#### [--create] Create a new command

    $ fcld --create my_first_command

 * Adds a command in lib/fcl_rails_daemon
 * Records the command in config/fcl_rails_daemon.rb


#### [--help] Displays the manual for commands and options

    $ fcld --help


#### [--pids] Displays the pids of the commands registered

    $ fcld --pids


#### [--logs] Displays the logs files for each registered command

    $ fcld --logs


#### [start|stop|restart|status] Performs action for all registered commands

    $ fcld start


#### [--env] Sets the environment for Rails application

    $ fcld --env production start


#### [--command] Individual action to run a registered command

    $ fcld --command my_first_command start


#### [--process_name] Sets a name to be assigned to the process (by default the name is the name of the command)

    $ fcld --command my_first_command --process_name foo_my_first_command start


