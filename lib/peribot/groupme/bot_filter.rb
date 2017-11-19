module Peribot
  module GroupMe
    # A filter that drops all messages we cannot respond to while in bot sender
    # mode. This includes all messages from groups that don't have a bot
    # available in the bot mapping (whether manually configured or
    # automatically generated).
    class BotFilter < Peribot::Processor
      # Register ourself into a bot's filter chain.
      def self.register_into(bot)
        bot.filter.register self
      end

      # Filter out messages that we cannot respond to, while passing through
      # messages that we can respond to or that are destined for other
      # services.
      #
      # @param message [Hash] The Peribot-formatted message to check
      def process(message)
        return message unless message[:service] == :groupme

        gid = message[:group].split('/').last
        map = Util.bot_map_for(bot)

        message if map.key? gid
      end
    end
  end
end
