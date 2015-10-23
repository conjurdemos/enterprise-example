#!/usr/bin/env ruby

require 'yaml'
require 'set'

require 'methadone'
require 'methadone/cli_logger'

class Generator
  LDAP_DN = 'dc=example,dc=com'

  def initialize input, output
    @input_path = input
    @output_path = output
  end

  def run!
    write_groups
    write_users
  end

  protected

  def output
    @output ||= File.open(@output_path, 'w')
  end

  def write_groups
    groups = Set.new
    data.each do |_, hash|
      if hash['groups'].kind_of?(Array)
        hash['groups'].each{|g| groups << g}
      end
    end

    groups.each do |name|
      output << group_ldif(name)
    end

    info "Wrote #{groups.size} groups"
  end

  def write_users
    data.each do |name, info|
      output << user_ldif(name, (info['groups'] || []))
    end
    info "Wrote #{data.size} users"
  end

  def user_ldif name, groups
    <<-EOS
dn: cn=#{name},#{LDAP_DN}
cn: #{name}
uid: #{name}
uidNumber: #{uid_number_for name}
homeDirectory: /home/#{name}
objectClass: posixAccount
objectClass: top
#{memberships_ldif groups}


    EOS
  end

  def memberships_ldif groups
    groups.map do |g|
      "gidNumber: #{gid_number_for g}"
    end.join "\n"
  end

  def group_ldif name
    <<-EOS
dn: cn=#{name},#{LDAP_DN}
cn: #{name}
gidNumber: #{gid_number_for(name)}
objectClass: posixGroup
objectClass: top


    EOS
  end

  def gid_number_for name
    id_number_for gids, name
  end

  def uid_number_for name
    id_number_for uids, name
  end

  def id_number_for hash, name
    hash[name] ||= next_id
  end

  def gids
    @gids ||= {}
  end

  def uids
    @uids ||= {}
  end

  def next_id
    @counter ||= 0
    @counter += 1
  end

  def data
    @data ||= YAML.load File.read(@input_path)
  end
end

include Methadone::Main
include Methadone::CLILogging



main do |input, output|
  Generator.new(input, output).run!
  info "Wrote LDIF to #{output}"
end


go!