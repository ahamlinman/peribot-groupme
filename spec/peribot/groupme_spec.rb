require 'spec_helper'
require 'shared_context/standard_doubles'

describe Peribot::GroupMe do
  include_context 'standard doubles'

  it 'has a version number' do
    expect(Peribot::GroupMe::VERSION).not_to be nil
  end

  describe '.register_into' do
    let(:chain) { instance_double(Peribot::Middleware::Chain) }

    before(:each) do
      allow(bot).to receive(:sender).and_return(chain)
    end

    it 'registers tasks and starts monitors' do
      expect(bot.sender).to receive(:register).with(Peribot::GroupMe::Sender)
      expect(bot.sender).to receive(:register)
        .with(Peribot::GroupMe::LikeSender)

      expect(Peribot::GroupMe::BotMonitor).to receive(:start)
      expect(Peribot::GroupMe::WelcomeMonitor).to receive(:start)

      Peribot::GroupMe.register_into bot
    end

    it 'allows monitors not to be started' do
      expect(bot.sender).to receive(:register).with(Peribot::GroupMe::Sender)
      expect(bot.sender).to receive(:register)
        .with(Peribot::GroupMe::LikeSender)

      expect(Peribot::GroupMe::BotMonitor).to_not receive(:start)
      expect(Peribot::GroupMe::WelcomeMonitor).to_not receive(:start)

      Peribot::GroupMe.register_into bot, with_monitors: false
    end

    it 'raises an error when the bot is not configured' do
      allow(bot).to receive(:config).and_return(nil)

      allow(bot.sender).to receive(:register)
      allow(Peribot::GroupMe::BotMonitor).to receive(:start)
      allow(Peribot::GroupMe::WelcomeMonitor).to receive(:start)

      msg = 'could not obtain GroupMe token (does groupme.conf exist?)'
      expect { Peribot::GroupMe.register_into bot }.to raise_error(msg)
    end
  end
end
