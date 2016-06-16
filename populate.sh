#!/bin/bash -ex

mkdir -p tmp

conjur bootstrap

conjur script execute --context conjur.json --as-group security_admin policy/groups.rb
conjur script execute --context conjur.json --as-group security_admin policy/users.rb

for script in $(find policy/* -name "*.yml"); do
	read folder group file <<< $(echo $script | tr "/" " ")
	if [ ! -z "$file" ]; then
		echo Loading policy $file as group $group
		conjur policy load --context api-keys.json --namespace prod --as-group $group $folder/$group/$file
	fi
done        	

conjur policy load --context api-keys.json --as-group security_admin policy/entitlements.yml

cd generate
./populate_hosts.rb hosts.json
cd -
