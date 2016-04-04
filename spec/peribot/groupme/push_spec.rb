require 'spec_helper'
require 'shared_context/standard_doubles'

describe Peribot::GroupMe::Push do
  include_context 'standard doubles'

  describe '.start!' do
    before(:each) do
      allow(GroupMe::Client).to receive(:new).and_return(client)
      allow(client).to receive(:me).and_return('id' => '123', 'name' => 'Test')

      allow(Faye::Client).to receive(:new).and_return(faye_client)
      allow(faye_client).to receive(:add_extension)

      allow(EventMachine).to receive(:run).and_yield
    end

    let(:faye_client) { double }

    it 'subscribes to the user channel' do
      expect(faye_client).to receive(:subscribe).with('/user/123')
      Peribot::GroupMe::Push.start! bot
    end

    context 'when a message is received' do
      let(:message) do
        {
          'alert' => 'Tester: This is only a test.',
          'subject' => { 'group_id' => '1', 'text' => 'Hi!' },
          'type' => 'line.create'
        }
      end

      it 'sends GroupMe messages to the bot' do
        allow(faye_client).to receive(:subscribe).and_yield(message)
        expect(bot).to receive(:accept).with('group_id' => '1',
                                             'text' => 'Hi!')

        Peribot::GroupMe::Push.start! bot
      end
    end

    context 'when a GroupMe status message is received' do
      let(:message) do
        {
          'alert' => 'You have been added to a group.',
          'type' => 'membership.create'
        }
      end

      it 'does not send anything to the bot' do
        allow(faye_client).to receive(:subscribe).and_yield(message)
        expect(bot).to_not receive(:accept)

        Peribot::GroupMe::Push.start! bot
      end
    end
  end
end
