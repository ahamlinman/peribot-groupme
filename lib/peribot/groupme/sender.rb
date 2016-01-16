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
        @client = ::GroupMe::Client.new token: @bot.config['groupme']['token']
      end

      # Send the message, or pass it on if it does not meet the required format
      # (it contains 'group_id' and 'text' paramters). Messages that do not
      # meet this format may be intended for another sender.
      def process(message)
        text = message['text']
        gid = message['group_id']
        attachments = message['attachments']

        return message unless text && gid

        @client.create_message gid, text, (attachments || [])

        stop_processing
      end
    end
  end
end
