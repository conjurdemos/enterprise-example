#!/bin/bash -ex

mkdir -p tmp

conjur script execute --as-group security_admin policy/groups.rb
conjur script execute --as-group security_admin policy/users.rb

for script in $(find policy/* -name "*.yml"); do
	read folder group file <<< $(echo $script | tr "/" " ")
	if [ ! -z "$file" ]; then
		echo Loading policy $file as group $group
		conjur policy2 load --namespace prod --as-group $group $folder/$group/$file
	fi
done        	

conjur policy2 load --as-group security_admin policy/entitlements.yml
