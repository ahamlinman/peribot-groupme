# Peribot::GroupMe

Peribot::GroupMe is a set of components for Peribot. This provides everything
necessary for a Peribot instance to send and receive messages from GroupMe.

A major caveat of this implementation is that it assumes the bot is a full
GroupMe user, rather than simply a bot created on the developer site. Keep in
mind that a phone number is required to create a new GroupMe user. It is
designed to use the callback feature of bots, rather than push notifications or
other means, to receive messages. It more or less acts as a web server that
receives messages from GroupMe and processes them before sending back replies
through the normal API. Many improvements can be made in all of these areas,
but this is at least a start for getting a working chatbot running.

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ahamlinman/peribot-groupme.

## License

This gem is available under the terms of the [MIT License].

<!-- Links -->
[MIT License]: http://opensource.org/licenses/MIT
