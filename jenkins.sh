#!/bin/bash -e

CONJUR_VERSION=${CONJUR_VERSION:-"4.6"}
DOCKER_IMAGE=${DOCKER_IMAGE:-"registry.tld/conjur-appliance-cuke-master:$CONJUR_VERSION-stable"}
NOKILL=${NOKILL:-"0"}
PULL=${PULL:-"1"}

if [ -z "$CONJUR_CONTAINER" ]; then
	if [ "$PULL" == "1" ]; then
	    docker pull $DOCKER_IMAGE
	fi
	
	cid=$(docker run -d -v ${PWD}:/src/enterprise-example $DOCKER_IMAGE)
	function finish {
    	if [ "$NOKILL" != "1" ]; then
			docker rm -f ${cid}
		fi
	}
	trap finish EXIT
	
	>&2 echo "Container id:"
	>&2 echo $cid
else
	cid=${CONJUR_CONTAINER}
fi

docker exec $cid bash -c "echo '127.0.0.1 conjur' >> /etc/hosts"
docker exec $cid /opt/conjur/evoke/bin/wait_for_conjur

cat << "TEST" | docker exec -i $cid bash
set -ex

export CONJUR_AUTHN_LOGIN=admin CONJUR_AUTHN_API_KEY=secret

cd /src/enterprise-example
rm -rf features/reports
bundle
bundle exec ./populate.sh
TEST
