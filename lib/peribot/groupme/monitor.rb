module Peribot
  module GroupMe
    # A class that provides functionality for repeatedly calling an {#execute}
    # method after a specified interval. This is intended to be used to monitor
    # GroupMe API responses at regular intervals and perform actions based on
    # them. For example, a monitor can detect whether Peribot has been added to
    # new groups.
    #
    # It is intended that the {#execute} method of this class periodically be
    # called in a Concurrent::TimerTask, which can be conveniently done by
    # calling {.start}.
    class Monitor
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

      # Create a {Monitor} that can determine which groups do not yet have
      # bots and register them.
      #
      # @param bot [Peribot::Bot] A Peribot instance
      # @param client [GroupMe::Client] A GroupMe client instance
      def initialize(bot, client)
        @bot = bot
        @client = client
      end

      # Execute the task for this monitor. This should be overridden by
      # subclasses to perform actual work.
      def execute
      end
    end
  end
end
