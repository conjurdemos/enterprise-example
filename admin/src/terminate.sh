#!/bin/bash -e

if [ -z "$DEMO_NAME" ]; then
  echo DEMO_NAME is not specified
  exit 1
fi

echo Terminating Enterprise Example demo $DEMO_NAME

./ec2.py --refresh-cache 2>&1 > /dev/null
ansible-playbook -i ec2.py plays/terminate.yml
