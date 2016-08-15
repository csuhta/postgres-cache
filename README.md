## PostgresCache

WIP, not production ready.

How to use:

```ruby
cache = PostgresCache.new("YOUR_POSTGRES_DATABASE_URL")
# Or as a Rails.cache
cache = ActiveSupport::Cache::Postgres.new("YOUR_POSTGRES_DATABASE_URL")
# Or as a Rack::Cache (not working correctly yet)
entity_store = Rack::Cache::EntityStore::Postgres.new("YOUR_POSTGRES_DATABASE_URL")
meta_store = Rack::Cache::MetaStore::Postgres.new("YOUR_POSTGRES_DATABASE_URL")
```
