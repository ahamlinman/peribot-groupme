require 'spec_helper'
require 'tempfile'

shared_context 'standard doubles' do
  let(:tmp_file) { @tmpfile = Tempfile.new(['peribot', '.pstore']) }
  let(:bot) do
    bot = Peribot::Bot.new(store_file: tmp_file)
    bot.configure do
      groupme do
        token 'TEST'
        welcome 'This is a welcome message!'
      end
    end

    bot
  end
  after(:each) { @tmpfile && @tmpfile.unlink && @tmpfile = nil }

  let(:client) { instance_double(GroupMe::Client) }
end
