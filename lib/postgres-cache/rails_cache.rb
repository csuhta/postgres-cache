class ActiveSupport::Cache::Postgres < ActiveSupport::Cache::Store

  def initialize(*args)
    @cache = PostgresCache.new(*args)
  end

  def write(cache_key, value = nil)
    @cache.write(cache_key, value)
  end

  def read(cache_key)
    @cache.read(cache_key)
  end

  def delete(cache_key)
    @cache.delete(cache_key)
  end

  def exist?(cache_key)
    @cache.exists?(cache_key)
  end

  def fetch(*args, &block)
    @cache.fetch(*args, &block)
  end

  def clear
    @cache.clear
  end

end
