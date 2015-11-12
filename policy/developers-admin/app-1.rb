policy "app-1/v1" do
  policy_resource.annotations['description'] = 'Generic template policy to restrict access to app-1'
  variables = [
    [variable('licenses/compiler'), "License for the app-1 compiler"],
    [variable('licenses/profiler'), "License for the app-1 profiler"],
    [variable('licenses/coverity'), "Coverity license"]
  ]

  webservice = resource "webservice"

  admins = group "admins"
  admins.resource.annotations['description'] = "admins group has ssh access with elevated privilege"
  users  = group "users"
  users.resource.annotations['description'] = "users group has ssh access with user privilege"
  
  layer do
    layer.resource.annotations['description'] = "hosts will be added to this layer to grant those hosts access to app-1"
    can 'update', webservice
    variables.each {|var| 
      can 'read', var[0] 
      can 'execute', var[0]
      var[0].resource.annotations['description'] = var[1]
    }
    add_member "admin_host", admins
    add_member "use_host",   users
  end
end
