class PostgresCache

  # Creates a new PostgresStore attached to the provided database.
  # The connection details can either be provided as a string containing a postgres:// URL
  # or as a hash with the keys `:host`, `:port`, `:username`, `:password`,
  # and `:database` as required for your connection.
  # If the environment variable DATABASE_URL is present, it will be used
  # to autodiscover credentials.
  def initialize(database_url_or_options = {}, options = {})
    establish_connection(database_url_or_options, options)
    create_cache_table unless self.cache_table_exists?
    prepare_statements
  end

  # Returns the underlying PG::Connection object.
  def connection
    @pg
  end

  # Connects to the Postgres database using the provided options.
  # See PostgresCaceh#initalize for more information
  def establish_connection(database_url_or_options = {}, options = {})

    case database_url_or_options
    when String
      uri = URI.parse(database_url_or_options)
      @table_name = options.fetch(:table_name, "application_cache").freeze
      @pg = PG::Connection.new(
        host: uri.host,
        port: uri.port,
        user: uri.user,
        password: uri.password,
        dbname: uri.path.tr("/",""),
        sslmode: "prefer",
      )
    else
      @table_name = database_url_or_options.fetch(:table_name, "application_cache").freeze
      @pg = PG::Connection.new(
        host: database_url_or_options[:host],
        port: database_url_or_options[:port],
        user: database_url_or_options[:username],
        password: database_url_or_options[:password],
        dbname: database_url_or_options[:database],
        sslmode: "prefer",
      )
    end

  end

  # True if the cache table exists in Postgres.
  def cache_table_exists?
    @pg.exec(%{SELECT 1 FROM pg_class WHERE pg_class.relname = '#{@table_name}';}).ntuples.eql?(1)
  end

  # Creates the configured cache table in the Postgres database.
  def create_cache_table(database_url_or_options = {}, options = {})
    @pg.exec(%{
      CREATE UNLOGGED TABLE #{@table_name} (
        key text UNIQUE NOT NULL,
        value bytea NULL
      );
    })
    return true
  end

  # Stores the given value in the Postgres cache under the given cache_key.
  # Note that ActiveSupport allows caching `nil` values.
  # Ruby objects that can’t be marshaled are not supported for `value`.
  # See the documentation for Marshal.dump for more information.
  def write(cache_key, value = nil)
    @pg.exec_prepared(@write_statement_name, [
      object_to_cache_key(cache_key),
      bytea_marshal(value)
    ])
    return true
  end

  # Returns the object stored under the given cache key in the Postgres cache.
  def read(cache_key)
    @pg.exec_prepared(@read_statement_name, [object_to_cache_key(cache_key)]) do |result|
      return nil unless result.ntuples.eql?(1)
      bytea_unmarshal(result.getvalue(0,0))
    end
  end

  # Deletes the given cache key from the Postgres cache.
  # Returns `true` if a key did exist.
  def delete(cache_key)
    @pg.exec_prepared(@delete_statement_name, [object_to_cache_key(cache_key)]).cmd_tuples.eql?(1)
  end

  # Returns `true` if the given cache key exists in the Postgres cache.
  def exists?(cache_key)
    @pg.exec_prepared(@exists_statement_name, [object_to_cache_key(cache_key)]).ntuples.eql?(1)
  end

  # Removes all entries from the cache.
  # This method will affect all processes using the cache.
  def clear
    @pg.exec_prepared(@clear_statement_name)
    return true
  end

  # Returns the value stored in Postgres under the given cache key.
  # If no block is provided and the cache key is not present, then `nil` is returned.
  # If a block was provided, it is evaluated and the yielded
  # value of the block is stored under the given key and returned.
  # Ruby objects that can’t be marshaled are not supported for the yielded value.
  # See the documentation for Marshal.dump for more information.
  def fetch(cache_key, &block)
    if value = read(cache_key)
      return value
    elsif block_given?
      value = yield
      write(cache_key, value)
      return value
    else
      return nil
    end
  end

  protected

  def bytea_unmarshal(raw_value)
    Marshal.load(@pg.unescape_bytea(raw_value))
  end

  def bytea_marshal(object)
    @pg.escape_bytea(Marshal.dump(object))
  end

  # Converts the given `object` into a cache key following
  # the rules specified in ActiveSupport::Cache::CacheStore
  def object_to_cache_key(object)
    if object.is_a?(String)
      return object
    elsif object.respond_to?(:cache_key)
      return object.cache_key
    elsif object.is_a?(Array)
      return object.map{ |element| object_to_cache_key(element) }.to_param
    elsif object.respond_to?(:to_param)
      return object.to_param
    else
      return object.to_s
    end
  end

  def prepare_statements

    @statement_identifier  = SecureRandom.hex(8).freeze

    @read_statement_name   = "postgres_cache_#{@statement_identifier}_read".freeze
    @write_statement_name  = "postgres_cache_#{@statement_identifier}_write".freeze
    @exists_statement_name = "postgres_cache_#{@statement_identifier}_exists".freeze
    @delete_statement_name = "postgres_cache_#{@statement_identifier}_delete".freeze
    @clear_statement_name  = "postgres_cache_#{@statement_identifier}_clear".freeze

    @read_statement = %{
      SELECT #{@table_name}.value
      FROM #{@table_name}
      WHERE #{@table_name}.key = $1::text;
    }.squish.freeze

    @write_statement = %{
      INSERT INTO #{@table_name} (key, value)
      VALUES ($1::text, $2::bytea)
      ON CONFLICT (key) DO UPDATE
      SET value = EXCLUDED.value::bytea;
    }.squish.freeze

    @exists_statement  = %{
      SELECT 1
      FROM #{@table_name}
      WHERE #{@table_name}.key = $1::text;
    }.squish.freeze

    @delete_statement = %{
      DELETE FROM #{@table_name}
      WHERE #{@table_name}.key = $1::text;
    }.squish.freeze

    @clear_statement = %{
      TRUNCATE TABLE #{@table_name};
    }.squish.freeze

    @pg.prepare(@write_statement_name, @write_statement)
    @pg.prepare(@read_statement_name, @read_statement)
    @pg.prepare(@exists_statement_name, @exists_statement)
    @pg.prepare(@delete_statement_name, @delete_statement)
    @pg.prepare(@clear_statement_name, @clear_statement)

  end

end
