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

  spec.summary       = %q{Projeto utilizado para gerar comandos que podem ser executados em background (daemons).}
  spec.description   = %q{Este tem como maior caracteristica a facilidade de gerar comandos e gerenciá-los de forma independente.}

  spec.add_dependency "bundler"
  spec.add_dependency "activesupport"
  spec.add_dependency "rake"
  spec.add_dependency "daemons", "~> 1.2"

  spec.add_development_dependency "rspec"
end
