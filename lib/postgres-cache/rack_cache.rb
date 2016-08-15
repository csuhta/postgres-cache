class Rack::Cache::EntityStore::Postgres < Rack::Cache::EntityStore

  def initialize(*args)
    @cache = PostgresCache.new(*args)
  end

  def write(entity_body)
    buffer = StringIO.new
    cache_key, size = slurp(entity_body) do |hunk|
      buffer.write(hunk)
    end
    @cache.write(cache_key, buffer.string)
    return [cache_key, size]
  end

  def exist?(cache_key)
    @cache.key_exists?(cache_key)
  end

  def read(cache_key)
    @cache.read(cache_key)
  end

  def purge(cache_key)
    @cache.delete(cache_key)
  end

end

class Rack::Cache::MetaStore::Postgres < Rack::Cache::EntityStore

  def initialize(*args)
    @cache = PostgresCache.new(*args)
  end

  def read(cache_key)
    @cache.read(cache_key)
  end

  def write(cache_key, value)
    @cache.write(cache_key, value)
  end

  def purge(cache_key)
    @cache.delete(cache_key)
  end

end
