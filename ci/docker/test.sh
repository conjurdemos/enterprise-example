#!/bin/bash -e

bundle exec conjur group create security_admin

# See https://www.pivotaltracker.com/story/show/106504504
bundle exec ./populate.sh || true
bundle exec ./populate.sh
