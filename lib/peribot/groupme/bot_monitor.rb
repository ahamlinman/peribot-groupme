module Peribot
  module GroupMe
    # A monitor used to determine whether Peribot has been added to new groups
    # and register any necessary listener bots in order to receive callbacks.
    #
    # @see Peribot::GroupMe::Monitor
    # @example Starting the monitor
    #   # All keyword options are passed to the TimerTask constructor
    #   Peribot::GroupMe::BotMonitor.start bot, execution_interval: 30
    class BotMonitor < Monitor
      # Execute the task of registering any necessary listener bots.
      def execute
        groups = @client.groups.map { |group| group['group_id'] }
        bots = @client.bots.map { |bot| bot['group_id'] }

        register_new_bots groups, bots
      end

      private

      # (private)
      #
      # Determine which groups have no associated bot and register them.
      #
      # @param groups [Array<String>] An array of group IDs
      # @param bots [Array<String>] An array of group IDs that have bots
      def register_new_bots(groups, bots)
        botless_groups = groups - bots
        opts = @bot.config['groupme']['bots']

        botless_groups.each do |group|
          @client.create_bot opts['name'], group,
                             callback_url: opts['callback']
        end
      end
    end
  end
end
