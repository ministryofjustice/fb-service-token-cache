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
      it 'should rescue and return empty string' do
        allow(Adapters::ShellAdapter).to receive(:output_of).and_raise(CmdFailedError)

        expect(subject.get_public_key).to eq('')
      end
    end

    context 'when all is fine' do
      before do
        allow(
          Adapters::ShellAdapter
        ).to receive(:output_of).with('which kubectl').once.and_return('/usr/local/bin/kubectl')
      end

      it 'sends the command to the shell adapter' do
        command = [
          "/usr/local/bin/kubectl",
          "get", "configmaps",
          "-o", "jsonpath='{.data.ENCODED_PUBLIC_KEY}'", "fb-my-service-slug-config-map",
          "--namespace=my-namespace --ignore-not-found=true"
        ]

        expect(Adapters::ShellAdapter).to receive(:output_of).with(command)

        subject.get_public_key
      end
    end
  end
end
