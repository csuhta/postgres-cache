$LOAD_PATH.push File.expand_path("../lib", __FILE__)
require "postgres-cache/version"

Gem::Specification.new do |s|

  s.name          = "postgres-cache"
  s.version       = PostgresCache::VERSION::STRING
  s.platform      = Gem::Platform::RUBY
  s.licenses      = ["MIT"]
  s.authors       = ["Corey Csuhta"]
  s.homepage      = "https://github.com/csuhta/postgres-cache"
  s.summary       = "A Ruby/Rack/Rails key/value storage that uses Postgres."
  s.description   = "A key/value store that uses Postgres unlogged tables. Includes support for becoming the Rails cache and use with Rack::Cache."

  s.files = `git ls-files`.split("\n")
  s.test_files = `git ls-files --directory test`.split("\n")
  s.require_paths = ["lib"]

  s.required_ruby_version = ">= 2.3"

  s.add_dependency "activesupport", "~> 5.0.0"
  s.add_dependency "rack-cache"
  s.add_dependency "pg"

  s.add_development_dependency "rake", "~> 10"
  s.add_development_dependency "bundler", "~> 1.3"
  s.add_development_dependency "minitest", "~> 5.7"

end
