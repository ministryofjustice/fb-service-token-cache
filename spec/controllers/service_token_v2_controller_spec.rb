require 'rails_helper'

RSpec.describe ServiceTokenV2Controller do
  describe '#show' do
    it 'returns public key' do
      allow(Support::ServiceTokenAuthoritativeSource).to receive(:get_public_key).and_return('v2-public-key')

      get :show, params: { service_slug: 'test-service' }
      expect(response).to be_successful
      expect(JSON.parse(response.body)['token']).to eql('v2-public-key')
    end

    context 'when service does not exist' do
      it 'returns 404' do
        allow(Support::ServiceTokenAuthoritativeSource).to receive(:get_public_key).and_return('')

        get :show, params: { service_slug: 'test-service' }
        expect(response).to be_not_found
      end
    end

    context 'when IGNORE_CACHE is set' do
      before do
        ENV.stub(:[])
        ENV.stub(:[]).with('IGNORE_CACHE').and_return('true')
        allow(Support::ServiceTokenAuthoritativeSource).to receive(:get_public_key).and_return('v2-public-key')
        get :show, params: { service_slug: 'test-service' }
      end

      it 'should return the public key without using the redis cache' do
        expect(response).to be_successful
        expect(Adapters::RedisCacheAdapter).not_to receive(:get)
        expect(Adapters::RedisCacheAdapter).not_to receive(:put)
      end
    end
  end
end
