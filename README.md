# Enterprise Example Demo

This repository models an example enterprise using Conjur. It includes user groups for development, operations, QA, research, HR, etc, along with the related infrastructure systems such as Jenkins.

YouTube video walkthrough (5 minutes):

[![Video Walkthrough (YouTube)](http://img.youtube.com/vi/vpZQNjns0Ks/0.jpg)](http://www.youtube.com/watch?v=vpZQNjns0Ks)

# Loading the demo policies
To run the demo, clone this repository and load the data using the populate script.

```sh-session
$ git clone https://github.com/conjurdemos/enterprise-example.git
$ cd enterprise-example
$ ./populate.sh
```
This assumes you have the Conjur CLI installed on your machine, and you've already run `conjur init -h $HOSTNAME` to point the CLI to your Conjur server. The script will also prompt to create a new security admin in which all demo records will be owned by.

# System Components

## Global organization

The organization groups are loaded from [policy/groups.yml](./policy/groups.yml). 

Some example groups:

* **employees** a group of which every user is a member
* **operations-admin** a group of HR administrators
* **operations** a group of HR employees, which is administered by the `hr-admin` group.

The rest of the groups follow the same pattern, e.g. `developers` and `developers-admin`. The members of the "admin" group correspond to the team managers. They can add and remove members of the managed group. 

## Policies

The [policy](./policy) folder contains sub-folders, for example `ci`, `prod`. Each of these folders contains Conjur policies that are applied to the corresponding environment.

For example, the [policy/ci](./policy/ci) folder contains policies which govern a Jenkins-based CI system. 

## Entitlements

The entitlements YAML assigns membership in application policy roles to groups from the global organization.

For example, each Layer automatically defines SSH roles `admin_host` and `use_host`. An "entitlement" grants membership in one of these roles to a group (or user) from the global organization. 

# LDAP (WIP)

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
