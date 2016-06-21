#!/usr/bin/env bash -e
set -o pipefail

# This script creates a new policy to store host variables.
# 
# The variables include:
# +private_key+ root SSH key (rotated)
# +host+ hostname or IP address, used by the rotator
# +login+ login name, used by the rotator
# +ec2/instance-id+ ec2 instance id (which is also part of the policy id)
#
# Once the policy is created, the variables are populated. Then the
# root SSH key is rotated. Finally, the policy is assigned to the operations
# group and revoked from Ansible. As a result, operations personnel can obtain
# backdoor access to the EC2 instances, but this access is not attainable by
# Ansible or by virtue of having access to the Ansible server.

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

POLICY_ID=ansible/hosts/$HOST_ID

# Load the policy
cat /src/ansible/new_instance.yml \
	| sed -e 's;%HOST_ID%;'"$HOST_ID"';g' \
	| conjur policy load --as-role layer:prod/ansible/v1

# Populate policy variables
conjur variable value prod/ansible/v1/ec2/bootstrap_private_key | conjur variable values add "$POLICY_ID"/private_key
conjur variable values add "$POLICY_ID/host" "$HOST_IP"
conjur variable values add "$POLICY_ID/login" ubuntu
conjur variable values add "$POLICY_ID/ec2/instance-id" "$HOST_ID"

# Expire the bootstrap private key (trigger rotation)
conjur variable expire --now "$POLICY_ID/private_key"

conjur role grant_to -a policy:$POLICY_ID group:operations
conjur role revoke_from policy:$POLICY_ID layer:prod/ansible/v1
