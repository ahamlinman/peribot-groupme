require 'spec_helper'
require 'tempfile'

shared_context 'standard doubles' do
  let(:tmp_file) { @tmpfile = Tempfile.new(['peribot', '.pstore']) }
  let(:bot) do
    bot = Peribot::Bot.new(store_file: tmp_file)
    bot.configure do
      groupme { token 'TEST' }
    end

    bot
  end
  after(:each) { @tmpfile && @tmpfile.unlink && @tmpfile = nil }

  let(:client) { instance_double(GroupMe::Client) }
end
