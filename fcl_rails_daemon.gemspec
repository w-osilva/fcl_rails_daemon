# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'fcl_rails_daemon/version'

Gem::Specification.new do |spec|
  spec.name          = "fcl_rails_daemon"
  spec.version       = FclRailsDaemon::VERSION
  spec.licenses      = ['MIT']
  spec.platform      = Gem::Platform::RUBY
  spec.authors       = ["Washington Silva"]
  spec.email         = ["w-osilva@hotmail.com"]
  spec.homepage      = ""
  spec.rubyforge_project = "fcl_rails_daemon"
  spec.files         = `git ls-files -z`.split("\x0")
  spec.test_files    = `git ls-files -- {test,spec}/*`.split("\n")
  spec.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.required_ruby_version = '>= 2.0.0'

  spec.summary       = %q{This gem was developed to facilitate the creation and management processes in rails projects.}
  spec.description   = %q{This gem creation commands makes it easy ( Ruby scripts) to run in the background ( daemon ). It has a friendly CLI to manage processes related to commands.}

  spec.add_dependency "bundler"
  spec.add_dependency "activesupport"
  spec.add_dependency "daemons", "~> 1.2"

  spec.add_development_dependency "rspec"
end
