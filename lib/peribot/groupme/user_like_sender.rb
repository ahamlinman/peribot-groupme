module Peribot
  module GroupMe
    # A Peribot sender task to like GroupMe messages via the user whose access
    # token is being used for the bot. Likes are sent based on the presence of
    # `:like` attachments in the message (see the Peribot message format
    # specification for details).
    class UserLikeSender < Peribot::Processor
      # Register this sender into a {Peribot::Bot} instance.
      #
      # @param bot [Peribot::Bot] A bot instance
      def self.register_into(bot)
        bot.sender.register self
      end

      # Initialize this processor with a bot.
      def initialize(bot)
        super
        @client = ::GroupMe::Client.new token: bot.config['groupme']['token']
      end

      # Like the message, or pass it on if it does not meet the required format
      def process(message)
        return message unless message[:service] == :groupme &&
                              message[:group] && message[:attachments]

        message[:attachments].each do |attachment|
          next attachment unless attachment[:kind] == :like
          @client.create_like message[:group].split('/').last,
                              attachment[:message_id]
        end

        message
      end
    end
  end
end
