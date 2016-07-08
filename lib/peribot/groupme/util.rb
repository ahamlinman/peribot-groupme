module Peribot
  module GroupMe
    # Minor shared utility functions for Peribot::GroupMe. Intended for
    # internal use only.
    module Util
      module_function

      # Load the GroupMe bots to groups mapping defined in this Peribot
      # instance's configuration, or automatically create a mapping if none
      # exists.
      def bot_map_for(bot)
        map = bot.config['groupme']['bot_map']

        if map == 'auto' || !map
          auto_map_for bot
        else
          map
        end
      end

      class << self
        private

        # (private)
        #
        # Create an automatic mapping between group IDs and bot IDs, which will
        # be cached in the bot instance so that we do not continually hit the
        # GroupMe API.
        def auto_map_for(bot)
          cache = bot.caches['groupme-bot-map']
          cache['map'] ||= Hash[
            client(bot).bots.map { |b| [b['group_id'], b['bot_id']] }.freeze]
        end

        # (private)
        #
        # Obtain a GroupMe client for a Peribot instance.
        def client(bot)
          ::GroupMe::Client.new token: bot.config['groupme']['token']
        end
      end
    end
  end
end
