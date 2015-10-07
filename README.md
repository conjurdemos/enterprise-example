# Human Resources Department Demo

An HR ops team at a large enterprise is authenticating and authorizing apps against external apis for insurance and payroll. They are also doing this for internal api for reporting... some users have visibility into this activity (via their role in conjur) and some don't.

## Policy as Code

Our security policy is defined in `policy.rb`. This defines variables (credentials) and
the human and non-human actors that can act on them.

To load the policy:

```
conjur policy load --as-group security_admin --collection dev policy.rb
```

`collection` is the environment your application runs it. All variables will be namespaced
with the collection name like so: '<collection>/<variable_name>'.

To populate an initial set of users:

```
./populate.sh
```

which runs an Expect (populate.exp) script to add the users, then adds the
users to groups, possibly with admin privilege.  (Expect automates the
interaction required to supply and confirm passwords.)
