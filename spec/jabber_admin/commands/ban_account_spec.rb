# frozen_string_literal: true

require 'spec_helper'

RSpec.describe JabberAdmin::Commands::BanAccount do
  it_behaves_like 'a command',
                  with_name: 'ban_account',
                  with_input_args: [
                    user: 'tom@ejabberd.local',
                    reason: 'test'
                  ],
                  with_called_args: [
                    user: 'tom',
                    host: 'ejabberd.local',
                    reason: 'test'
                  ]
end
