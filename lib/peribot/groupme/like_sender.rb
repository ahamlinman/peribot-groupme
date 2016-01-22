module Peribot
  module GroupMe
    # A Peribot sender task to like GroupMe messages. This task accepts
    # messages of a particular format and likes them without performing any
    # further processing.
    class LikeSender < Peribot::Processor
      # Initialize this sender task.
      #
      # @param bot [Peribot::Bot] A Peribot instance
      def initialize(bot)
        @bot = bot
      end

      # Like the message, or pass it on if it does not meet the required format
      # (it contains 'group_id' and 'like' paramters).
      def process(message)
        return message unless message['like'] && message['group_id']

        client = ::GroupMe::Client.new token: @bot.config['groupme']['token']
        client.create_like message['group_id'], message['like']

        stop_processing
      end
    end
  end
end
