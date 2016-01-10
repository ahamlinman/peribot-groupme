require 'spec_helper'

describe Peribot::GroupMe::BotMonitor do
  subject { Peribot::GroupMe::BotMonitor }

  let(:bot) { instance_double(Peribot::Bot) }
  let(:client) { instance_double(GroupMe::Client) }
  let(:monitor) { Peribot::GroupMe::BotMonitor.new bot, client }

  let(:config) do
    {
      'groupme' => { 'token' => 'TEST',
                     'bots' => { 'name' => 'Robot',
                                 'callback' => 'http://callback' } }
    }
  end

  let(:group_list) do
    [
      { 'group_id' => '1', 'name' => 'Sample', 'stuff' => rand },
      { 'group_id' => '2', 'name' => 'Another', 'stuff' => rand }
    ]
  end

  describe '.start' do
    let(:task_double) { instance_double(Concurrent::TimerTask) }
    it 'creates and executes a timer task' do
      expect(subject).to receive(:from_bot).with(bot).and_return(monitor)
      expect(monitor).to receive(:execute)
      expect(Concurrent::TimerTask).to receive(:new).and_yield
        .and_return(task_double)
      expect(task_double).to receive(:execute)

      subject.start bot
    end

    it 'passes keyword arguments to TimerTask' do
      expect(Concurrent::TimerTask).to receive(:new).with(test: true)
        .and_return(task_double)
      allow(task_double).to receive(:execute)

      subject.start bot, test: true
    end
  end

  describe '.from_bot' do
    it 'creates a monitor from the bot configuration' do
      expect(bot).to receive(:config).and_return(config)
      expect(GroupMe::Client).to receive(:new).with(token: 'TEST')
        .and_return(client)
      expect(subject).to receive(:new).with(bot, client)

      subject.from_bot bot
    end
  end

  describe '#execute' do
    before(:each) do
      allow(bot).to receive(:config).and_return(config)
      allow(client).to receive(:groups).and_return(group_list)
    end

    context 'when a group has no bot' do
      let(:bot_list) { [{ 'bot_id' => '1b', 'group_id' => '1' }] }

      it 'registers one' do
        allow(client).to receive(:bots).and_return(bot_list)
        expect(client).to receive(:create_bot)

        subject.new(bot, client).execute
      end
    end

    context 'when all groups have bots' do
      let(:bot_list) do
        [
          { 'bot_id' => '1b', 'group_id' => '1' },
          { 'bot_id' => '2b', 'group_id' => '2' }
        ]
      end

      it 'does not register any' do
        allow(client).to receive(:bots).and_return(bot_list)
        expect(client).to_not receive(:create_bot)

        subject.new(bot, client).execute
      end
    end
  end
end
