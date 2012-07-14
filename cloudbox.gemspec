# -*- encoding: utf-8 -*-
require File.expand_path('../lib/cloudbox/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["E.J. Finneran"]
  gem.email         = ["ej.finneran@gmail.com"]
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.add_dependency("mixlib-shellout", "~> 1.0.0")
  gem.add_dependency("jbuilder", "~> 0.4.0")
  gem.add_dependency("uuid", "~> 2.3.5")
  gem.add_dependency("sinatra", "~> 1.3.2")
  gem.add_development_dependency("rspec", "~> 2.10.0")
  gem.add_development_dependency("rack-test")
  gem.add_development_dependency("simplecov", "~> 0.6.4")
  gem.name          = "cloudbox"
  gem.require_paths = ["lib"]
  gem.version       = Cloudbox::VERSION
end
