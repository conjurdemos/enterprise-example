#!/bin/bash -ex
cd /vagrant

docker exec conjur-appliance mkdir -p /src/enterprise-example
tar -c * | docker exec -i conjur-appliance tar -x -C /src/enterprise-example
cat << "CONFIGURE" | docker exec -i conjur-appliance bash
set -ex
cd /src/enterprise-example

export CONJUR_AUTHN_LOGIN=admin
export CONJUR_AUTHN_API_KEY=$(su conjur -c "conjur-authn rails r \"puts User['admin'].api_key\"")

cat << "CONJUR_CONF" > /etc/conjur.conf
appliance_url: https://localhost/api
account: demo
plugins: [ dsl2 ]
cert_file: /opt/conjur/etc/ssl/ca.pem
CONJUR_CONF

bundle
bundle exec ./populate.sh
CONFIGURE
