require 'spec_helper'

shared_context 'monitors' do
  let(:instance) { described_class.new bot, client }
  let(:bot) { instance_double(Peribot::Bot) }
  let(:client) { instance_double(GroupMe::Client) }
  let(:config) do
    {
      'groupme' => { 'token' => 'TEST',
                     'bots' => { 'name' => 'Robot',
                                 'callback' => 'http://callback' },
                     'welcome' => 'This is a welcome message'
                   }
    }
  end

  before(:each) { allow(bot).to receive(:config).and_return(config) }
end
