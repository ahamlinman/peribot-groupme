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

      # Register this sender into a {Peribot::Bot} instance.
      #
      # @param bot [Peribot::Bot] A bot instance
      def self.register_into(bot)
        bot.sender.register self
      end

      # Send the message, or pass it on if it does not meet the required
      # format. Messages that do not meet this format may be intended for
      # another sender.
      def process(message)
        return message unless good_message(message)

        text = message[:text]
        group = message[:group]
        attachments = message[:attachments]

        @client.create_message group.split('/').last, (text || ''),
                               convert_attachments(attachments)

        message
      end

      private

      # (private)
      #
      # Determine whether we are able to send a response. We need a valid group
      # and either non-empty text or a set of attachments.
      def good_message(message)
        return unless message[:service] == :groupme && message[:group]

        text = message[:text]
        attachments = message[:attachments]

        (text && !text.empty?) || !convert_attachments(attachments).empty?
      end

      # (private)
      #
      # Convert attachments from Peribot's format to GroupMe's format.
      #
      # @param attachments [Array] The Peribot attachments to convert
      # @return [Array] GroupMe-style attachments for the client
      def convert_attachments(attachments)
        (!attachments && []) || attachments
          .select { |a| a[:kind] == :image }
          .map { |a| { 'type' => 'image', 'url' => a[:image] } }
      end
    end
  end
end
