require 'rails_helper'

RSpec.describe ServiceTokenV2Controller do
  let(:kubectl_adapter) { instance_double(Adapters::KubectlAdapter, get_public_key: public_key) }
  let(:public_key) { 'v2-public-key' }

  let(:service_slug) { 'test-service' }
  let(:namespace) { nil }

  before do
    allow(
      Adapters::KubectlAdapter
    ).to receive(:new).with(service_slug:, namespace:).and_return(kubectl_adapter)
  end

  describe '#show' do
    let(:params) { { service_slug: } }

    it 'returns public key' do
      get :show, params: params
      expect(response).to be_successful
      expect(JSON.parse(response.body)['token']).to eql(public_key)
    end

    context 'when service does not exist' do
      let(:public_key) { '' }

      it 'returns 404' do
        get :show, params: params
        expect(response).to be_not_found
      end
    end

    context 'when IGNORE_CACHE is set' do
      before do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('IGNORE_CACHE').and_return('true')
        get :show, params: params
      end

      it 'should return the public key without using the redis cache' do
        expect(response).to be_successful
        expect(Adapters::RedisCacheAdapter).not_to receive(:get)
        expect(Adapters::RedisCacheAdapter).not_to receive(:put)
      end
    end

    context 'when ignore_cache query param is present' do
      before do
        get :show, params: params.merge(ignore_cache: 'true')
      end

      it 'should return the public key without using the redis cache' do
        expect(response).to be_successful
        expect(ENV).not_to receive(:[]).with('IGNORE_CACHE')
      end
    end
  end
end
