# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'hcloud/version'

Gem::Specification.new do |spec|
  spec.name          = 'hcloud'
  spec.version       = Hcloud::VERSION
  spec.authors       = ['Tim Foerster', 'Raphael Pour']
  spec.email         = ['github@moo.gl', 'rubygems@evilcookie.de']

  spec.summary       = 'HetznerCloud native Ruby client'
  spec.homepage      = 'https://github.com/tonobo/hcloud-ruby'

  spec.required_ruby_version = '>= 2.7.0'

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'activemodel'
  spec.add_development_dependency 'activesupport', '6.1.4.4'
  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'grape'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'webmock'
  spec.add_runtime_dependency 'activemodel'
  spec.add_runtime_dependency 'activesupport', '6.1.4.4'
  spec.add_runtime_dependency 'oj'
  spec.add_runtime_dependency 'typhoeus'
end
