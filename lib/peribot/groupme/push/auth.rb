module Peribot
  module GroupMe
    module Push
      # A basic Faye extension that will authenticate us with GroupMe when we
      # attempt to subscribe to our user channel.
      class Auth
        # Create a new authentication extension instance.
        def initialize(token)
          @token = token
        end

        # Process an outgoing message from Faye. If we are attempting to
        # subscribe to a channel, intercept the message and add our GroupMe
        # access token so that we can successfully authenticate with the push
        # service.
        def outgoing(message, callback)
          chan = message['channel']
          return callback.call message unless chan == '/meta/subscribe'

          message['ext'] ||= {}
          message['ext']['access_token'] = @token

          callback.call message
        end
      end
    end
  end
end
