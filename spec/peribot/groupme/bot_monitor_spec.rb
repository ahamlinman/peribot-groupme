require 'spec_helper'
require 'shared_context/monitors'
require 'shared_examples/monitor'

describe Peribot::GroupMe::BotMonitor do
  include_context 'monitors'

  it_behaves_like 'a monitor'

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
