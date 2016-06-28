# Launch a demo environment.

## Prerequisites

1. Docker
2. CONJURRC file to `conjurops`
3. Summon + Conjur-CLI provider

Install the base `summon` program: 

```
$ brew tap conjurinc/tools
$ brew install summon
```

Install the Conjur-CLI provider (the `conjur` provider is not working with conjurops SSL right now):

```
$ curl -o summon-conjur-cli -sSL https://raw.githubusercontent.com/conjurinc/summon-conjurcli/master/conjurcli.sh
$ chmod a+x summon-conjur-cli
$ mv summon-conjur-cli /usr/local/lib/summon
```

## Launch

You should be logged into `conjurops` to access the AWS credentials and SSH key.

Next, select a name for your demo environment. This name will be the Conjur account name, and 
will also be used to name resources such as the EC2 security group.

```
# Choose a demo name here
$ demo_name=
$ ./bin/startup $demo_name
```

You will see the admin password printed during the launch command output.

```
Configuring Enterprise Example demo kegtest
Admin password: d0c1ea706e5bc79a
```

## Populate the demo data

Enter a Docker container which has the CLI installed and pre-authenticated to your demo Conjur server.
Then load the demo data using `./populate.sh`. You should create a new `security_admin` user account
for yourself.

```
$ docker exec -it ee_cli_kegtest  bash
root@3b630caf94f9:/src# ./populate.sh
...
Create a new security_admin? (answer 'y' or 'yes'):
yes
...
```

## Open the UI

You will see the hostname of the server printed during the launch command output.

```
Configuring Enterprise Example demo kegtest
Admin password: d0c1ea706e5bc79a

PLAY RECAP *********************************************************************
ec2-54-163-192-198.compute-1.amazonaws.com : ok=4    changed=1    unreachable=0    failed=0  
```

Open the UI like this:

```
$ open https://ec2-54-163-192-198.compute-1.amazonaws.com:8443/ui &
```

Login using the security admin username and password you selected earlier.

