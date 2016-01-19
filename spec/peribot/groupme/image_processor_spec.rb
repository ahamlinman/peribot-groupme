require 'spec_helper'
require 'webmock/rspec'
require 'json'

describe Peribot::GroupMe::ImageProcessor do
  let(:bot) { instance_double(Peribot::Bot) }
  let(:instance) { Peribot::GroupMe::ImageProcessor.new bot }
  let(:image) { File.new File.expand_path('../../fixtures/wow.jpg', __dir__) }
  let(:upload_result) do
    { 'payload' => { 'url' => 'http://i.groupme.com/123456789' } }
  end
  let(:reply) do
    params = [{
      'type' => 'image',
      'url' => 'http://i.groupme.com/123456789'
    }]
    message.merge('attachments' => params)
  end

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
          'text' => 'From a GroupMe URL!',
          'image' => 'http://i.groupme.com/123456789'
        }
      end

      it 'includes the URL as an image attachment' do
        expect(instance.process(message)).to eq(reply)
      end
    end

    context 'with a message containing a non-GroupMe image URL' do
      let(:message) do
        {
          'group_id' => '1',
          'text' => 'From an external URL!',
          'image' => 'http://pictures.com/wow.jpg'
        }
      end

      it 'includes the GroupMe URL as an image attachment' do
        stub_request(:post, 'https://image.groupme.com/pictures')
          .to_return(body: upload_result.to_json)

        stub_request(:get, 'http://pictures.com/wow.jpg')
          .to_return(status: 200, body: image)

        expect(instance.process(message)).to eq(reply)
      end
    end

    context 'with a message containing an image file' do
      let(:message) do
        {
          'group_id' => '1',
          'text' => 'From disk!',
          'image' => image
        }
      end

      it 'includes the GroupMe URL as an image attachment' do
        stub_request(:post, 'https://image.groupme.com/pictures')
          .to_return(body: upload_result.to_json)

        expect(instance.process(message)).to eq(reply)
      end
    end
  end
end
