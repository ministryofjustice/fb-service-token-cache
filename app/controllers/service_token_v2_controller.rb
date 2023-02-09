class ServiceTokenV2Controller < ApplicationController
  def show
    service = PublicKeyService.new({service_slug: params[:service_slug], ignore_cache: ignore_cache})
    public_key = service.call

    if public_key.present?
      render json: { token: public_key }, status: 200
    else
      head :not_found
    end
  end
end
