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
    end
  end
end
