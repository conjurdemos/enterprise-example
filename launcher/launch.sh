#!/bin/bash

cp ../Vagrantfile .
cp -R ../cookbooks .

export AWS_ACCESS_KEY_ID=$(awk '/^aws_access_key_id/{print $3}' ~/.aws/credentials)
export AWS_SECRET_ACCESS_KEY=$(awk '/^aws_secret_access_key/{print $3}' ~/.aws/credentials)
export AWS_KEYPAIR_NAME=launch-conjur-demo-$HOSTNAME
export SSH_PRIVATE_KEY_PATH=id_$AWS_KEYPAIR_NAME  
aws ec2 create-key-pair --key-name $AWS_KEYPAIR_NAME --query 'KeyMaterial' --output text> $SSH_PRIVATE_KEY_PATH
chmod 400 $SSH_PRIVATE_KEY_PATH
export CONJUR_ADMIN_PASSWORD=$(openssl rand -hex 8) 
export AWS_BASE_AMI=ami-4dd1e727

echo "Admin password is : $CONJUR_ADMIN_PASSWORD"

vagrant up --provider aws --debug
