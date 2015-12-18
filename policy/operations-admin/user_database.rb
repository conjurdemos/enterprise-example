policy "user-database/v1" do
  policy_resource.annotations['description'] = 'Manages permissions within the user database'

  variables = [
    {
      :record => variable('postgres/master_user_name'),     
      :description => "Name of the master user for the PostgreSQL database"
    },
    {
      :record => variable('postgres/master_user_password'),
      :description => "Password of the master user for the PostgreSQL database",
      :expiration => "P1D" 
    },
    {
      :record => variable('postgres/database_name'),
      :description => "Name of the database to connect to"
    },
    {
      :record => variable('postgres/database_url'),
      :description => "URL of the database to connect to"
    }
  ]

  admins = group "admins"
  users  = group "users"

  admins.resource.annotations['description'] = "Members have elevated SSH access privilege to hosts in the 'user-database/v1' layer"
  users.resource.annotations['description']  = "Members have user-level SSH access privilege to hosts in the 'user-database/v1' layer"
  
  group "secrets_managers" do |group|
    group.resource.annotations['description'] = "Members are able to update the value of all secrets within the policy"

    variables.each do |var| 
      can 'read',    var[:record]
      can 'execute', var[:record]
      can 'update',  var[:record]
      var[:record].resource.annotations['description'] = var[:description]

      if var.key?(:expiration) then
        var[:record].resource.annotations['expiration/timestamp'] = var[:expiration]
      end
    end

    group.add_member admins, admin_option: true
  end

  layer do
    layer.resource.annotations['description'] = "Hosts in this layer can fetch all 'user-database/v1' variables"

    variables.each do |var| 
      can 'read',    var[:record] 
      can 'execute', var[:record]
    end

    add_member "admin_host", admins
    add_member "use_host",   users
  end
end