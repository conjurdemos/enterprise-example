#!/usr/bin/env ruby
require 'conjur/cli'
require 'conjur-api'
require 'open-uri'
require 'active_support/inflector'

class Chance
  def initialize chance, sample_size
    @chance = chance
    @sample_size = sample_size
  end

  def check?
    Random.rand(@sample_size) < @chance
  end
end

INTERVAL = 60
DAY = 86400
DAILY_SAMPLES = DAY / INTERVAL

hire_chance = Chance.new(3, DAILY_SAMPLES)
fire_chance = Chance.new(3, DAILY_SAMPLES)

def random_user_from_group conjur, group_name
  group = conjur.group group_name
  group.role.members.sample.member.id
end
  
def login_random_from_group conjur, group_name
  loop do
    who = random_user_from_group conjur, group_name
    begin
      api_key = Conjur::API.login who, 'password'
      return Conjur::API.new_from_key who, api_key
    rescue RestClient::Unauthorized
      # Ignore and try again with new user
    end
  end
end

# Return a list of 'User objects'
def fetch_unique_user_name conjur
  loop do
    response = JSON.parse(open("http://api.randomuser.me/").read)
    name_parts = response['results'][0]['user']['name']
    name = name_parts.values_at('first', 'last').join('.').gsub(' ', '.')
    # XXX Avoid unicode/weird names since they upset the system
    #name = name.chars.normalize(:kd).gsub(/[^\x00-\x7F]/n,'').downcase.to_s
    name = ActiveSupport::Inflector.transliterate(name)

    return name unless conjur.user(name).exists?
  end
end

def hire_random_to_group conjur, group_name
  who = fetch_unique_user_name conjur
  conjur.create_user who, ownerid: conjur.group('security_admin').roleid, password: 'password'
  conjur.group(group_name).add_member conjur.user(who)
  return who
end

def fire_random_from_group conjur, group_name
  who = random_user_from_group conjur, group_name
  return system(*%W(conjur user retire #{who})) ? who : nil;
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

if hire_chance.check? then
  who = hire_random_to_group conjur, 'employees'
  puts "Hired #{who}"
end

if fire_chance.check? then
  who = fire_random_from_group conjur, 'employees'
  puts "Terminated #{who}"
end
