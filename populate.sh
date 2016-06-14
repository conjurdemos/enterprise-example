#!/bin/bash -ex

mkdir -p tmp

conjur bootstrap -q

cat << USER_SCRIPT | ruby -rconjur-api -rconjur-cli -rconjur/authn
Conjur::Config.load
Conjur::Config.apply
api = Conjur::Authn.connect(nil, noask: true)
api.create_user 'alice', password: 'password' unless api.user('alice').exists?
USER_SCRIPT
conjur group members add security_admin alice
conjur elevate resource give user:alice group:security_admin

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

cd demo
./populate_hosts.rb hosts.json
cd -
