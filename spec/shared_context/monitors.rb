require 'spec_helper'

shared_context 'monitors' do
  let(:instance) { described_class.new bot, client }
  let(:bot) { instance_double(Peribot::Bot) }
  let(:client) { instance_double(GroupMe::Client) }
  let(:config) do
    {
      'groupme' => { 'token' => 'TEST',
                     'bots' => { 'name' => 'Robot',
                                 'callback' => 'http://callback' } }
    }
  end
end
