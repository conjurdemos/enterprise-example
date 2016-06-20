# ansible-conjur-provisioning

Launches applications via Ansible with secrets provided from Conjur

# Setup

```
$ ./bin/startup keg_ansible
Creating ee_ansible_keg_ansible
```

# Running

## Enter the Ansible container

```
$ docker exec -it ee_ansible_keg_ansible bash
/src# conjur authn whoami
{"account":"keg_ansible","username":"kgilpin"}
```

## Load the policy

```
/src# conjur policy load --context api-keys.json --as-group operations Conjurfile 
```

## Populate ec2 credentials

Input values for the following variables:

```
/src# cat /root/.ssh/conjur_dev_spudling.pem | conjur variable values add $POLICY/ec2/bootstrap_private_key
Value added
/src# conjur variable values add $POLICY/ec2/key_name spudling
Value added
```

## Login as the `ansible` host

```
/src# export CONJUR_AUTHN_API_KEY="$(conjur host rotate_api_key -h ee/ansible)"
/src# export CONJUR_AUTHN_LOGIN=host/ee/ansible
/src# conjur authn whoami 
{"account":"keg_ansible","username":"host/ee/ansible"}
/src# conjur variable list -i
[
  "keg_ansible:variable:prod/ansible/v1/ec2/bootstrap_private_key",
  "keg_ansible:variable:prod/ansible/v1/ec2/key_name"
]
```

## Launch the host

```
/src# ansible-playbook ansible/launch.yml
```

## Login to the host

```
/src# conjur variable value ansible/hosts/i-1b307c81/private_key > /dev/shm/i-1b307c81.key
/src# chmod 0600 /dev/shm/i-1b307c81.key
/src# ssh -i /dev/shm/i-1b307c81.key -F ssh_config ubuntu@$(conjur variable value ansible/hosts/i-1b307c81/host)
Welcome to Ubuntu 14.04.3 LTS (GNU/Linux 3.13.0-74-generic x86_64)
...
Last login: Mon Jun 13 17:59:53 2016 from c-50-189-92-188.hsd1.ma.comcast.net
ubuntu@ip-10-10-171-19:~$
```

## Extract the HF token

```
/src# token=$(cat /dev/shm/myapp-token.json | jq -r ".[0].token")
/src# conjur hostfactory hosts create $token ec2/i-1b307c81 
{
  "id": "ec2/i-1b307c81",
  "userid": "deputy/myapp",
  "created_at": "2016-06-13T18:16:22Z",
  "ownerid": "cucumber:policy:myapp",
  "roleid": "cucumber:host:ec2/i-1b307c81",
  "resource_identifier": "cucumber:host:ec2/i-1b307c81",
  "api_key": "3njbd2sg0cqzh3yj4qvz7bt5n22p506p0mrvwd52nvsk5915fzct0"
}
```

