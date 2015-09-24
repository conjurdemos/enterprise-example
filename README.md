# fantasy-football-demo
A fantasy football application protected with Conjur

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
