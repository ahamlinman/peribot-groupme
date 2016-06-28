# frozen_string_literal: true

require 'peribot/groupme/push/auth'
require 'faye'

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
        token = bot.config['groupme']['token']
        client = ::GroupMe::Client.new token: token

        ::EventMachine.run do
          push = faye_client token
          push.subscribe("/user/#{client.me['id']}") do |msg|
            if msg['type'] == 'line.create'
              bot.accept(groupme_to_peribot(msg['subject']))
            end
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

        # (private)
        #
        # Convert a message in GroupMe's format to a message in Peribot's
        # format.
        def groupme_to_peribot(message)
          {
            service: :groupme,
            group: "groupme/#{message['group_id']}",
            text: message['text'],
            user_name: message['name'],
            id: message['id'],
            attachments: convert_attachments(message['attachments']),
            original: message
          }
        end

        # (private)
        #
        # Convert attachments from GroupMe's format to Peribot's format.
        def convert_attachments(attachments)
          return nil unless attachments

          converted = attachments.map { |a| convert_attachment(a) }.compact

          return nil if converted.empty?
          converted
        end

        # (private)
        #
        # Convert an attachment from GroupMe's format to Peribot's format. For
        # now, we only convert images (not mentions or other attachments).
        def convert_attachment(attachment)
          return nil unless attachment['type'] == 'image'

          {
            kind: :image,
            image: attachment['url']
          }
        end
      end
    end
  end
end
