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

      # Send the message, or pass it on if it does not meet the required format
      # (it contains 'group_id' and 'text' paramters). Messages that do not
      # meet this format may be intended for another sender.
      def process(message)
        return message unless message[:service] == :groupme

        text = message[:text]
        bid = get_bot_id message[:group].split('/').last
        picture = get_picture_url message[:attachments]

        return message unless text && bid

        options = {}
        options[:picture_url] = picture if picture

        @client.bot_post bid, text, options

        stop_processing
      end

      private

      # (private)
      #
      # Retrieve a bot ID based on a group ID.
      #
      # @param gid The group ID for the message
      # @return The ID of the bot to use to respond to this group
      def get_bot_id(gid)
        map = bot.config['groupme']['bot_map']
        map = auto_map if map == 'auto' || !map

        map[gid]
      end

      # (private)
      #
      # Create an automatic mapping between group IDs and bot IDs, which will
      # be cached in the bot instance so that we do not continually hit the
      # GroupMe API.
      def auto_map
        cache = bot.caches['groupme-bot-map']
        cache['map'] || cache['map'] = Hash[
          @client.bots.map { |bot| [bot['group_id'], bot['bot_id']] }.freeze]
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
    end
  end
end
