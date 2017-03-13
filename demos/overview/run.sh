#!/usr/bin/env bash
set -eox pipefail

create_conjurize_script() {
    host_id="$1"
    api_key=$(conjur host rotate_api_key -h $host_id)
    echo "{\"id\": \"$host_id\", \"api_key\": \"$api_key\"}" | conjurize --chef-executable /usr/bin/chef-solo --ssh --conjur-run-list conjur::configure
}

psql_cmd () {
  docker-compose exec postgres bash -c "PGPASSWORD=secret psql -h localhost -U postgres -c \"$@\""
}

# Kill any current containers, rebuild, and start
(docker-compose stop && docker-compose rm -f && docker-compose build)
docker-compose up -d &>/dev/null

# Configure Conjur server as a master
docker-compose exec conjur evoke configure master -h conjur-solo -p secret demo

# Configure, initialize local client and create/login as user 'demo' with password 'demo'
unset CONJURRC
rm -f ~/conjur-demo.pem ~/.conjurrc
conjur init -h conjur <<< yes
conjur authn login admin <<< secret
cat <<EOF | conjur policy load
- !user demo
- !grant
  role: !group security_admin
  member: !user demo
EOF
conjur authn login -u demo -p "$(conjur user rotate_api_key -u demo)"
conjur user update_password -p demo

# Set up Postgres for example password rotation
psql_cmd "create database users;"
psql_cmd "create user robot with password 'initialpass'; grant all privileges on database users to robot;"

# Load the enterprise-example policies
pushd ../../
./populate.sh | cat
popd

# Conjurize our SSH containers
docker-compose exec -T bastion bash -c "$(create_conjurize_script bastion.itp.myorg.com); supervisorctl start logshipper" &
docker-compose exec -T userdb bash -c "$(create_conjurize_script userdb-01.itp.myorg.com); supervisorctl start logshipper" &
wait

# Creates an ssh_config to SSH with: `ssh -F ssh_config wayne.walker@userdb`
echo "Creating ssh_config..."
bastion_port=`docker-compose port bastion 22 | sed 's/.*://'`
cat <<- EOF > ssh_config
Host *
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null

Host bastion
    Port $bastion_port
    HostName localhost

Host userdb
    HostName userdb
    ProxyCommand ssh %r@localhost -p $bastion_port nc userdb 22
EOF

# Initialize some demo variables
conjur variable values add prod/postgres/v1/url "postgres/users"
conjur variable values add prod/postgres/v1/username "robot"
conjur variable values add prod/postgres/v1/password "initialpass"
conjur variable values add prod/frontend/v1/ssl/private_key "$(openssl genrsa 1024)"
conjur variable values add prod/frontend/v1/ssl/certificate "$(openssl genrsa 1024 | sed 's/RSA PRIVATE KEY/CERTIFICATE/g')"

# Add public keys to annie.diaz and wayne.walker for SSH
if [ -f ~/.ssh/id_rsa ]; then
    conjur pubkeys add annie.diaz "$(ssh-keygen -y -f ~/.ssh/id_rsa) DemoKey"
    conjur pubkeys add wayne.walker "$(ssh-keygen -y -f ~/.ssh/id_rsa) DemoKey"
fi