# Enterprise Example Demo

This repository models an example enterprise using Conjur. It includes user groups for development, operations, QA, research, HR, etc, along with the related infrastructure systems such as Jenkins.

YouTube video walkthrough (5 minutes):

[![Video Walkthrough (YouTube)](http://img.youtube.com/vi/vpZQNjns0Ks/0.jpg)](http://www.youtube.com/watch?v=vpZQNjns0Ks)

# Running the demo

* Request a Conjur demo appliance at https://demo-factory-conjur.herokuapp.com/request/secrets
* Once you receive the email, `ssh` to the demo machine using the information provided
* Clone the repository and load the data:

```sh-session
$ git clone git@github.com:conjurdemos/enterprise-example.git
$ cd enterprise-example
$ ./populate.sh
```

If the `./populate.sh` script quits with an error `error: "\xC3" from ASCII-8BIT to UTF-8`, simply run it again.

Once the demo data is loaded, you can open the Conjur UI at `http://ec2-your-machine-name.amazonaws.com/ui/`. Your login credentials are `demo / demo`.

# System Components

## Global organization

The organization groups are loaded from the Conjur DSL script  [groups.rb](https://github.com/conjurdemos/enterprise-example/blob/master/policy/groups.rb). 

Some example groups:

* **employees** a group of which every user is a member
* **operations-admin** a group of HR administrators
* **operations** a group of HR employees, which is administered by the `hr-admin` group.

The rest of the groups follow the same pattern, e.g. `developers` and `developers-admin`. The members of the "admin" group correspond to the team managers. They can add and remove members of the managed group. 

## Policies

The [policy](https://github.com/conjurdemos/enterprise-example/tree/master/policy) folder contains sub-folders, for example `ci-admin`, `developers-admin`. Each of these folders contains Conjur DSL policies that are owned by the group corresponding to the folder name. 

For example, the [ci-admin](https://github.com/conjurdemos/enterprise-example/tree/master/policy/ci-admin) folder contains policies which govern the Jenkins system. The [jenkins](https://github.com/conjurdemos/enterprise-example/blob/master/policy/ci-admin/jenkins.rb) policy governs the Conjur layer which holds the Jenkins master and slave machines. [Jenkins team](https://github.com/conjurdemos/enterprise-example/blob/master/policy/ci-admin/team-a.rb) policies declare secrets (via Conjur variables) which are available to Jenkins jobs located within the corresponding Jenkins Folder. This integration is performed by the Conjur plugin for Jenkins, which is not part of this repository.

## Entitlements

The entitlements DSL script assigns membership in application policy roles to groups from the global organization.

For example, when a declares a Layer, it typically also declares two user groups: `admins` and `users`. The `admins` have admin SSH access to the machines in the layer. The `users` have non-admin SSH access.

An "entitlement" grants membership in one of these policy-specific groups to a user or group from the global organization. For example, the `hr` group is added to the group `v2/hr/admins`, and as a result the `hr` team can SSH admin the machines in the `v2/hr` layer.

# LDAP

The global organization groups and users can be  provided by an LDAP directory. Conjur can be configured to sync this directory into Conjur Users and Groups. Conjur can also be configured to authenticate users via LDAP password. The combination of these two features makes Conjur an extension of the enterprise IAM system into infrastructure management.

References:

* [LDAP Sync](https://developer.conjur.net/server_setup/tools/ldap_sync.html)
* [LDAP Authn](https://developer.conjur.net/server_setup/tools/authn_ldap.html)

```
$ ruby policy/ldif.rb policy/users.yml docker-ldap/ldif/users.ldif
$ docker build -t enterprise-example-ldap docker-ldap
$ docker run --name ldap --rm -i -P enterprise-example-ldap
$ $port=$(docker port ldap 3897 | tail -c 6)
$ ldapsearch -h $DOCKER_HOST -p $port -x -b dc=example,dc=com
...
prints out lots of LDIF
...
```
