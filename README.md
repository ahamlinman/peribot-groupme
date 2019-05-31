**Peribot is no longer in active development.** Its components are kept on
GitHub in the hope that they may be useful to others, but please keep in mind
that they have not been maintained for some time, and may fail to operate as
originally intended.

**Why?** Peribot was developed as a basis for some GroupMe chatbots that I
personally operated. Those bots are rarely used anymore, and Peribot is not
used elsewhere to my knowledge. Thus, I no longer have much reason to invest in
this project.

Thank you for your interest, and sorry for the bad news. The Peribot::GroupMe
README continues below, but please note that parts of it may become outdated
over time.

---

# Peribot::GroupMe

Peribot::GroupMe allows [Peribot]-powered bots to easily send and receive
GroupMe messages. It is incredibly simple to configure in most cases, yet
allows for a good amount of flexibility in how your bot operates.

Thanks to push notification support, there's no need to run a web server and
manage callback URLs as GroupMe typically requires. Running a bot with
Peribot::GroupMe is now as simple as running a script!

## Getting Started

For a basic introduction to Peribot and Peribot::GroupMe, take a look at the
[Zero to Peribot] tutorial on the Peribot wiki. This is essentially a "Hello,
world!" project for the framework that results in a simple GroupMe bot.

## Configuring Your Bot

To use Peribot::GroupMe with a Peribot-powered bot, you must have a `groupme`
section in your bot's configuration containing the following:

  * `token` (required): An access token for the GroupMe API, obtainable at
    https://dev.groupme.com by creating an application or clicking "Access
    Token" in the top navigation bar. (I recommend the application method, as it
    allows tokens to be revoked if necessary by deleting the application.)
  * `bot_map` (optional): Mappings from group IDs to bot IDs. By default,
    Peribot::GroupMe sends messages using "bots" created for particular groups
    at https://dev.groupme.com. Each bot acts like a user within a group - it
    has its own name and avatar and can send messages (although it does not
    appear in the list of group members). If you use bots for other purposes,
    you may want to manually specify the bot that Peribot::GroupMe should use to
    send messages to a particular group, using the ID of the group and of the
    bot you wish to use. If you do not provide this mapping, Peribot::GroupMe
    will obtain a list of your bots at runtime and create a mapping
    automatically (using the last bot in the list that matches a given group).
    You can also obtain this behavior by specifying `auto` for this option.

Here is an example of what you might include in a YAML configuration file for
your bot (with fake values):

    groupme:
      token: 09f911029d74e35bd84156c5635688c0
      bot_map:
        '12345678': 82ef4009ed7cac2a5ee12b5f8e8ad9a0

## License

This gem is available under the terms of the [MIT License].

<!-- Links -->
[MIT License]: http://opensource.org/licenses/MIT
[Peribot]: https://github.com/ahamlinman/peribot
[Zero to Peribot]: https://github.com/ahamlinman/peribot/wiki/Zero-to-Peribot
