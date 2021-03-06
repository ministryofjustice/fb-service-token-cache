require 'rails_helper'

describe Adapters::KubectlAdapter do
  let(:service_slug) { 'my-service-slug' }
  let(:namespace) { 'my-namespace' }

  before do
    allow(Adapters::ShellAdapter).to receive(:output_of).and_return('some output')
  end

  subject do
    described_class.new(service_slug: service_slug, namespace: namespace)
  end

  describe '#get_public_key' do
    context 'when code injection' do
      context 'with dangerous service_slug' do
        let(:service_slug) { '; curl https://example.com;' }
        let(:namespace) { 'some-namespace' }

        subject do
          described_class.new(service_slug: service_slug, namespace: namespace)
        end

        it 'raises an error' do
          expect do
            subject.get_public_key
          end.to raise_error(ArgumentError)
        end
      end

      context 'with dangerous namespace' do
        let(:service_slug) { 'some-namespace' }
        let(:namespace) { '; curl https://example.com;' }

        subject do
          described_class.new(service_slug: service_slug, namespace: namespace)
        end

        it 'raises an error' do
          expect do
            subject.get_public_key
          end.to raise_error(ArgumentError)
        end
      end
    end

    context 'when a CmdFailedError is raised' do
      subject do
        described_class.new(service_slug: 'some-secret', namespace: 'some-namespace')
      end

      it 'should rescue and return empty string' do
        allow(Adapters::ShellAdapter).to receive(:output_of).and_raise(CmdFailedError)

        expect(subject.get_public_key).to eq('')
      end
    end
  end
end
