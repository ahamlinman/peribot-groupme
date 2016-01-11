require 'spec_helper'

describe Peribot::GroupMe do
  it 'has a version number' do
    expect(Peribot::GroupMe::VERSION).not_to be nil
  end

  describe '.register_into' do
    let(:bot) { instance_double(Peribot::Bot) }
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
  end
end
