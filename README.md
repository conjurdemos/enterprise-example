# Enterprise Example Demo

An HR ops team at a large enterprise is authenticating and authorizing apps against external APIs for insurance and payroll. They are also doing this for internal API for reporting... some users have visibility into this activity (via their role in Conjur) and some don't.

# System Components

## LDAP

The global organization groups and users are provided by an LDAP directory. Conjur can be configured to sync this directory into Conjur Users and Groups. Conjur can also be configured to authenticate users via LDAP password. The combination of these two features makes Conjur an extension of the enterprise IAM system into infrastructure management.

References:

* [LDAP Sync](https://github.com/conjurinc/ldap-sync)
* [LDAP Authn](https://github.com/conjurinc/authn-ldap)

## Policies

* **[optional] Global organization** If the global organization (groups and users) are not available in a directory, they can be loaded by a "users" policy.
* **Application policies** Application behavior are specified by individual Policy files. Each Policy defines the roles, secrets, and layers for the application. 
* **Mapping policy** A global "mapping" policy assigns membership in application policy roles to groups from the global organization. For example, an application role `production/hr-app/key-managers` might be granted to organization group `operations`.

To load a policy:

```
conjur policy load --as-group security_admin --collection prod policy.rb
```

`collection` is the environment your application runs it (ci, prod, sox, etc). All variables will be namespaced
with the collection name like so: '<collection>/<variable_name>'.

# System Details

TODO Describe details of the system components such as LDAP server operation, LDAP sync and LDAP authn configuration, policy files and specific policy loading instructions.

