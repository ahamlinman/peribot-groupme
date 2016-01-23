require 'spec_helper'

describe Peribot::GroupMe::BotSender do
  let(:instance) { Peribot::GroupMe::BotSender.new bot }
  let(:bot) { instance_double(Peribot::Bot) }
  let(:bot_cache) do
    Concurrent::Map.new { |m, k| m[k] = Concurrent::Atom.new({}) }
  end
  let(:message) { { 'group_id' => '1', 'text' => 'Test' } }
  let(:groupme) { instance_double(::GroupMe::Client) }
  let(:chain_stop) { Peribot::ProcessorChain::Stop }

  before(:each) do
    allow(bot).to receive(:config).and_return(bot_config)
    allow(bot).to receive(:cache).and_return(bot_cache)
    allow(::GroupMe::Client).to receive(:new).and_return(groupme)
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
      expect(groupme).to receive(:bot_post).with('1abc', 'Test', {})
      expect { instance.process message }.to raise_error(chain_stop)
    end
  end

  shared_context 'auto mapping' do
    let(:bot_response) { [{ 'bot_id' => '1abc', 'group_id' => '1' }] }
    before(:each) { allow(groupme).to receive(:bots).and_return(bot_response) }

    it 'sends messages using the bot in the group' do
      expect(groupme).to receive(:bot_post).with('1abc', 'Test', {})
      expect { instance.process message }.to raise_error(chain_stop)
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
      expect(groupme).to_not receive(:bot_post)
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
        'group_id' => '1',
        'text' => 'Test',
        'attachments' => [{ 'type' => 'image', 'url' => 'http://pic/i.jpg' }]
      }
    end

    it 'includes the image URL in the message' do
      options = { picture_url: 'http://pic/i.jpg' }
      expect(groupme).to receive(:bot_post).with('1abc', 'Test', options)
      expect { instance.process message }.to raise_error(chain_stop)
    end
  end
end