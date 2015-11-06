policy "qa/v1" do
  policy_resource.annotations['description'] = 'QA team policy to restrict access to API keys for web services needed by QA apps'
  variables = [
    [variable('ci_tool/api-key'),"key for access to Continuous Integration (CI) web service"],
    [variable('ci_tool/report-api-key'),"key for access to Continuous Integration (CI) Reporting web service"]
  ]

  admins = group "admins"
  admins.resource.annotations['description'] = "admins group has ssh access with elevated privilege to QA host machines"
  users  = group "users"
  users.resource.annotations['description'] = "users group has ssh access with user privilege to QA host machines"

  layer do
    layer.resource.annotations['description'] = "hosts will be added to this layer to grant those hosts access to QA API keys and secrets"
    variables.each {|var| 
      can 'read', var[0]
      can 'execute', var[0]
      var[0].resource.annotations['description'] = var[1]
    }
    add_member "admin_host", admins
    add_member "use_host",   users
  end
end
