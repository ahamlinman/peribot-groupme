require 'spec_helper'
require 'shared_context/standard_doubles'

describe Peribot::GroupMe::BotSender do
  include_context 'standard doubles'

  let(:instance) { Peribot::GroupMe::BotSender.new bot }
  let(:message) { { service: :groupme, group: 'groupme/1', text: 'Test' } }

  describe '#initialize' do
    it 'takes a bot and initializes a GroupMe client' do
      expect(::GroupMe::Client).to receive(:new).with(token: 'TEST')
      expect(instance).to be_instance_of(Peribot::GroupMe::BotSender)
    end
  end

  describe '#process' do
    before(:each) do
      bot.configure bot_config
      allow(::GroupMe::Client).to receive(:new).and_return(client)
    end

    context 'with explicit bot mappings defined' do
      let(:bot_config) do
        {
          'groupme' => {
            'token' => 'TOKEN',
            'bot_map' => { '1' => '1abc' }
          }
        }
      end

      it 'sends messages using the bot mapped to the group' do
        expect(client).to receive(:bot_post).with('1abc', 'Test', {})
        expect(instance.process(message)).to eq(message)
      end
    end

    shared_context 'auto mapping' do
      let(:bot_response) { [{ 'bot_id' => '1abc', 'group_id' => '1' }] }
      before(:each) do
        allow(client).to receive(:bots).and_return(bot_response)
      end

      it 'sends messages using the bot in the group' do
        expect(client).to receive(:bot_post).with('1abc', 'Test', {})
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with auto bot mapping explicitly enabled' do
      let(:bot_config) do
        {
          'groupme' => {
            'token' => 'TOKEN',
            'bot_map' => 'auto'
          }
        }
      end

      include_context 'auto mapping'
    end

    context 'with auto bot mapping implicitly enabled' do
      let(:bot_config) do
        {
          'groupme' => {
            'token' => 'TOKEN'
          }
        }
      end

      include_context 'auto mapping'
    end

    context 'with no bot associated with the group' do
      let(:bot_config) do
        {
          'groupme' => {
            'token' => 'TOKEN',
            'bot_map' => {}
          }
        }
      end

      it 'passes the message on' do
        expect(client).to_not receive(:bot_post)
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a message containing an image' do
      let(:bot_config) do
        {
          'groupme' => {
            'token' => 'TOKEN',
            'bot_map' => { '1' => '1abc' }
          }
        }
      end
      let(:message) do
        {
          service: :groupme,
          group: 'groupme/1',
          text: 'Test',
          attachments: [{ kind: :image, image: 'http://pic/i.jpg' }]
        }
      end

      it 'includes the image URL in the message' do
        options = { picture_url: 'http://pic/i.jpg' }
        expect(client).to receive(:bot_post).with('1abc', 'Test', options)
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a message with empty text and no attachment' do
      let(:bot_config) do
        {
          'groupme' => {
            'token' => 'TOKEN',
            'bot_map' => { '1' => '1abc' }
          }
        }
      end
      let(:message) { { service: :groupme, group: 'groupme/1', text: '' } }

      it 'does not send the message' do
        expect(client).to_not receive(:bot_post)
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a message with empty text and an image' do
      let(:bot_config) do
        {
          'groupme' => {
            'token' => 'TOKEN',
            'bot_map' => { '1' => '1abc' }
          }
        }
      end
      let(:message) do
        {
          service: :groupme,
          group: 'groupme/1',
          attachments: [{ kind: :image, image: 'http://pic/i.jpg' }]
        }
      end

      it 'includes the image URL in the message' do
        options = { picture_url: 'http://pic/i.jpg' }
        expect(client).to receive(:bot_post).with('1abc', '', options)
        expect(instance.process(message)).to eq(message)
      end
    end
  end
end
