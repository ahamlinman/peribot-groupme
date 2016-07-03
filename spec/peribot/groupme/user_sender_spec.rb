require 'spec_helper'
require 'shared_context/standard_doubles'

describe Peribot::GroupMe::UserSender do
  include_context 'standard doubles'
  let(:instance) { Peribot::GroupMe::UserSender.new bot }

  describe '#initialize' do
    it 'takes a bot and initializes a GroupMe client' do
      expect(GroupMe::Client).to receive(:new).with(token: 'TEST')
      expect(instance).to be_instance_of(Peribot::GroupMe::UserSender)
    end
  end

  describe '#process' do
    before(:each) { allow(GroupMe::Client).to receive(:new).and_return(client) }

    context 'with a valid message with no attachment' do
      let(:message) do
        { service: :groupme, group: 'groupme/1', text: 'This is text!' }
      end

      it 'sends the message and continues processing' do
        expect(client).to receive(:create_message)
          .with('1', 'This is text!', [])
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a message with empty text' do
      let(:message) do
        { service: :groupme, group: 'groupme/1', text: '' }
      end

      it 'does not send the message and continues processing' do
        expect(client).to_not receive(:create_message)
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a valid message with an attachment' do
      let(:message) do
        {
          service: :groupme,
          group: 'groupme/1',
          text: 'This is text!',
          attachments: [{ kind: :image, image: 'http://i.co/1.jpg' }]
        }
      end

      it 'sends the message and continues processing' do
        attachments = [{ 'type' => 'image', 'url' => 'http://i.co/1.jpg' }]
        expect(client).to receive(:create_message)
          .with('1', 'This is text!', attachments)
        expect(instance.process(message)).to eq(message)
      end
    end

    shared_context 'invalid message' do
      it 'returns the message for further processing' do
        expect(client).to_not receive(:create_message)
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a fully invalid message' do
      let(:message) { { test: true } }
      include_context 'invalid message'
    end

    context 'with a message missing a text parameter' do
      let(:message) { { service: :groupme, group: 'groupme/1' } }
      include_context 'invalid message'
    end

    context 'with a message missing a group parameter' do
      let(:message) { { service: :groupme, text: 'Message!' } }
      include_context 'invalid message'
    end

    context 'with a message missing a service parameter' do
      let(:message) { { group: 'groupme/1', text: 'Message!' } }
      include_context 'invalid message'
    end
  end
end
