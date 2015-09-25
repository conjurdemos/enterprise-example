#!/usr/bin/env bash
#
# generate_person_name.sh -- Fetch a random name

curl -s https://randomuser.me/api/ | sed -n -e '/"first":/N;s/.*"first": "\(.*\)",.*"last": "\(.*\)".*/\1.\2/p'
