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

    it 'registers tasks' do
      expect(bot.postprocessor).to receive(:register)
        .with(Peribot::GroupMe::ImageProcessor)

      expect(bot.sender).to receive(:register).with(Peribot::GroupMe::Sender)
      expect(bot.sender).to receive(:register)
        .with(Peribot::GroupMe::LikeSender)

      Peribot::GroupMe.register_into bot
    end
  end
end
