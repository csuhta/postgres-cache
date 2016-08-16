## PostgresCache

A work in progress, not production ready.

PostgresCache is a Rails/Rack cache backed by a Postgres `UNLOGGED` table and `bytea` column. 

How to use:

```ruby
# This will create the table `application_cache` in your database
cache = PostgresCache.new("YOUR_POSTGRES_DATABASE_URL", table_name:"application_cache")
# Now you can store any Ruby object that can be marshaled in the database under a key
cache.write("your key", "some value")
cache.exists?("your key")
cache.read("your key")
cache.fetch("another key") do 
  "default value if not exists"
end
cache.delete("your key")
cache.clear
```

There is a wrapper for use as a Rails.cache: 

```ruby
Rails.application.config.cache = ActiveSupport::Cache::Postgres.new("YOUR_POSTGRES_DATABASE_URL")
```

Or as a Rack::Cache (not working correctly yet):

```ruby
entity_store = Rack::Cache::EntityStore::Postgres.new("YOUR_POSTGRES_DATABASE_URL")
meta_store = Rack::Cache::MetaStore::Postgres.new("YOUR_POSTGRES_DATABASE_URL")
```
