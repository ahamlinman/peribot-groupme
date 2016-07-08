require 'spec_helper'
require 'shared_context/standard_doubles'

describe Peribot::GroupMe::BotFilterPreprocessor do
  include_context 'standard doubles'

  let(:instance) { Peribot::GroupMe::BotFilterPreprocessor.new bot }

  describe '.register_into' do
    it 'registers the preprocessor into the correct chain' do
      bot.use described_class
      expect(bot.preprocessor.tasks).to include(described_class)
    end
  end

  describe '#process' do
    let(:bot_config) do
      {
        'groupme' => {
          'token' => 'TEST',
          'bot_map' => { '1' => '1abc' }
        }
      }
    end

    before(:each) do
      bot.configure bot_config
    end

    context 'with a message not from GroupMe' do
      let(:message) { { service: :msgr, group: 'msgr/1', text: 'Test' } }

      it 'passes the message through' do
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a message from a group we can respond to' do
      let(:message) { { service: :groupme, group: 'groupme/1', text: 'Test' } }

      it 'passes the message through' do
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a message from a group we cannot respond to' do
      let(:message) { { service: :groupme, group: 'groupme/2', text: 'Test' } }

      it 'drops the message' do
        expect(instance.process(message)).to be_nil
      end
    end
  end
end
