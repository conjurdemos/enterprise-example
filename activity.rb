#!/usr/bin/env ruby
require 'conjur/cli'
require 'conjur-api'
require 'open-uri'
require 'active_support/inflector'
require 'set'

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

USER_CHURN_CHANCE = Chance.new(1, DAILY_SAMPLES)
MIN_USERS = 396
MAX_USERS = 404

def random_user_set_from_group conjur, group_name, count: 1
  group = conjur.group group_name
  grants = group.role.members
  user_grants = grants.select { |g| g.member.kind == 'user' }

  results = Set.new
  begin
    role = user_grants.sample.member
    if !results.include? role.id
      # Workaround for #106344362. The code will fail with
      # Forbidden if user is already retired.
      conjur.user(role.id).uidnumber

      results.add(role.id)
    end
  rescue RestClient::Forbidden
    # Ignore
  end while results.size < count

  results.to_a
end

def random_user_from_group conjur, group_name
  random_user_set_from_group(conjur, group_name, count: 1)[0]
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

def hire_random_to_group conjur, group_name, count: 1
  count.times do
    who = fetch_unique_user_name conjur
    conjur.create_user who, ownerid: conjur.group('security_admin').roleid, password: 'password'
    conjur.group(group_name).add_member conjur.user(who)
    puts "Hired #{who}"
  end
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


def fire_user conjur, who
  puts "Attempting to terminate #{who}"
  if system(*%W(conjur user retire), "#{who}")
    puts "Terminated #{who}"
  end
end

def fire_random_from_group conjur, group_name, count: 1
  fire_list = []
  while fire_list.size < count
    users = random_user_set_from_group conjur, group_name, count: count - fire_list.size
    users.each do |who|
      if !fire_list.include? who
        fire_user conjur, who
        fire_list.push who
      end
    end
  end
end

def hire_or_fire conjur
  employee_count = conjur.resources(kind: "user").count
  begin
    user_delta = Random.rand(MIN_USERS..MAX_USERS) - employee_count
  end until user_delta != 0;
  
  puts "Adjust employee count #{employee_count} to #{employee_count + user_delta}"
  if user_delta > 0
    hire_random_to_group conjur, 'employees', count: user_delta
  elsif user_delta < 0
    fire_random_from_group conjur, 'employees', count: -user_delta
  end
end

def connect_as_current_user
  # Load configuration file
  Conjur::Config.load
  return Conjur::Authn.connect nil, noask: true
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

  if USER_CHURN_CHANCE.check?
    hire_or_fire conjur
  end
end

if __FILE__ == $0
  main
end
