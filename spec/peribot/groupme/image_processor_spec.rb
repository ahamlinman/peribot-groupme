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

    context 'with a message containing a GroupMe image URL' do
      let(:message) do
        {
          'group_id' => '1',
          'text' => 'Test',
          'image' => 'http://i.groupme.com/123456789'
        }
      end
      let(:reply) do
        params = [{
          'type' => 'image',
          'url' => 'http://i.groupme.com/123456789'
        }]
        message.merge('attachments' => params)
      end

      it 'includes the URL as an image attachment' do
        expect(instance.process(message)).to eq(reply)
      end
    end
  end
end
