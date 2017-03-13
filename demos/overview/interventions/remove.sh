#!/usr/bin/env bash
set -eo pipefail

conjur policy load --as-group security_admin interventions/policy/remove_membership.yml