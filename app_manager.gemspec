# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'app_manager/version'

Gem::Specification.new do |spec|
  spec.name          = "app_manager"
  spec.version       = AppManager::VERSION
  spec.authors       = ["tatums"]
  spec.email         = ["tatum@ashlandstudios.com"]
  spec.summary       = %q{Library to quickly generate rack based sites.}
  spec.description   = %q{Library to quickly generate rack based sites.}
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency "thin", "~> 1.6"
  spec.add_development_dependency "bundler", "~> 1.7"
  spec.add_development_dependency "rake", "~> 10.0"
end
