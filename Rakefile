# Creates `rake compile`
spec = Gem::Specification.load("postgres-cache.gemspec")

desc "Open an irb session preloaded with this library"
task :console do
  exec "irb -rubygems -I lib -r postgres-cache.rb"
end
