require 'peribot'
require 'groupme'

require 'peribot/groupme/bot_filter'
require 'peribot/groupme/bot_sender'
require 'peribot/groupme/image_postprocessor'
require 'peribot/groupme/push'
require 'peribot/groupme/user_like_sender'
require 'peribot/groupme/user_sender'
require 'peribot/groupme/util'
require 'peribot/groupme/version'

module Peribot
  # This module provides functionality for a Peribot instance to work within
  # GroupMe groups. Where Peribot provides the core plumbing to make all of
  # this work, Peribot::GroupMe provides various components that connect that
  # plumbing to GroupMe's inputs and outputs.
  module GroupMe
    module_function

    # Register GroupMe components with the given bot. This sets up the bot so
    # that it can reply to GroupMe. Note that it is still the responsibility of
    # an instance maintainer to determine how to get messages *into* the bot.
    #
    # @param bot [Peribot::Bot] A Peribot instance
    # @param send_as [Symbol] The method to use to send responses. The default
    #                         is :bots, which replies via bots added to groups.
    #                         The :user option can be used in order to respond
    #                         directly as a user.
    def register_into(bot, send_as: :bots, starter: true)
      bot.use Peribot::GroupMe::ImagePostprocessor

      case send_as
      when :bots
        bot.use Peribot::GroupMe::BotFilter
        bot.use Peribot::GroupMe::BotSender
      when :user
        bot.use Peribot::GroupMe::UserSender
        bot.use Peribot::GroupMe::UserLikeSender
      end

      register_groupme_starter_for bot if starter
    end

    class << self
      private

      # Define a method on a bot that allows for push messages to be started.
      # This is a relatively natural way of starting up the bot properly.
      def register_groupme_starter_for(bot)
        bot.define_singleton_method(:start_groupme_push!) do
          Peribot::GroupMe::Push.start! bot
        end
      end
    end
  end
end
