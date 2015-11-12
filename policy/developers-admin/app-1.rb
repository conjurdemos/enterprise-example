policy "app-1/v1" do
  policy_resource.annotations['description'] = 'Generic template policy to restrict access to app-1'
  variables = [
    [variable('licenses/compiler'), "License for the app-1 compiler"],
    [variable('licenses/profiler'), "License for the app-1 profiler"],
    [variable('licenses/coverity'), "License for Coverity"]
  ]

  webservice = resource "webservice"

  admins = group "admins"
  admins.resource.annotations['description'] = "This group has elevated ssh access privilege to hosts in the prod/app-1/v1 layer"
  users  = group "users"
  users.resource.annotations['description'] = "This group has user-level ssh access privilege to hosts in the prod/app-1/v1 layer"
  
  layer do
    layer.resource.annotations['description'] = "Hosts in this layer are granted access privilege to app-1"
    variables.each {|var| 
      can 'read', var[0] 
      can 'execute', var[0]
      var[0].resource.annotations['description'] = var[1]
    }
    add_member "admin_host", admins
    add_member "use_host",   users
  end
end
