# Creating a demo
You can use the Vagrantfile in this directory to start an EC2 instance running a Conjur appliance, along with the Conjur UI. The `policy/populate.sh` script will be used to load some sample data. 

Start by making sure you have the `vagrant-berkshelf` and `vagrant-aws` plugins installed.

You'll need access to either the ci or dev account. Use the corresponding secrets YAML file. If you use the dev account, you'll also need to provide a keypair name and a private key file.

You'll need to pick an admin password, e.g.

```
$ password=$(openssl rand -hex 8)
```

Then, to bring up an EC2 instance, you can do

```
env CONJUR_ADMIN_PASSWORD=$password \
  summon -f secrets.ci.yml vagrant up --provider aws
```

or

```
env CONJUR_ADMIN_PASSWORD=$password \
  summon -f secrets.dev.yml \
  -D AWS_KEYPAIR_NAME=$keypair_name \
  -D AWS_PRIVATE_KEY_PATH=$priv_key_path \
  vagrant up --provider aws
```
