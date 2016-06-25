require 'spec_helper'
require 'shared_context/standard_doubles'

describe Peribot::GroupMe do
  include_context 'standard doubles'

  it 'has a version number' do
    expect(Peribot::GroupMe::VERSION).not_to be nil
  end

  describe '.register_into' do
    it 'defines a push starter method on the bot instance' do
      expect(Peribot::GroupMe::Push).to receive(:start!)
      Peribot::GroupMe.register_into bot
      bot.start_groupme_push!
    end

    it 'does not define a push starter when requested not to' do
      Peribot::GroupMe.register_into bot, starter: false
      expect(bot).not_to respond_to(:start_groupme_push!)
    end

    context 'when sending as a bot' do
      it 'registers bot components' do
        expect(bot.postprocessor).to receive(:register)
          .with(Peribot::GroupMe::ImageProcessor)

        expect(bot.sender).to receive(:register)
          .with(Peribot::GroupMe::BotSender)

        Peribot::GroupMe.register_into bot
      end
    end

    context 'when sending as a user' do
      it 'registers user components' do
        expect(bot.postprocessor).to receive(:register)
          .with(Peribot::GroupMe::ImageProcessor)

        expect(bot.sender).to receive(:register)
          .with(Peribot::GroupMe::UserSender)
        expect(bot.sender).to receive(:register)
          .with(Peribot::GroupMe::UserLikeSender)

        Peribot::GroupMe.register_into bot, send_as: :user
      end
    end
  end
end
