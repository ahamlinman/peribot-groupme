module Peribot
  module GroupMe
    # A monitor used to determine whether Peribot has been added to any new
    # groups and send them an informational welcome message. This is
    # customizable, and can include information about services provided by this
    # instance.
    #
    # @see Peribot::GroupMe::Monitor
    # @example Starting the monitor
    #   # All keyword options are passed to the TimerTask constructor
    #   Peribot::GroupMe::WelcomeMonitor.start bot, execution_interval: 30
    class WelcomeMonitor < Monitor
      # Execute the task of sending any necessary welcome messages.
      def execute
        joined_groups = @client.groups.map { |group| group['group_id'] }
        known_groups = @bot.store('groupme').value['known_groups']

        new_groups = joined_groups - known_groups
        new_groups.each { |group| welcome_message group }
        save_groups new_groups
      end

      private

      # Send a welcome message to a group.
      #
      # @param group [String] The ID of the group
      def welcome_message(group)
        @client.create_message group, @bot.config['groupme']['welcome']
      end

      # Ensure that all given groups are saved in the known groups list.
      #
      # @param groups [Array<String>] An array of group IDs to save
      def save_groups(groups)
        @bot.store('groupme').swap do |opts|
          opts['known_groups'] += groups
          opts
        end
      end
    end
  end
end
