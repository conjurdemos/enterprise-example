#!/usr/bin/env bash -e

conjur script execute --as-group security_admin users.rb
conjur script execute --as-group security_admin global-secrets.rb
