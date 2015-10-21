api.group("v1/hr/admins").add_member api.group('hr')

api.group("v1/development/admins").add_member api.group('developers')

[
  host('hr1.myorg.com'),
  host('hr2.myorg.com'),
  host('hr3.myorg.com')
].each do |host|
  host.resource.annotations['host_type'] = 'SOX'
    
  api.layer("v1/hr").add_host host
end

[
  host('db-dev.myorg.com'),
  host('build1.myorg.com'),
  host('build2.myorg.com')
].each do |host|
  api.layer("v1/development").add_host host
end

[
  host('modeling1.myorg.com'),
  host('modeling2.myorg.com'),
  host('modeling3.myorg.com'),
  host('modeling4.myorg.com'),
  host('scope.myorg.com')
].each do |host|
  api.layer("v1/research").add_host host
end

qa_hosts = (1..10).map { |i| host("qa#{i}.myorg.com") }

api.variable('v1/qa/ci_tool/report-api-key').permit %w(execute), api.group('developers')

%w(team-a team-b).each do |team|
  api.host("v1/jenkins/#{team}").role.grant_to layer("v1/jenkins")
end
