# frozen_string_literal: true

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
      end
    end
  end
end
