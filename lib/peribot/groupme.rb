require 'peribot'
require 'groupme'

require 'peribot/groupme/monitor'
require 'peribot/groupme/bot_monitor'
require 'peribot/groupme/welcome_monitor'

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
    MONITOR_INTERVAL = 15

    # The interval after which monitor tasks are considered to have failed, in
    # seconds.
    MONITOR_TIMEOUT = 15

    module_function

    # Register GroupMe components with the given bot. This sets up the bot for
    # communication with GroupMe.
    def register_into(bot)
      bot.sender.register Peribot::GroupMe::Sender
      bot.sender.register Peribot::GroupMe::LikeSender

      Peribot::GroupMe::BotMonitor.start(
        bot,
        execution_interval: MONITOR_INTERVAL,
        timeout_interval: MONITOR_TIMEOUT)

      Peribot::GroupMe::WelcomeMonitor.start(
        bot,
        execution_interval: MONITOR_INTERVAL,
        timeout_interval: MONITOR_TIMEOUT)
    end
  end
end
