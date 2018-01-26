# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'active_enumerable/version'

Gem::Specification.new do |spec|
  spec.name          = "active_enumerable"
  spec.version       = ActiveEnumerable::VERSION
  spec.authors       = ["Dustin Zeisler"]
  spec.email         = ["dustin@zeisler.net"]

  spec.summary       = %q{Provides ActiveRecord like query methods for use in Ruby Enumerable collections.}
  spec.description   = %q{Provides ActiveRecord like query methods for use in Ruby Enumerable collections. Use Hashes or custom Ruby Objects to represent records.}
  spec.homepage      = "https://github.com/zeisler/active_enumerable"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.required_ruby_version = '>= 2.1'

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.4"
  spec.add_development_dependency "simplecov", "~> 0.15.1"
end
