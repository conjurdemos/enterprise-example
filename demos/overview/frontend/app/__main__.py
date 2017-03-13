#!/usr/bin/env python

import os
import sys
import conjur

conjur.configure(appliance_url='https://conjur/api', 
  account='demo',
  cert_file='~/conjur-demo.pem')


env = os.environ.get('ENVIRONMENT') or 'prod'

try:
  conjur_api = conjur.new_from_netrc()
except:
  sys.stderr.write('Not logged in to Conjur.\n')

private_key = conjur_api.variable('{}/frontend/v1/ssl/private_key'.format(env)).value()
certificate = conjur_api.variable('{}/frontend/v1/ssl/certificate'.format(env)).value()

print("Hello World!")