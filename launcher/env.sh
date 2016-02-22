#!/bin/bash

export AWS_ACCESS_KEY_ID=$(awk '/^aws_access_key_id/{print $3}' ~/.aws/credentials)
export AWS_SECRET_ACCESS_KEY=$(awk '/^aws_secret_access_key/{print $3}' ~/.aws/credentials)
export AWS_KEYPAIR_NAME=launch-conjur-demo-$HOSTNAME
export SSH_PRIVATE_KEY_PATH=id_$AWS_KEYPAIR_NAME
export AWS_BASE_AMI=ami-4dd1e727
