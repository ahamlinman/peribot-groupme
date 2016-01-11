module Peribot
  module GroupMe
    # A Peribot sender task to send replies from services to GroupMe.
    # Currently, messages containing text are supported. Attachments will
    # likely be supported in the future.
    class Sender < Peribot::Middleware::Task
      # Initialize this sender task.
      #
      # @param bot [Peribot::Bot] A Peribot instance
      def initialize(bot)
        @bot = bot
      end

      # Send the message, or pass it on if it does not meet the required format
      # (it contains 'group_id' and 'text' paramters). Messages that do not
      # meet this format may be intended for another sender.
      def process(message)
        return message unless message['text'] && message['group_id']

        client = ::GroupMe::Client.new token: @bot.config['groupme']['token']
        client.create_message message['group_id'], message['text']

        stop_processing
      end
    end
  end
end
