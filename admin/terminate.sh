#!/bin/bash -e

if [ -z "$DEMO_NAME" ]; then
  echo DEMO_NAME is not specified
  exit 1
fi

echo Terminating Enterprise Example demo $DEMO_NAME

cd /src

ansible-playbook -i ec2.py plays/terminate.yml
