require 'spec_helper'
require 'shared_context/standard_doubles'

describe Peribot::GroupMe::LikeSender do
  include_context 'standard doubles'
  let(:instance) { Peribot::GroupMe::LikeSender.new bot }

  describe '#initialize' do
    it 'takes a bot as a paramter' do
      expect(instance).to be_instance_of(Peribot::GroupMe::LikeSender)
    end
  end

  describe '#process' do
    before(:each) { allow(GroupMe::Client).to receive(:new).and_return(client) }

    context 'with a like message' do
      let(:message) { { 'group_id' => '1', 'like' => '1234' } }

      it 'likes the message and stops processing' do
        expect(client).to receive(:create_like).with('1', '1234')
        expect(instance).to receive(:stop_processing)

        instance.process message
      end
    end

    context 'with a text message' do
      let(:message) { { 'group_id' => '1', 'text' => 'Should not respond' } }

      it 'returns the message for further processing' do
        expect(client).to_not receive(:create_like)
        expect(instance.process(message)).to eq(message)
      end
    end
  end
end
