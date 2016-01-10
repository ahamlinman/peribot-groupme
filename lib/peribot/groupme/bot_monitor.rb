module Peribot
  module GroupMe
    # A class that continually monitors API responses from GroupMe to determine
    # whether Peribot has been added to new groups and thus needs to register a
    # bot to receive callbacks. It is intended that the {#execute} method of
    # this class periodically be called in a Concurrent::TimerTask, which can
    # be conveniently done by calling {.start}.
    #
    # @example Starting the monitor
    #   # All keyword options are passed to the TimerTask constructor
    #   Peribot::GroupMe::BotMonitor.start bot, execution_interval: 30
    class BotMonitor
      class << self
        # Start a timer task that will run {#execute} repeatedly in the
        # background after a specified interval.
        #
        # @param bot [Peribot::Bot] A Peribot instance
        def start(bot, options = {})
          task = Concurrent::TimerTask.new(options) do
            monitor = from_bot bot
            monitor.execute
          end
          task.execute
        end

        # Create an instance of this class solely from a bot. The API token for
        # the GroupMe client will be pulled from the bot's configuration.
        #
        # @param bot [Peribot::Bot] A Peribot instance
        def from_bot(bot)
          new bot, ::GroupMe::Client.new(token: bot.config['groupme']['token'])
        end
      end

      # Create a BotMonitor that can determine which groups do not yet have
      # bots and register them.
      #
      # @param bot [Peribot::Bot] A Peribot instance
      # @param client [GroupMe::Client] A GroupMe client instance
      def initialize(bot, client)
        @bot = bot
        @client = client
      end

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
