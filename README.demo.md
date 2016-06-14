# Creating a demo
You can use the Vagrantfile in this directory to start an EC2 instance running a Conjur appliance, along with the Conjur UI. The `policy/populate.sh` script will be used to load some sample data. 

Start by making sure you have the `vagrant-berkshelf` and `vagrant-aws` plugins installed.

You'll need summon installed and the summon-conjurcli provider (conjurcli.sh) in /usr/libexec/summon.
You should be logged into conjurops with the conjur cli to access the aws account info.
You'll need access to either the ci or dev account. Use the corresponding secrets YAML file. If you use the dev account, you'll also need to provide a keypair name and a private key file.

You'll need to pick an admin password, e.g.

```
$ export CONJUR_ADMIN_PASSWORD=$(openssl rand -hex 8)
```

Then, to bring up an EC2 instance, you can do

```
$ summon -f secrets.ci.yml -D CONJUR_ADMIN_PASSWORD=$CONJUR_ADMIN_PASSWORD vagrant up --provider aws
```

or

```
$ summon -f secrets.dev.yml \
  -D AWS_KEYPAIR_NAME=mykey \
  -D AWS_PRIVATE_KEY_PATH=$HOME/.ssh/id_rsa \
  -D CONJUR_ADMIN_PASSWORD=$CONJUR_ADMIN_PASSWORD \
  vagrant up --provider aws
```

After the Conjur appliance and Conjur UI setup is complete on the EC2 instance, you will see the hostname of
the instance near the end of the output included in the URL to use to launch the Conjur UI, e.g.

```INFO interface: info: ==> default: http://ec2-xx-xxx-xxx-xx.compute-1.amazonaws.com/ui```

To ssh into the instance, use summon to pass the correct variables to vagrant ssh, e.g.

```
summon -f secrets.dev.yml \
  -D AWS_KEYPAIR_NAME=$keypair_name \
  -D AWS_PRIVATE_KEY_PATH=$priv_key_path \
  vagrant ssh
```
