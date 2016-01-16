require 'spec_helper'

describe Peribot::GroupMe::ImageProcessor do
  let(:bot) { instance_double(Peribot::Bot) }
  let(:instance) { Peribot::GroupMe::ImageProcessor.new bot }

  describe '#process' do
    context 'with a message containing no image' do
      let(:message) { { 'group_id' => '1', 'text' => 'Test' } }

      it 'returns the message unchanged' do
        expect(instance.process(message)).to eq(message)
      end
    end
  end
end
