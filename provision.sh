#!/bin/bash -ex
cd /vagrant

# Re-create the appliance, with the source folder mapped in
image=$(docker images | grep conjur-appliance | python -c 'import sys; tokens = sys.stdin.read().split(); print "%s:%s" % (tokens[0], tokens[1])')
docker rm -f -v conjur-appliance

sleep 5

docker create \
	--name conjur-appliance \
	--restart always \
	--log-driver=syslog --log-opt tag="conjur-appliance" \
	-v /var/log/conjur:/var/log/conjur \
	-v /opt/conjur/backup:/opt/conjur/backup \
	-v $PWD:/src/enterprise-example \
	-p "443:443" -p "636:636" -p "5432:5432" -p "5433:5433" -p "127.0.0.1:38053:38053" \
	$image

docker start conjur-appliance

cat << CONFIGURE | docker exec -i conjur-appliance bash
set -ex

openssl dhparam 256 > /etc/ssl/dhparam.pem
evoke configure master -h $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) \
    -p "$CONJUR_ADMIN_PASSWORD" demo

export CONJUR_AUTHN_LOGIN=admin
export CONJUR_AUTHN_API_KEY="$CONJUR_ADMIN_PASSWORD"

cat << "CONJUR_CONF" > /etc/conjur.conf
appliance_url: https://localhost/api
account: demo
plugins: [ policy ]
cert_file: /opt/conjur/etc/ssl/ca.pem
CONJUR_CONF

cd /src/enterprise-example

bundle
bundle exec ./populate.sh
CONFIGURE

cat << CONJUR_UI > /etc/init/conjur-ui.conf
description "Conjur UI"
author "Conjur, Inc."
start on filesystem and started docker
stop on runlevel [!2345]
respawn

pre-start script 
	/usr/bin/docker pull conjurinc/conjur-ui
end script

script
	/usr/bin/docker run -i -p 8443:443 --link conjur-appliance:conjur \
		-e CONJUR_APPLIANCE_URL=https://conjur \
		--name conjur-ui conjurinc/conjur-ui
end script

post-stop script
	sleep 2
	/usr/bin/docker rm conjur-ui
end script
CONJUR_UI

service conjur-ui start

