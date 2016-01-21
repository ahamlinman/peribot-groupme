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
        # @param client [GroupMe::Client] A GroupMe client instance
        def start(bot, client, options = {})
          task = Concurrent::TimerTask.new(options) do
            monitor = new bot, client
            monitor.execute
          end
          task.execute
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

      # A failure action that will be called when exceptions are thrown in
      # order to print details to stderr.
      #
      # @param error [Exception] The error that was raised
      def failure_action(error)
        @bot.log "#{self.class}: Error in monitor\n"\
                 "  => exception = #{error.inspect}\n"\
                 "  => backtrace:\n#{format_backtrace error.backtrace}"
      end

      private

      # (private)
      #
      # Format an exception backtrace for printing to the log.
      #
      # @param backtrace [Array<String>] Lines of the backtrace
      # @return [String] An indented backtrace with newlines
      def format_backtrace(backtrace)
        indent = 5
        backtrace.map { |line| line.prepend(' ' * indent) }.join("\n")
      end
    end
  end
end
