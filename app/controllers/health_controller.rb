class HealthController < ApplicationController
  def show
    render plain: 'healthy'
  end

  def readiness
    if Adapters::RedisCacheAdapter.connection.ping
      render plain: 'ready'
    end
  end
end
