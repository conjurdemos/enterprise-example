#!/bin/bash -e

mkdir -p tmp

rsync -a --delete --exclude tmp --exclude ci . ci/docker/tmp

cd ci/docker

docker build -t enterprise-example-test -f Dockerfile.test .

cd -

conjur_cid_file=tmp/conjur.cid

function finish {
	rm -f $conjur_cid_file || true
	docker rm -f $conjur_cid  || true
}
if [ -z "$KEEP_CONTAINERS" ]; then
	trap finish EXIT
fi

mkdir -p features/reports
chmod 777 features/reports

docker run -d --cidfile=$conjur_cid_file -P \
		registry.tld:80/conjur-appliance-cuke-master:4.5-stable  
conjur_cid=$(cat $conjur_cid_file)

cat << CLI_CONF > tmp/conjur.conf
appliance_url: https://conjur/api
account: cucumber
cert_file: /etc/conjur.pem
CLI_CONF

docker exec $conjur_cid cat /opt/conjur/etc/ssl/ca.pem > tmp/conjur.pem

sleep 60

docker run --rm \
		-e CONJUR_AUTHN_LOGIN=admin \
		-e CONJUR_AUTHN_API_KEY=secret \
		--link "$conjur_cid":conjur \
        -v $PWD/features/reports:/tmp/features/reports \
        -v $PWD/tmp/conjur.conf:/etc/conjur.conf \
        -v $PWD/tmp/conjur.pem:/etc/conjur.pem \
        enterprise-example-test
