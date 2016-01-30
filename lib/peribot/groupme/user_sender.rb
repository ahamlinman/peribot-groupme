module Peribot
  module GroupMe
    # A Peribot sender task to send replies from services to GroupMe via
    # messages from the user whose access token is being used for the bot.
    # Messages containing text and attachments are supported.
    class UserSender < Peribot::Processor
      # Initialize this sender task.
      #
      # @param bot [Peribot::Bot] A Peribot instance
      def initialize(bot)
        super

        @client = ::GroupMe::Client.new token: bot.config['groupme']['token']
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
