require 'rails_helper'

describe Adapters::ShellAdapter do
  let(:token) { SecureRandom.uuid }
  let(:message) do
    "failing cmd: /some/path/kubectl get configmaps -o jsonpath='{.data.PATRICK_STAR}' fb-spongebob-config-map --namespace=formbuilder-spongebob --token=#{token} --ignore-not-found=true"
  end

  describe '.exec' do
    before do
      allow(
        Kernel
      ).to receive(:system).with('which kubectl').and_return(result)
    end

    context 'when successful' do
      let(:result) { 'foobar' }

      it 'does not raise any error' do
        expect(described_class.exec(%w[which kubectl])).to be_nil
      end
    end

    context 'when failed' do
      let(:result) { nil }

      it 'raises an exception' do
        expect {
          described_class.exec(%w[which kubectl])
        }.to raise_error(CmdFailedError, /failing cmd: which kubectl/)
      end
    end
  end

  describe '.output_of' do
    let(:result) { ['foobar', double(success?: success)] }

    before do
      allow(
        Open3
      ).to receive(:capture2).with('which kubectl', stdin_data: nil).and_return(result)
    end

    context 'when successful' do
      let(:success) { true }

      it 'builds the command and captures it' do
        expect(described_class.output_of(%w[which kubectl])).to eq('foobar')
      end
    end

    context 'when failed' do
      let(:success) { false }

      it 'raises an exception' do
        expect {
          described_class.output_of(%w[which kubectl])
        }.to raise_error(CmdFailedError, /failing cmd: which kubectl/)
      end
    end
  end

  describe '.redact_token' do
    context 'when a message needs redacting' do
      it 'should remove the token from the message' do
        expect(described_class.redact_token(message)).not_to include(token)
      end
    end
  end
end
