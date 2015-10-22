#!/usr/bin/env ruby

# Policy ownership is broken; the policy resource should be owned by the policy role
# The policy role should be granted to the owning group with admin option

security_admin = api.group('security_admin')

api.resources(kind: 'policy').each do |resource|
  resource.give_to security_admin
  api.role("policy:#{resource.identifier}").grant_to security_admin, admin_option: true
end
