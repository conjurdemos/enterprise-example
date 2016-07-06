# ansible-conjur-provisioning

Launches applications via Ansible with secrets provided from Conjur

# Setup

```
$ demo_name=keg
$ ./bin/startup $demo_name
Creating ee_demos_ansible_keg
```

# Running

## Enter the Ansible container

```
$ docker exec -it ee_demos_ansible_keg $demo_name
/src# conjur authn whoami
{"account":"keg","username":"kgilpin"}
```

## Populate ec2 credentials

Setup the credentials.

* Ansible needs an SSH connection, so put the private key into the ssh-agent
* Ansible needs to know the EC2 SSH key name and key plaintext
* Create a host factory token for the `frontend/v1` application.

```
/src# ssh-agent bash
/src# echo "$SSH_PRIVATE_KEY" | ssh-add -
/src# echo "$SSH_PRIVATE_KEY" | conjur variable values add $POLICY/ec2/bootstrap_private_key
Value added
/src# conjur variable values add $POLICY/ec2/key_name "$AWS_KEYPAIR_NAME"
Value added
/src# conjur variable expire -n $POLICY/host-factory/frontend
Variable expired
/src# sleep 5
/src# conjur audit resource -s variable:$POLICY/host-factory/frontend | tail -n 5
...
[2016-06-21 17:33:16 UTC] keg:host:conjur/secrets-rotator reported rotation:rotate
```

## Login as the `ansible` host

```
/src# export CONJUR_AUTHN_API_KEY="$(conjur host rotate_api_key -h ansible.ee)"
/src# export CONJUR_AUTHN_LOGIN=host/ansible.ee
/src# conjur authn whoami 
{"account":"keg","username":"host/ansible.ee"}
/src# conjur variable list -i
[
  "keg:variable:prod/ansible/v1/host-factory/frontend",
  "keg:variable:prod/ansible/v1/ec2/bootstrap_private_key",
  "keg:variable:prod/ansible/v1/ec2/key_name"
]
```

## Launch the new instance

```
/src# ansible-playbook \
  -vvv \
  -u ubuntu \
  -i ./ansible/ec2.py \
  -b \
  -e hostfactory_token=$(conjur variable value $POLICY/host-factory/frontend) \
  ansible/launch.yml
```

## Login to the instance

```
/src# conjur variable value ansible/hosts/i-1b307c81/private_key > /dev/shm/i-1b307c81.key
/src# chmod 0600 /dev/shm/i-1b307c81.key
/src# ssh -i /dev/shm/i-1b307c81.key ubuntu@$(conjur variable value ansible/hosts/i-1b307c81/host)
Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.13.0-74-generic x86_64)
...
Last login: Mon Jun 13 17:59:53 2016 from c-50-189-92-188.hsd1.ma.comcast.net
ubuntu@ip-10-10-171-19:~$
```

