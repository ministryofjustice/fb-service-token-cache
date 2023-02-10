require 'rails_helper'

RSpec.describe ServiceTokenV2Controller do
  describe '#show' do
    let(:params) { { service_slug: 'test-service' } }

    it 'returns public key' do
      allow(Support::ServiceTokenAuthoritativeSource).to receive(:get_public_key).and_return('v2-public-key')

      get :show, params: params
      expect(response).to be_successful
      expect(JSON.parse(response.body)['token']).to eql('v2-public-key')
    end

    context 'when service does not exist' do
      it 'returns 404' do
        allow(Support::ServiceTokenAuthoritativeSource).to receive(:get_public_key).and_return('')

        get :show, params: params
        expect(response).to be_not_found
      end
    end

    context 'when IGNORE_CACHE is set' do
      before do
        allow(ENV).to receive(:[])
        allow(ENV).to receive(:[]).with('IGNORE_CACHE').and_return('true')
        allow(Support::ServiceTokenAuthoritativeSource).to receive(:get_public_key).and_return('v2-public-key')
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
        allow(Support::ServiceTokenAuthoritativeSource).to receive(:get_public_key).and_return('v2-public-key')
        get :show, params: params.merge(ignore_cache: 'true')
      end

      it 'should return the public key without using the redis cache' do
        expect(response).to be_successful
        expect(ENV).not_to receive(:[]).with('IGNORE_CACHE')
      end
    end
  end
end
