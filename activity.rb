#!/usr/bin/env ruby
require 'conjur/cli'
require 'conjur-api'

def login_random_from_group conjur, group_name
  group = conjur.group group_name
  members = group.role.members
  loop do
    who = members.sample
    begin
      api_key = Conjur::API.login who.member.id, 'password'
      return Conjur::API.new_from_key who.member.id, api_key
    rescue RestClient::Unauthorized
      # Ignore and try again with new user
    end
  end
end
  
# Load configuration file
Conjur::Config.load
conjur = Conjur::Authn.connect nil, noask: true

user_api = login_random_from_group conjur, 'developers'
puts "Logged in as #{user_api.username}"

secrets = %w(licenses/compiler licenses/profiler licenses/coverity)
secret = user_api.variable secrets.sample
secret.value
puts "Read secret #{secret.id}"

