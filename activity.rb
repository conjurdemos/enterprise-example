#!/usr/bin/env ruby
require 'conjur/cli'
require 'conjur-api'
require 'open-uri'
require 'active_support/inflector'

INTERVAL = 60
DAY = 86400
DAILY_SAMPLES = DAY / INTERVAL

class Chance
  def initialize chance, sample_size
    @chance = chance
    @sample_size = sample_size
  end

  def check?
    Random.rand(@sample_size) < @chance
  end
end

# Vary a baseline value between a min and max cyclically over a given time period.
class CyclicValue
  def initialize baseline, min_value, max_value, time_period, interval
    @baseline = baseline
    @min_value = min_value
    @max_value = max_value
    @time_period = time_period
    @chance = Chance.new(2*(max_value - min_value), time_period / interval)
  end

  def delta current_value, time: nil
    return 0 unless @chance.check?
    
    time ||= Time.now
    day_offset = time.to_i % @time_period
    delta = (day_offset < @time_period / 2) ? -1 : 1

    if (((current_value >= @max_value) && delta > 0) ||
        ((current_value <= @min_value) && delta < 0))
      delta = 0
    end

    return delta
  end
end

USER_CYCLE = CyclicValue.new 400, 360, 440, 2 * DAY, INTERVAL

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

def member_of_group? conjur, who, group_name
  conjur.group(group_name).role.members.any? { |m| m.member.id == who }
end

# A member of one of these groups cannot be fired. This is necessary
# until the hiring/firing logic is made smarter to keep the groups
# populated.
GROUPS_PROTECTED_FROM_FIRE = %w(developers hradmins operations qa researchers security_admin)

def protected_from_fire? conjur, who
  return true if who == "testuser"

  GROUPS_PROTECTED_FROM_FIRE.any? do |g|
    member_of_group? conjur, who, g
  end
end

def fire_random_from_group conjur, group_name
  who = nil
  loop do
    who = random_user_from_group conjur, group_name
    break unless protected_from_fire? conjur, who
  end

  return system(*%W(conjur user retire), "#{who}") ? who : nil
end

def main
  # Load configuration file
  Conjur::Config.load
  conjur = Conjur::Authn.connect nil, noask: true

  user_api = login_random_from_group conjur, 'developers'
  puts "Logged in as #{user_api.username}"

  secrets = %w(licenses/compiler licenses/profiler licenses/coverity)
  secret = user_api.variable secrets.sample
  secret.value
  puts "Read secret #{secret.id}"

  employee_count = conjur.group('employees').role.members.count
  user_delta = USER_CYCLE.delta employee_count
  if user_delta > 0
    who = hire_random_to_group conjur, 'employees'
    puts "Hired #{who}"
  elsif user_delta < 0
    who = fire_random_from_group conjur, 'employees'
    puts "Terminated #{who}"
  end
end

if __FILE__ == $0
  main
end
