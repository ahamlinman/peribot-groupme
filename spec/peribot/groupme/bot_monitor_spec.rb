require 'spec_helper'

describe Peribot::GroupMe::BotMonitor do
  let(:instance) { Peribot::GroupMe::BotMonitor.new bot, client }
  let(:bot) { instance_double(Peribot::Bot) }
  let(:client) { instance_double(GroupMe::Client) }

  let(:config) do
    {
      'groupme' => { 'token' => 'TEST',
                     'bots' => { 'name' => 'Robot',
                                 'callback' => 'http://callback' } }
    }
  end

  describe '.start' do
    let(:task_double) { instance_double(Concurrent::TimerTask) }

    it 'creates and executes a timer task' do
      allow(Peribot::GroupMe::BotMonitor).to receive(:from_bot).with(bot)
        .and_return(instance)
      allow(instance).to receive(:execute)

      expect(Concurrent::TimerTask).to receive(:new).and_yield
        .and_return(task_double)
      expect(task_double).to receive(:execute)

      Peribot::GroupMe::BotMonitor.start bot
    end

    it 'passes keyword arguments to TimerTask' do
      allow(task_double).to receive(:execute)

      expect(Concurrent::TimerTask).to receive(:new).with(test: true)
        .and_return(task_double)

      Peribot::GroupMe::BotMonitor.start bot, test: true
    end
  end

  describe '.from_bot' do
    it 'creates a monitor from the bot configuration' do
      allow(bot).to receive(:config).and_return(config)
      allow(GroupMe::Client).to receive(:new).with(token: 'TEST')
        .and_return(client)

      expect(Peribot::GroupMe::BotMonitor).to receive(:new).with(bot, client)

      Peribot::GroupMe::BotMonitor.from_bot bot
    end
  end

  describe '#execute' do
    let(:group_list) do
      [
        { 'group_id' => '1', 'name' => 'Sample', 'stuff' => rand },
        { 'group_id' => '2', 'name' => 'Another', 'stuff' => rand }
      ]
    end

    let(:bot_list) do
      [
        { 'bot_id' => '1b', 'group_id' => '1' },
        { 'bot_id' => '2b', 'group_id' => '2' }
      ]
    end

    before(:each) do
      allow(bot).to receive(:config).and_return(config)
      allow(client).to receive(:groups).and_return(group_list)
    end

    context 'when a group has no bot' do
      it 'registers one' do
        allow(client).to receive(:bots).and_return(bot_list[0..0])
        expect(client).to receive(:create_bot)

        instance.execute
      end
    end

    context 'when all groups have bots' do
      it 'does not register any' do
        allow(client).to receive(:bots).and_return(bot_list[0..1])
        expect(client).to_not receive(:create_bot)

        instance.execute
      end
    end
  end
end
