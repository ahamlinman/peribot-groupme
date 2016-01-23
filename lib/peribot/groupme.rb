require 'peribot'
require 'groupme'

require 'peribot/groupme/monitor'
require 'peribot/groupme/bot_monitor'
require 'peribot/groupme/welcome_monitor'

require 'peribot/groupme/image_processor'

require 'peribot/groupme/bot_sender'
require 'peribot/groupme/sender'
require 'peribot/groupme/like_sender'

require 'peribot/groupme/version'

module Peribot
  # This module provides functionality for a Peribot instance to work within
  # GroupMe groups. Where Peribot provides the core plumbing to make all of
  # this work, Peribot::GroupMe provides various components that connect that
  # plumbing to GroupMe's inputs and outputs.
  module GroupMe
    # The interval between monitor executions, in seconds.
    MONITOR_INTERVAL = 20

    # The interval after which monitor tasks are considered to have failed, in
    # seconds.
    MONITOR_TIMEOUT = 15

    module_function

    # Register GroupMe components with the given bot. This sets up the bot for
    # communication with GroupMe.
    def register_into(bot, with_monitors: true)
      bot.postprocessor.register Peribot::GroupMe::ImageProcessor

      bot.sender.register Peribot::GroupMe::Sender
      bot.sender.register Peribot::GroupMe::LikeSender

      start_monitors_for bot if with_monitors
    end

    class << self
      private

      # (private)
      #
      # Start the bot and welcome monitors for this instance.
      def start_monitors_for(bot)
        timer_args = {
          execution_interval: MONITOR_INTERVAL,
          timeout_interval: MONITOR_TIMEOUT,
          run_now: true
        }

        Peribot::GroupMe::BotMonitor.start bot, client(bot), **timer_args
        Peribot::GroupMe::WelcomeMonitor.start bot, client(bot), **timer_args
      end

      # (private)
      #
      # Retrieve a GroupMe client based on the token in a bot's config.
      def client(bot)
        ::GroupMe::Client.new token: bot.config['groupme']['token']
      rescue NoMethodError
        raise 'could not obtain GroupMe token (does groupme.conf exist?)'
      end
    end
  end
end
