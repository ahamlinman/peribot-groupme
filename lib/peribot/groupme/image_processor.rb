# frozen_string_literal: true

require 'uri'

module Peribot
  module GroupMe
    # A Peribot postprocessor task to ensure that any images sent by services
    # are uploaded to the GroupMe image service (if this is not already done).
    # Uploads to the image service are required in order to post images to
    # GroupMe - this postprocessor makes this detail more transparent to
    # services.
    class ImageProcessor < Peribot::Middleware::Task
      IMAGE_HOST = 'i.groupme.com'.freeze
      UPLOAD_URL = 'https://image.groupme.com/pictures'.freeze

      # Initialize this postprocessor task.
      #
      # @param bot [Peribot::Bot] A Peribot instance
      def initialize(bot)
        @bot = bot
      end

      # Given an 'image' parameter in a message, create the necessary
      # 'attachment' parameter for GroupMe that will allow the image to be
      # attached to a real message once sent.
      #
      # @param message [Hash] The reply from services being processed
      def process(message)
        return message unless message['image']

        image_url = get_image_url message['image']
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
      def get_image_url(img)
        return img if URI.parse(img).host == IMAGE_HOST
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
