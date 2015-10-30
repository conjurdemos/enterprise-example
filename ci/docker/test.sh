#!/bin/bash -e

bundle exec conjur group create security_admin

bundle exec ./populate.sh
