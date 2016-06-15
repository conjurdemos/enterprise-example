#!/bin/bash -e

if [ -z "$DEMO_NAME" ]; then
  echo DEMO_NAME is not specified
  exit 1
fi

echo Configuring Enterprise Example demo $DEMO_NAME

cd /src

ansible-playbook --key-file /dev/shm/id_rsa -i ec2.py -u ubuntu plays/configure.yml
