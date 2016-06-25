require 'spec_helper'
require 'tmpdir'

shared_context 'standard doubles' do
  let(:bot) do
    store = File.join(Dir.mktmpdir, 'peribot.pstore')
    bot = Peribot::Bot.new(store_file: store)
    bot.configure do
      groupme do
        token 'TEST'
        welcome 'This is a welcome message!'
      end
    end

    bot
  end

  let(:client) { instance_double(GroupMe::Client) }
end
