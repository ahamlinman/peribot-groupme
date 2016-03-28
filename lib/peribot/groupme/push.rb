# frozen_string_literal: true

require 'peribot/groupme/push/auth'

module Peribot
  module GroupMe
    # The Push module provides some convenience functions for using the GroupMe
    # Push service with a Peribot instance. In particular, it includes a
    # .start! method which can easily be called to start up an event loop and
    # begin receiving messages.
    module Push
      PUSH_ENDPOINT = 'https://push.groupme.com/faye'.freeze

      module_function

      # Start the EventMachine reactor and create a Faye client to receive
      # messages from the GroupMe Push service and send them to the given bot.
      #
      # @param bot [Peribot::Bot] A Peribot instance
      def start!(bot)
        # Having Faye as a dependency brings in a lot of additional baggage,
        # including EventMachine and more. Thus, we're going to force the user
        # to require it themselves if they really want to do push.
        raise 'faye must be loaded to use push client' unless defined? ::Faye

        token = bot.config['groupme']['token']
        client = ::GroupMe::Client.new token: token

        ::EventMachine.run do
          push = faye_client token
          push.subscribe("/user/#{client.me['id']}") do |msg|
            bot.accept msg['subject'] if msg['type'] == 'line.create'
          end
        end
      end

      class << self
        private

        # (private)
        #
        # Obtain a Faye::Client that will connect to GroupMe using the
        # given authentication token.
        def faye_client(token)
          push = ::Faye::Client.new PUSH_ENDPOINT
          push.add_extension Auth.new token
          push
        end
      end
    end
  end
end
