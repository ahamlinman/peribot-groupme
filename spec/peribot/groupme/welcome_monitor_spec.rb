require 'spec_helper'
require 'shared_context/monitors'
require 'shared_examples/monitor'

describe Peribot::GroupMe::WelcomeMonitor do
  include_context 'monitors'

  it_behaves_like 'a monitor'

  describe '#execute' do
    let(:known_groups) { %w(1 2) }
    let(:joined_groups) do
      [
        { 'group_id' => '1', 'name' => 'Sample', 'stuff' => rand },
        { 'group_id' => '2', 'name' => 'Another', 'stuff' => rand }
      ]
    end

    before(:each) do
      allow(client).to receive(:groups).and_return(joined_groups)
    end

    context 'with a new joined group' do
      let(:store) { Concurrent::Atom.new('known_groups' => known_groups[0..0]) }

      before(:each) do
        allow(bot).to receive(:store).with('groupme').and_return(store)
      end

      it 'sends a message to new groups' do
        expect(client).to receive(:create_message)
        instance.execute
      end

      it 'saves the new group' do
        allow(client).to receive(:create_message)

        instance.execute
        expect(store.value['known_groups']).to include('1', '2')
      end
    end

    context 'with no new joined groups' do
      let(:store) { Concurrent::Atom.new('known_groups' => known_groups[0..1]) }

      before(:each) do
        allow(bot).to receive(:store).with('groupme').and_return(store)
      end

      it 'does not send any messages' do
        expect(client).to_not receive(:create_message)
        instance.execute
      end
    end
  end
end
