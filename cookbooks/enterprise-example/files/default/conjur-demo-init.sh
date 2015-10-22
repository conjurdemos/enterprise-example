#!/bin/bash -ex

hostname="$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)"
password="$(openssl rand -hex 8)"
orgaccount=demo
docker exec -i conjur-appliance evoke configure master -h "$hostname" -p "$password" $orgaccount

cli_image=apotterri/conjur-cli
docker run -i --rm -v $HOME/conjurrc:/conjurrc $cli_image conjur init -h localhost -f /conjurrc/.conjurrc <<< "yes"
docker run -i --rm -v $HOME/conjurrc:/conjurrc -e CONJURRC=/conjurrc/.conjurrc $cli_image conjur bootstrap <<EOF
admin
$password
demo
demo
demo
y
EOF
