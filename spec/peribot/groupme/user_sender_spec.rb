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
      let(:message) { { 'group_id' => '1', 'text' => 'This is text!' } }

      it 'sends the message and stops processing' do
        expect(client).to receive(:create_message)
          .with('1', 'This is text!', [])
        expect(instance).to receive(:stop_processing)

        instance.process message
      end
    end

    context 'with a valid message with an attachment' do
      let(:message) do
        {
          'group_id' => '1',
          'text' => 'This is text!',
          'attachments' => [{ 'type' => 'image', 'url' => 'http://i.co/1.jpg' }]
        }
      end

      it 'sends the message and stops processing' do
        expect(client).to receive(:create_message)
          .with('1', 'This is text!', message['attachments'])
        expect(instance).to receive(:stop_processing)

        instance.process message
      end
    end

    shared_context 'invalid messages' do
      it 'returns the message for further processing' do
        expect(client).to_not receive(:create_message)
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a fully invalid message' do
      let(:message) { { 'test' => true } }
      include_context 'invalid messages'
    end

    context 'with a message missing a text parameter' do
      let(:message) { { 'group_id' => '1', 'test' => true } }
      include_context 'invalid messages'
    end

    context 'with a message missing a group_id parameter' do
      let(:message) { { 'text' => 'Message!', 'test' => true } }
      include_context 'invalid messages'
    end
  end
end
