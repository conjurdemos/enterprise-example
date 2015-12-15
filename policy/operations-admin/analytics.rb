policy "analytics/v1" do
  policy_resource.annotations['description'] = 'Manages permissions within the data analysis webservice'

  variables = [
    [variable('redshift/master_user_name'),     "Name of the master user for the Redshift cluster"],
    [variable('redshift/master_user_password'), "Password of the master user for the Redshift cluster"],
    [variable('redshift/database_name'),        "Name of the database to connect to"],
    [variable('redshift/database_url'),         "URL of the database to connect to"]
  ]

  webservices = [
    [resource('webservice'), "HTTP traffic is controlled from permissions on this webservice"]
  ]

  admins = group "admins"
  users  = group "users"

  admins.resource.annotations['description'] = "Members have elevated SSH access privilege to hosts in the 'analytics/v1' layer"
  users.resource.annotations['description']  = "Members have user-level SSH access privilege to hosts in the 'analytics/v1' layer"
  
  group "secrets_managers" do |group|
    group.resource.annotations['description'] = "Members are able to update the value of all secrets within the policy"

    variables.each do |var| 
      can 'read',    var[0]
      can 'execute', var[0]
      can 'update',  var[0]
      var[0].resource.annotations['description'] = var[1]
    end

    group.add_member admins, admin_option: true
  end

  layer do |layer|
    layer.resource.annotations['description'] = "Analytic webservice hosts"

    variables.each do |var| 
      can 'read',    var[0] 
      can 'execute', var[0]
    end

    webservices.each do |webservice|
      can 'update',  webservice[0]
      can 'read',    webservice[0]
      can 'create',  webservice[0]
      webservice[0].annotations['description'] = webservice[1]
    end

    add_member "admin_host", admins
    add_member "use_host",   users
  end

  layer "data-producers" do |layer|
    layer.resource.annotations['description'] = "Hosts which produce analytical data"
    webservices.each do |webservice|
      can 'create', webservice[0]
    end
  end
end