# -*- encoding: utf-8 -*-
require File.expand_path('../lib/guitar_tabs/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Andriy Dmytrenko"]
  gem.email         = ["refresh.xss@gmail.com"]
  gem.description   = %q{Library to read meta info from a gp5,gp4 files}
  gem.summary       = %q{Guitar Tabs library}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "guitar_tabs"
  gem.require_paths = ["lib"]
  gem.version       = GuitarTabs::VERSION
end
