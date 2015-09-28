#!/usr/bin/env bash
#
# generate_person_name.sh -- Fetch a random name

for employee in 1 2 3 4 5 6 7 8 9 10 
do
curl -s https://randomuser.me/api/ | sed -n -e '/"first":/N;s/.*"first": "\(.*\)",.*"last": "\(.*\)".*/\1.\2/p'
done
