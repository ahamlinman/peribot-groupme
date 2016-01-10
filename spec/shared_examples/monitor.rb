require 'spec_helper'
require 'shared_context/monitors'

shared_examples 'a monitor' do
  include_context 'monitors'

  describe '.start' do
    let(:task_double) { instance_double(Concurrent::TimerTask) }

    it 'creates and executes a timer task' do
      expect(described_class).to receive(:from_bot).with(bot)
        .and_return(instance)
      allow(instance).to receive(:execute)

      expect(Concurrent::TimerTask).to receive(:new).and_yield
        .and_return(task_double)
      expect(task_double).to receive(:execute)

      described_class.start bot
    end

    it 'passes keyword arguments to TimerTask' do
      allow(task_double).to receive(:execute)

      expect(Concurrent::TimerTask).to receive(:new).with(test: true)
        .and_return(task_double)

      described_class.start bot, test: true
    end
  end

  describe '.from_bot' do
    it 'creates a monitor from the bot configuration' do
      allow(GroupMe::Client).to receive(:new).with(token: 'TEST')
        .and_return(client)

      expect(described_class).to receive(:new).with(bot, client)

      described_class.from_bot bot
    end
  end
end
