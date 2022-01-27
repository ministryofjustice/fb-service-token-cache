Rails.application.routes.draw do
  get '/health', to: 'health#show' # used for liveness probe
  get '/readiness', to: 'health#readiness'
  get '/service/v2/:service_slug', to: 'service_token_v2#show'
  get '/v3/applications/:service_slug/namespaces/:namespace', to: 'service_token_v3#show'
end
