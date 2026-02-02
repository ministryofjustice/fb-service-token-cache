class HealthController < ApplicationController
  # :nocov:
  def show
    render plain: 'healthy'
  end

  def readiness
    if Adapters::RedisCacheAdapter.connection.ping
      render plain: 'ready'
    end
  end
  # :nocov:
end
