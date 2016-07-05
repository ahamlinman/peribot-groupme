# Peribot::GroupMe

Peribot::GroupMe allows [Peribot]-powered bots to easily send and receive
GroupMe messages. It is incredibly simple to configure in most cases, yet
allows for a good amount of flexibility in how your bot operates.

Thanks to push notification support, there's no need to run a web server and
manage callback URLs as GroupMe typically requires. Running a bot with
Peribot::GroupMe is now as simple as running a script!

## How can I use it?

First, visit the GroupMe Developers website at https://dev.groupme.com to
obtain an access token and create bots to respond to messages.

You can obtain an access token by clicking "Access Token" at the top right of
the page after logging in.  You can also create an application by clicking
"Applications" in the top navigation bar. This will give an access token
specific to your bot. (I recommend the latter method, as the application access
token can easily be revoked by deleting the application. I do not know of a way
to revoke an access token obtained via the first method.)

Bots are created by clicking "Bots" in the top navigation bar. You can add a
bot to any group that you are a member of, and you can customize its name and
avatar. By default, Peribot::GroupMe will send replies to the last of your bots
that it sees in a given group. If you have not created a bot for a group on the
GroupMe developers website, you will not see replies from your Peribot bot in
that group.

The following snippet shows how a Peribot bot might be configured to use
Peribot::GroupMe:

```ruby
# Assuming that 'peribot' and 'peribot/groupme' have been required
bot = Peribot.new
bot.configure do
  groupme { token '[YOUR ACCESS TOKEN]' }
end

bot.use Peribot::GroupMe
bot.use OtherThingsYouWant

bot.start_groupme_push!
```

The final line of this script starts an EventMachine loop that connects to
GroupMe push services and feeds all messages from all groups to your bot.
Again, with this configuration, your bot will only reply to groups that you
have created a bot for on the Developers website. (A future version of
Peribot::GroupMe will likely include a filter to ignore messages from other
groups. I just don't typically use this configuration, so I haven't created it
yet!) The bot will run until the Ruby interpreter is terminated.

I am planning more documentation of the features and configuration options for
Peribot::GroupMe as a future project. Please stay tuned, and feel free to
examine the code in the meantime!

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/ahamlinman/peribot-groupme.

## License

This gem is available under the terms of the [MIT License].

<!-- Links -->
[MIT License]: http://opensource.org/licenses/MIT
[Peribot]: https://github.com/ahamlinman/peribot
