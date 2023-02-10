class Adapters::RedisCacheAdapter
  def self.get(key)
    connection.get(key)
  end

  def self.put(key, value, options = {})
    connection.set(key, value, **options)
  end

  private

  def self.connection
    Rails.configuration.x.service_token_cache_redis
  end
end
