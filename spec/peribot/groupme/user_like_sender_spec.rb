require 'spec_helper'
require 'shared_context/standard_doubles'

describe Peribot::GroupMe::UserLikeSender do
  include_context 'standard doubles'
  let(:instance) { Peribot::GroupMe::UserLikeSender.new bot }

  describe '#initialize' do
    it 'takes a bot as a paramter' do
      expect(instance).to be_instance_of(Peribot::GroupMe::UserLikeSender)
    end
  end

  describe '#process' do
    before(:each) do
      allow(GroupMe::Client).to receive(:new)
        .with(token: 'TEST').and_return(client)
    end

    context 'with a like message' do
      let(:message) do
        {
          service: :groupme,
          group: 'groupme/1',
          attachments: [{ kind: :like, message_id: '1234' }]
        }
      end

      it 'likes the message and stops processing' do
        expect(client).to receive(:create_like).with('1', '1234')
        expect(instance).to receive(:stop_processing)

        instance.process message
      end
    end

    shared_context 'invalid message' do
      it 'returns the message for further processing' do
        expect(client).to_not receive(:create_like)
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a text message' do
      let(:message) do
        { service: :groupme, group: 'groupme/1', text: 'Should not respond' }
      end
      include_context 'invalid message'
    end

    context 'with a message missing a like attachment' do
      let(:message) { { service: :groupme, group: 'groupme/1' } }
      include_context 'invalid message'
    end

    context 'with a message missing a group_id parameter' do
      let(:message) do
        {
          service: :groupme,
          attachments: [{ kind: :like, message_id: '1234' }]
        }
      end
      include_context 'invalid message'
    end
  end
end
