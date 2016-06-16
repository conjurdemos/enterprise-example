#!/bin/bash -e

if [ -z "$DEMO_NAME" ]; then
  echo DEMO_NAME is not specified
  exit 1
fi

if [ -z "$SSH_PRIVATE_KEY" ]; then
  echo SSH_PRIVATE_KEY is not specified
  exit 1
fi

echo Storing private key

mkdir -p ~/.ssh
echo "$SSH_PRIVATE_KEY" > /dev/shm/id_rsa
chmod 0600 /dev/shm/id_rsa

password=$(openssl rand -hex 8)

echo Launching Enterprise Example demo $DEMO_NAME

ansible-playbook --key-file /dev/shm/id_rsa  -u ubuntu --extra-vars "admin_password=$password" plays/launch.yml

./configure.sh
