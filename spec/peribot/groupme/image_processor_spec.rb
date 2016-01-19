require 'spec_helper'
require 'webmock/rspec'
require 'json'

describe Peribot::GroupMe::ImageProcessor do
  let(:bot) { instance_double(Peribot::Bot) }
  let(:instance) { Peribot::GroupMe::ImageProcessor.new bot }

  before(:each) do
    allow(bot).to receive(:config).and_return('groupme' => { 'token' => '' })
  end

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

    context 'with a message containing a non-GroupMe image URL' do
      let(:message) do
        {
          'group_id' => '1',
          'text' => 'Check this out!',
          'image' => 'http://pictures.com/wow.jpg'
        }
      end
      let(:reply) do
        params = [{
          'type' => 'image',
          'url' => 'http://i.groupme.com/123456789'
        }]
        message.merge('attachments' => params)
      end

      it 'includes the GroupMe URL as an image attachment' do
        body = { 'payload' => { 'url' => 'http://i.groupme.com/123456789' } }
        stub_request(:post, 'https://image.groupme.com/pictures')
          .to_return(body: body.to_json)

        image_path = File.expand_path('../../fixtures/wow.jpg', __dir__)
        stub_request(:get, 'http://pictures.com/wow.jpg')
          .to_return(status: 200, body: File.new(image_path))

        expect(instance.process(message)).to eq(reply)
      end
    end
  end
end
