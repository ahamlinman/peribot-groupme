# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'peribot/groupme/version'

Gem::Specification.new do |spec|
  spec.name          = 'peribot-groupme'
  spec.version       = Peribot::GroupMe::VERSION
  spec.authors       = ['Alex Hamlin']
  spec.email         = ['alexh1995@gmail.com']

  spec.summary       = 'GroupMe components for Peribot.'
  spec.homepage      = 'https://github.com/ahamlinman/peribot-groupme'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'peribot', '~> 0.6.4'
  spec.add_dependency 'groupme', '~> 0.0.7'
  spec.add_dependency 'faraday', '~> 0.9.2'
  spec.add_dependency 'faraday_middleware', '~> 0.9.0' # GroupMe can't use 0.10

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 11.1'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 0.39.0'
  spec.add_development_dependency 'simplecov', '~> 0.11.2'
  spec.add_development_dependency 'webmock', '~> 1.24.2'

  if RUBY_VERSION >= '2.1.0'
    spec.add_development_dependency 'mutant-rspec', '~> 0.8.8'
  end
end
