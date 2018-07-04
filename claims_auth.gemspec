$LOAD_PATH.push File.expand_path("../lib", __FILE__)

require "claims_auth/version"

Gem::Specification.new do |s|
  s.name        = "claims_auth"
  s.version     = ClaimsAuth::VERSION
  s.authors     = ["Jayson Uy"]
  s.email       = %w(uy.json@gmail.com)
  s.homepage    = "https://github.com/uy-json/claims-auth"
  s.summary     = "Declarative and unobtrusive authorization Rack middleware"
  s.description = "Lightweight declarative authorization middleware"
  s.license     = 'MIT'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency "railties", ">= 4.2"
  s.add_dependency "activesupport"
  s.required_ruby_version = ">= 2.4"

  s.add_development_dependency "rake", ">= 11.3.0"
  s.add_development_dependency "rspec"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "simplecov-console"
end