require 'spec_helper'
require 'webmock/rspec'
require 'json'

describe Peribot::GroupMe::ImagePostprocessor do
  include_context 'standard doubles'

  let(:instance) { Peribot::GroupMe::ImagePostprocessor.new bot }
  let(:image) { File.new File.expand_path('../../fixtures/wow.jpg', __dir__) }
  let(:upload_result) do
    { 'payload' => { 'url' => 'http://i.groupme.com/123456789' } }
  end
  let(:reply) do
    params = [{
      kind: :image,
      image: 'http://i.groupme.com/123456789'
    }]
    message.merge(attachments: params)
  end

  before(:each) do
    bot.configure { groupme { token '' } }
  end

  describe '#process' do
    context 'with a message containing no image' do
      let(:message) { { service: :groupme, group: 'groupme/1', text: 'Test' } }

      it 'returns the message unchanged' do
        expect(instance.process(message)).to eq(message)
      end
    end

    context 'with a message containing a GroupMe image URL' do
      let(:message) do
        {
          service: :groupme,
          group: 'groupme/1',
          text: 'From a GroupMe URL!',
          attachments: [
            { kind: :image, image: 'http://i.groupme.com/123456789' }
          ]
        }
      end

      it 'includes the URL as an image attachment' do
        expect(instance.process(message)).to eq(reply)
      end
    end

    context 'with a message containing a non-GroupMe image URL' do
      let(:message) do
        {
          service: :groupme,
          group: 'groupme/1',
          text: 'From an external URL!',
          attachments: [{ kind: :image, image: 'http://pictures.com/wow.jpg' }]
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
          service: :groupme,
          group: 'groupme/1',
          text: 'From disk!',
          attachments: [{ kind: :image, image: image }]
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
