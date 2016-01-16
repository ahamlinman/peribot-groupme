require 'spec_helper'
require 'shared_context/standard_doubles'

describe Peribot::GroupMe::Sender do
  include_context 'standard doubles'
  let(:instance) { Peribot::GroupMe::Sender.new bot }

  describe '#initialize' do
    it 'takes a bot as a parameter' do
      expect(instance).to be_instance_of(Peribot::GroupMe::Sender)
    end
  end

  describe '#process' do
    before(:each) { allow(GroupMe::Client).to receive(:new).and_return(client) }

    context 'with a valid message' do
      let(:message) { { 'group_id' => '1', 'text' => 'This is text!' } }

      it 'sends the message and stops processing' do
        expect(client).to receive(:create_message)
        expect(instance).to receive(:stop_processing)

        instance.process message
      end
    end

    context 'with an invalid message' do
      let(:message) { { 'test' => true } }

      it 'returns the message for further processing' do
        expect(client).to_not receive(:create_message)
        expect(instance.process(message)).to eq(message)
      end
    end
  end
end
