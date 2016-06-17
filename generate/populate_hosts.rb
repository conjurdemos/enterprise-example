#!/usr/bin/env ruby

require 'json'
require 'conjur/cli'
require 'conjur/api'

Conjur::Config.load
Conjur::Config.apply

conjur = Conjur::Authn.connect nil, noask: true
api    = Conjur::Command.api

def load_host_data(path)
    if path.nil? or not File.exists?(path)
        puts 'Usage: ./populate_hosts.rb data.json'
        exit
    end

    data = ''
    File.open(path, 'r') do |stream|
        while(line = stream.gets)
            data << line
        end

        stream.close
    end

    return JSON.parse(data)
end

hostData = load_host_data(ARGV[0])
security_admin = (api.group 'security_admin').roleid

hostData.each_pair do |layerName, hostArray|
    # api.create_layer layerName
    currentLayer = api.layer layerName

    if not currentLayer.exists?
        puts "#{layerName} does not exist! Skipping."
        next
    end
    
    puts "Populating #{layerName}"

    hostArray.each do |hostName|
        newHost = api.host hostName

        if not newHost.exists?
            api.create_host id: hostName, ownerid: security_admin
        end

        currentLayer.add_host newHost
    end
end

