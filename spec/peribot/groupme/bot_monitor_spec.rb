require 'spec_helper'
require 'shared_context/standard_doubles'
require 'shared_examples/monitor'

describe Peribot::GroupMe::BotMonitor do
  include_context 'standard doubles'

  it_behaves_like 'a monitor'

  describe '#execute' do
    let(:instance) { Peribot::GroupMe::BotMonitor.new bot, client }

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

    context 'when an exception is raised' do
      it 'logs the error using the bot' do
        allow(client).to receive(:groups).and_raise('test exception')
        expect(bot).to receive(:log)

        instance.execute
      end
    end
  end
end
