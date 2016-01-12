require 'spec_helper'
require 'shared_context/standard_doubles'

shared_examples 'a monitor' do
  include_context 'standard doubles'
  let(:instance) { described_class.new bot, client }

  describe '.start' do
    let(:task_double) { instance_double(Concurrent::TimerTask) }

    it 'creates and executes a timer task' do
      allow(described_class).to receive(:new).with(bot, client)
        .and_return(instance)
      allow(instance).to receive(:execute)

      expect(Concurrent::TimerTask).to receive(:new).and_yield
        .and_return(task_double)
      expect(task_double).to receive(:execute)

      described_class.start bot, client
    end

    it 'passes keyword arguments to TimerTask' do
      allow(task_double).to receive(:execute)

      expect(Concurrent::TimerTask).to receive(:new).with(test: true)
        .and_return(task_double)

      described_class.start bot, client, test: true
    end
  end
end
