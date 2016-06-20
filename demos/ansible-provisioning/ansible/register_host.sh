#!/usr/bin/env bash
set -e
set -o pipefail

HOST_ID=$1
if [ -z $HOST_ID ]; then
	echo HOST_ID is required
	exit 1
fi
HOST_IP=$2
if [ -z $HOST_IP ]; then
	echo HOST_IP is required
	exit 1
fi
TIME_TO_LIVE=$3
[ -z $TIME_TO_LIVE ] && TIME_TO_LIVE=P1D

POLICY_ID=ansible/hosts/$HOST_ID

# Load the policy
cat /src/ansible/new_instance.yml \
	| sed -e 's;%HOST_ID%;'"$HOST_ID"';g' -e 's;%TIME_TO_LIVE%;'"$TIME_TO_LIVE"';g' -e 's;%HOST_IP%;'"$HOST_IP"';g' \
	| conjur policy load --as-role layer:prod/ansible/v1

# Populate policy variables
conjur variable value prod/ansible/v1/ec2/bootstrap_private_key | conjur variable values add "$POLICY_ID"/private_key
conjur variable values add "$POLICY_ID/host" "$HOST_IP"
conjur variable values add "$POLICY_ID/login" ubuntu

# Expire the bootstrap private key (trigger rotation)
conjur variable expire --now "$POLICY_ID/private_key"

conjur role grant_to -a policy:$POLICY_ID group:security_admin
conjur role revoke_from policy:$POLICY_ID layer:prod/ansible/v1
