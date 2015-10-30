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

api.group("prod/starcluster/v1/cluster-users").add_member api.group('researchers')

[
  host('hr1.myorg.com'),
  host('hr2.myorg.com'),
  host('hr3.myorg.com')
].each do |host|
  host.resource.annotations['host_type'] = 'SOX'
    
  api.layer("prod/hr/v1").add_host host
end

[
  host('app-1-db.dev.myorg.com'),
  host('app-1-frontend.dev.myorg.com'),
  host('app-1-ws.dev.myorg.com')
].each do |host|
  api.layer("prod/app-1/v1").add_host host
end

[
  host('starcluster.myorg.com'),
].each do |host|
  api.layer("prod/starcluster/v1/master").add_host host
end

[
  host('modeling1.myorg.com'),
  host('modeling2.myorg.com'),
  host('modeling3.myorg.com'),
  host('modeling4.myorg.com')
].each do |host|
  api.layer("prod/starcluster/v1/cluster").add_host host
end

qa_hosts = (1..10).map { |i| host("qa#{i}.myorg.com") }

api.variable("prod/qa/v1/ci_tool/report-api-key").permit %w(execute), api.group('developers')

%w(team-a team-b).each do |team|
  api.host("prod/jenkins/#{team}").role.grant_to layer("prod/jenkins/v1")
end

resource "webservice", "authn-tv"

api.layer("prod/jenkins/v1").add_host host("jenkins-master")
api.resource("webservice:authn-tv").permit "execute", api.layer("prod/jenkins/v1")
