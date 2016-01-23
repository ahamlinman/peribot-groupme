require 'peribot'
require 'groupme'

require 'peribot/groupme/bot_sender'
require 'peribot/groupme/image_processor'
require 'peribot/groupme/like_sender'
require 'peribot/groupme/sender'
require 'peribot/groupme/version'

module Peribot
  # This module provides functionality for a Peribot instance to work within
  # GroupMe groups. Where Peribot provides the core plumbing to make all of
  # this work, Peribot::GroupMe provides various components that connect that
  # plumbing to GroupMe's inputs and outputs.
  module GroupMe
    module_function

    # Register GroupMe components with the given bot. This sets up the bot for
    # communication with GroupMe.
    def register_into(bot)
      bot.postprocessor.register Peribot::GroupMe::ImageProcessor

      bot.sender.register Peribot::GroupMe::Sender
      bot.sender.register Peribot::GroupMe::LikeSender
    end
  end
end
