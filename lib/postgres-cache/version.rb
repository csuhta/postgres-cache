class PostgresCache

  # Returns Urandom’s version number
  # @return [Gem::Version] PostgresCache’s version
  def self.version
    Gem::Version.new("1.0.0")
  end

  # Contains Urandom’s version number
  module VERSION
    MAJOR, MINOR, TINY, PRE = PostgresCache.version.segments
    STRING = PostgresCache.version.to_s
  end

end
