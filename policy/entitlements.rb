employees = group "employees"

# Grant all top-level groups to the employees group
# Grant groups to admin groups
api.groups.each do |group|
  next if group.resource.annotations[:'ldap-sync/source'].nil?
  employees.add_member group
  if group.id =~ /(.*)-admin$/
    api.group($1).add_member group, admin_option: true
  end
end

api.group("prod/bastion/v1/admins").add_member api.group('operations')
api.group("prod/bastion/v1/users").add_member api.group('developers')
api.layer("prod/bastion/v1").permit "execute", api.group('prod/analytics/v1/admins')
api.layer("prod/bastion/v1").permit "execute", api.group('prod/analytics/v1/users')

[
  host('analytics.myorg.com-001'),
  host('analytics.myorg.com-002'),
  host('analytics.myorg.com-003')
].each do |host|
  api.layer("prod/analytics/v1").add_host host
end

[
  host('user-db.dev.myorg.com-001'),
  host('user-db.dev.myorg.com-002'),
].each do |host|
  host.resource.annotations['host_type'] = 'SOX'

  api.layer("prod/user-database/v1").add_host host
end

[
  host('admin.myorg.com')
].each do |host|
  api.layer("prod/admin-ui/v1").add_host host
end

[
  host('app.myorg.com-001'),
  host('app.myorg.com-002'),
  host('app.myorg.com-003'),
  host('app.myorg.com-004'),
  host('app.myorg.com-005')
].each do |host|
  api.layer("prod/frontend/v1").add_host host
end

api.layer("prod/analytics/v1/data-producers").role.grant_to api.layer("prod/frontend/v1")

[
  host('bastion.myorg.com')
].each do |host|
  api.layer("prod/bastion/v1").add_host host
end

[
  host('ubuntu-1'),
  host('ubuntu-2'),
  host('osx-1'),
  host('windows-1')
].each do |host|
  api.layer("prod/jenkins-slaves/v1").add_host host
end

%w(admin-ui/v1 analytics/v1 frontend/v1 user-database/v1).each do |team|
  api.host("prod/jenkins/#{team}").role.grant_to layer("prod/jenkins/v1")
end

authn_tv = resource "webservice", "authn-tv"

api.layer("prod/jenkins/v1").add_host host("jenkins-master")
authn_tv.permit "execute", api.layer("prod/jenkins/v1")
