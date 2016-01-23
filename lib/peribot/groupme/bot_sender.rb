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
        @bot = bot
        @client = ::GroupMe::Client.new token: @bot.config['groupme']['token']
      end

      # Send the message, or pass it on if it does not meet the required format
      # (it contains 'group_id' and 'text' paramters). Messages that do not
      # meet this format may be intended for another sender.
      def process(message)
        text = message['text']
        bid = get_bot_id message['group_id']
        picture = get_picture_url message['attachments']

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
        map = @bot.config['groupme']['bot_map']
        map = auto_map if map == 'auto' || !map

        map[gid]
      end

      # (private)
      #
      # Create an automatic mapping between group IDs and bot IDs, which will
      # be cached in the bot instance so that we do not continually hit the
      # GroupMe API.
      def auto_map
        cache = @bot.cache['groupme-bot-map']
        return cache.value['map'] if cache.value['map']

        map = Hash[@client.bots.map { |bot| [bot['group_id'], bot['bot_id']] }]
        cache.swap { |values| values.merge('map' => map) }

        map
      end

      # (private)
      #
      # Get a picture URL from a list of attachments to a message.
      #
      # @param attachments [Array<Hash>] A list of attachments
      # @return [String] The URL of an image in the message, or nil if none
      def get_picture_url(attachments)
        return unless attachments

        image = attachments.find { |a| a['type'] == 'image' }
        image && image['url']
      end
    end
  end
end
