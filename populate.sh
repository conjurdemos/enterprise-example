#!/bin/bash -ex

mkdir -p tmp

conjur script execute --as-group security_admin policy/groups.rb
conjur script execute --as-group security_admin policy/users.rb

for script in $(find -L policy/* -name "*.rb"); do
	read folder collection group file <<< $(echo $script | tr "/" " ")
	if [ ! -z "$file" ]; then
		echo Loading policy $file as group $group under collection $collection
		conjur policy load --collection $collection --as-group $group $folder/$collection/$group/$file
	fi
done        	

conjur script execute --as-group security_admin -c tmp/identity-info.json policy/entitlements.rb
