policy "hr/v1" do
  policy_resource.annotations['description'] = 'Human Resources team policy to restrict access to HR web services'
  variables = [
    [variable('workday/REST/api-key'),"key for access to Workday REST API"],
    [variable('workday/R-a-a-S/api-key'), "API key for access to Workday Reporting-as-a-Service"],
    [variable('mybank.com/api-key'), "API key for access to mybank.com"],
    [variable('myinsurance.com/api-key'), "API key for access to myinsurance.com"]
  ]
  
  admins = group "admins"
  admins.resource.annotations['description'] = "admins group has access with elevated privilege"
  users  = group "users"
  users.resource.annotations['description'] = "users group has ssh access with user privilege"

  layer do
    layer.resource.annotations['description'] = "hosts will be added to this layer to grant them access to Human Resources web services"
    variables.each {|var| 
      can 'read', var[0]
      can 'execute', var[0]
      var[0].resource.annotations['description'] = var[1]
    }
    layer.add_member "admin_host", admins
    layer.add_member "use_host",   users
  end
end
