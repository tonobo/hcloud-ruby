# frozen_string_literal: true

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hcloud/version'

Gem::Specification.new do |spec|
  spec.name          = 'hcloud'
  spec.version       = Hcloud::VERSION
  spec.authors       = ['Tim Foerster']
  spec.email         = ['github@moo.gl']

  spec.summary       = 'HetznerCloud native Ruby client'
  spec.homepage      = 'https://github.com/tonobo/hcloud'

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'activesupport'
  spec.add_development_dependency 'bundler', '~> 1.15'
  spec.add_development_dependency 'grape'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_runtime_dependency 'activesupport'
  spec.add_runtime_dependency 'oj'
  spec.add_runtime_dependency 'typhoeus'
end
