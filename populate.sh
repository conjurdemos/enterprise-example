#!/bin/bash -ex

mkdir -p tmp

gem install -N conjur-asset-policy

if [ -t 1 ]; then
	conjur bootstrap
else
	conjur bootstrap -q
fi

cd policy
conjur policy load --context api-keys.json --as-group security_admin conjur.yml
cd -
