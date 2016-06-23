# frozen_string_literal: true

require 'uri'
require 'faraday'
require 'faraday_middleware'

module Peribot
  module GroupMe
    # A Peribot postprocessor task to ensure that any images sent by services
    # are uploaded to the GroupMe image service (if this is not already done).
    # Uploads to the image service are required in order to post images to
    # GroupMe - this postprocessor makes this detail more transparent to
    # services.
    class ImageProcessor < Peribot::Processor
      IMAGE_HOST = 'i.groupme.com'.freeze
      UPLOAD_HOST = 'https://image.groupme.com'.freeze
      UPLOAD_PATH = '/pictures'.freeze

      # Register this postprocessor into a {Peribot::Bot} instance.
      #
      # @param bot [Peribot::Bot] A bot instance
      def self.register_into(bot)
        bot.postprocessor.register self
      end

      # Given an 'image' parameter in a message, create the necessary
      # 'attachment' parameter for GroupMe that will allow the image to be
      # attached to a real message once sent.
      #
      # @param message [Hash] The reply from services being processed
      def process(message)
        return message unless message['image']

        image_url = get_groupme_image_url message['image']
        add_image_to_message image_url, message
      end

      private

      # (private)
      #
      # Given the 'image' parameter of a message, obtain a GroupMe image URL
      # that corresponds to the image. This could involve downloading and
      # uploading the image, retrieving information from a cache, or simply
      # passing the URL as given if it is already a GroupMe image service URL.
      #
      # @param img The item to get an image URL for
      def get_groupme_image_url(img)
        return img if img.respond_to?(:to_str) &&
                      URI.parse(img).host == IMAGE_HOST

        io = img.respond_to?(:read) ? img : io_from_url(img)
        groupme_url_from_io io
      end

      # (private)
      #
      # Given an image URL, retrieve an IO object representing the actual
      # content of the image. Essentially, we are just downloading the image
      # and creating a StringIO out of it.
      #
      # @param img [String] The URL to an image on the web
      # @return [IO] An IO object containing the image body
      def io_from_url(img)
        StringIO.new(Faraday.new(img).get.body)
      end

      # (private)
      #
      # Given an IO object representing an image, upload that image to the
      # GroupMe image service and return the resulting image URL.
      #
      # @param io [IO] An IO object to upload
      # @return [String] The URL of the uploaded image
      def groupme_url_from_io(io)
        conn = Faraday.new(UPLOAD_HOST) do |f|
          f.request :multipart
          f.request :url_encoded
          f.response :json
          f.adapter :net_http
        end

        token = bot.config['groupme']['token']
        file = Faraday::UploadIO.new(io, 'application/octet-stream')

        res = conn.post UPLOAD_PATH, 'token' => token, 'file' => file
        res.body['payload']['url']
      end

      # (private)
      #
      # Given an image url (for the GroupMe image service) and a message, add
      # the image to the message's attachment list.
      #
      # @param image_url [String] The URL to the image on GroupMe
      # @param message [Hash] The message being processed
      def add_image_to_message(image_url, message)
        params = { 'type' => 'image', 'url' => image_url }

        msg = message.dup
        (msg['attachments'] ||= []) << params

        msg
      end
    end
  end
end
