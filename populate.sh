#!/bin/bash -e

conjur script execute --as-group security_admin policy/groups.rb
conjur script execute --as-group security_admin policy/users.rb

for script in $(find policy/* -name "*.rb"); do
	read folder group file <<< $(echo $script | tr "/" " ")
	if [ ! -z "$file" ]; then
		echo Loading policy $file as group $group
		conjur policy load --collection v1 --as-group $group $folder/$group/$file
	fi
done        	

conjur script execute --as-group security_admin policy/entitlements.rb
