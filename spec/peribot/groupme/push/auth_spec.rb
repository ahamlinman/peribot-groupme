require 'spec_helper'

describe Peribot::GroupMe::Push::Auth do
  let(:token) { 'TEST_TOKEN' }
  let(:instance) { Peribot::GroupMe::Push::Auth.new token }
  let(:callback) { double }

  context 'when handling a subscribe message' do
    let(:message) do
      {
        'channel' => '/meta/subscribe',
        'clientId' => '1c5k4zq1mycffe161kgqp13gnvvn',
        'subscription' => '/user/123'
      }
    end
    let(:response) { message.merge('ext' => { 'access_token' => token }) }

    it 'includes the auth token in the message' do
      expect(callback).to receive(:call).with(response)
      instance.outgoing message, callback
    end
  end

  context 'when handling a non-subscribe message' do
    let(:message) do
      {
        'channel' => '/meta/handshake',
        'version' => '1.0'
      }
    end

    it 'returns the message unchanged' do
      expect(callback).to receive(:call).with(message)
      instance.outgoing message, callback
    end
  end
end
