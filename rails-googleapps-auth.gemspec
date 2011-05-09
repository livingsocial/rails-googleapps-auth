$:.push File.expand_path("../lib", __FILE__)
require "lib/version"

Gem::Specification.new do |gem|
  gem.name         = "googleapps-auth"
  gem.summary      = "Google Apps Auth Provider for Rails"
  gem.description  = "Use Google Apps as an Authentication Provider"
  gem.version      = GoogleAppsAuth::VERSION

  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.require_paths = ["lib"]
end