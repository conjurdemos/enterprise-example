#!/bin/bash -e

NOKILL=${NOKILL:-"0"}

if [ ! -f ./bin/docker-compose ]; then
	curl -L https://github.com/docker/compose/releases/download/1.7.1/docker-compose-`uname -s`-`uname -m` > ./bin/docker-compose
	chmod a+x bin/docker-compose
fi

export PATH=./bin:$PATH

demo_name=$(openssl rand -hex 8)

function finish {
	if [ "$NOKILL" != "1" ]; then
		./bin/shutdown $demo_name || true
	fi
}

trap finish EXIT

CONTAINER_SUFFIX=$demo_name SUMMON_PROVIDER=conjurcli.sh ENVIRONMENT=ci ./bin/startup $demo_name

docker exec ee_cli_$demo_name ./populate.sh
