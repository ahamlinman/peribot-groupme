require 'spec_helper'
require 'shared_context/standard_doubles'

describe Peribot::GroupMe do
  include_context 'standard doubles'

  it 'has a version number' do
    expect(Peribot::GroupMe::VERSION).not_to be nil
  end

  describe '.register_into' do
    let(:postprocessor) { instance_double(Peribot::ProcessorChain) }
    let(:sender) { instance_double(Peribot::ProcessorChain) }

    before(:each) do
      allow(bot).to receive(:postprocessor).and_return(postprocessor)
      allow(bot).to receive(:sender).and_return(sender)
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
