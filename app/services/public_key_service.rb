class PublicKeyService
  attr_reader :service_slug, :namespace, :ignore_cache

  def initialize(service_slug:, namespace: ENV['KUBECTL_SERVICES_NAMESPACE'], ignore_cache:)
    @service_slug = service_slug
    @namespace = namespace
    @ignore_cache = ignore_cache
  end

  def call
    return public_key if ignore_cache
    return cached_value if cached_value

    adapter.put(
      key, public_key, { ex: ttl_in_seconds }
    )

    public_key
  end

  private

  def public_key
    # In development, pull from the cache adapter directly to avoid
    # calling the authoritative source and to reflect current cached state
    return adapter.get(key) if Rails.env.development?

    @public_key ||=
      Support::ServiceTokenAuthoritativeSource.get_public_key(
        service_slug: service_slug,
        namespace: namespace
      )
  end

  def ttl_in_seconds
    ENV['SERVICE_TOKEN_CACHE_TTL'].to_i
  end

  def key
    @key ||= ["encoded-public-key", service_slug].join('-')
  end

  def cached_value
    @cached_value ||= adapter.get(key)
  end

  def adapter
    Adapters::RedisCacheAdapter
  end
end
