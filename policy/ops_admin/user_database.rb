policy "user-database/v1" do
  policy_resource.annotations['description'] = 'Manages permissions within the user database'

  variables = [
    [variable('postgres/master_user_name'),     "Name of the master user for the PostgreSQL database"],
    [variable('postgres/master_user_password'), "Password of the master user for the PostgreSQL database"],
    [variable('postgres/database_name'),        "Name of the database to connect to"],
    [variable('postgres/database_url'),         "URL of the database to connect to"]
  ]

  admins = group "admins"
  users  = group "users"

  admins.resource.annotations['description'] = "Members have elevated SSH access privilege to hosts in the 'user-database/v1' layer"
  users.resource.annotations['description']  = "Members have user-level SSH access privilege to hosts in the 'user-database/v1' layer"
  
  group "secrets_managers" do
    group.resource.annotations['description'] = "Members are able to update the value of all secrets within the policy"

    variables.each {|var| 
      can 'read',    var[0]
      can 'execute', var[0]
      can 'update',  var[0]
      var[0].resource.annotations['description'] = var[1]
    }

    group.add_member admins, admin_option: true
  end

  layer do
    layer.resource.annotations['description'] = "Hosts in this layer can fetch all 'user-database/v1' variables"

    variables.each {|var| 
      can 'read',    var[0] 
      can 'execute', var[0]
    }

    add_member "admin_host", admins
    add_member "use_host",   users
  end
end