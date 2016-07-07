#!/bin/bash -ex

mkdir -p tmp

gem install -N conjur-asset-policy

if [ -t 1 ]; then
	conjur bootstrap
else
	conjur bootstrap -q
fi

conjur script execute --context conjur.json --as-group security_admin policy/groups.rb
conjur script execute --context conjur.json --as-group security_admin policy/users.rb

conjur policy load --context api-keys.json --as-group security_admin policy/Conjurfile

cd generate
./populate_hosts.rb hosts.json
cd -
