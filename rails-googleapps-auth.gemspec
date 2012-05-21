require "./lib/googleapps_auth/version"
require "date"

Gem::Specification.new do |gem|
  gem.name         = "googleapps-auth"
  gem.summary      = "Google Apps Auth Provider for Rails"
  gem.description  = "Use Google Apps as an Authentication Provider"
  gem.version      = GoogleAppsAuth::VERSION
  gem.date         = Date.today.to_s

  gem.authors      = ["Brian Muller"]
  gem.email        = "brian.muller@livingsocial.com"
  gem.homepage     = "https://github.com/livingsocial/rails-googleapps-auth"

  gem.add_runtime_dependency("actionpack", [">= 2.3.5"])
  gem.add_runtime_dependency("ruby-openid", ["= 2.1.8"])

  gem.add_development_dependency("activesupport", ["~> 3.0"])
  gem.add_development_dependency("tzinfo", [">= 0.3"])
  gem.add_development_dependency("actionpack", ["~> 3.0"])
  gem.add_development_dependency("activemodel", ["~> 3.0"])
  gem.add_development_dependency("railties", ["~> 3.0"])
  gem.add_development_dependency("rspec-rails", ["= 2.5.0"])

  gem.files = Dir["{lib}/**/*", "README", "LICENSE", "Gemfile"]
  gem.test_files = Dir["spec/**/*"]
end

