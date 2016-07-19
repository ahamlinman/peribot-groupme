module Peribot
  module GroupMe
    # A Peribot sender task to send replies from services to GroupMe via the
    # bot feature. Messages containing text and an optional image are
    # supported.
    class BotSender < Peribot::Processor
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
        return message unless message[:service] == :groupme

        bid = get_bot_id message[:group].split('/').last
        text = message[:text]
        picture = get_picture_url message[:attachments]
        return message unless good_message(bid, text, picture)

        @client.bot_post bid, (text || ''), picture_options(picture)

        message
      end

      private

      # (private)
      #
      # Determine whether a message is okay to be sent based on the states of
      # its various elements. We should have a valid bot ID along with either
      # non-empty text or a picture attachment in order to send a message
      # successfully.
      def good_message(bid, text, picture)
        bid && (text && !text.empty? || picture)
      end

      # (private)
      #
      # Retrieve a bot ID based on a group ID.
      #
      # @param gid The group ID for the message
      # @return The ID of the bot to use to respond to this group
      def get_bot_id(gid)
        Util.bot_map_for(bot)[gid]
      end

      # (private)
      #
      # Get a picture URL from a list of attachments to a message.
      #
      # @param attachments [Array<Hash>] A list of attachments
      # @return [String] The URL of an image in the message, or nil if none
      def get_picture_url(attachments)
        return unless attachments

        image_att = attachments.find { |a| a[:kind] == :image }
        image_att && image_att[:image]
      end

      # (private)
      #
      # Generate options to send an image by URL
      #
      # @param picture The picture URL, or nil
      # @return [Hash] An empty hash, or one containing a picture URL
      def picture_options(picture)
        options = {}
        options[:picture_url] = picture if picture

        options
      end
    end
  end
end
