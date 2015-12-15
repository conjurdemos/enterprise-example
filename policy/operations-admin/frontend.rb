policy "frontend/v1" do
  policy_resource.annotations['description'] = 'Manages permissions within the Front-end web application'

  variables = [
    [variable('ssl/private-key'), "Private key for communication over SSL"]
  ]

  admins = group "admins"
  users  = group "users"

  admins.resource.annotations['description'] = "Members have elevated SSH access privilege to hosts in the 'frontend/v1' layer"
  users.resource.annotations['description']  = "Members have user-level SSH access privilege to hosts in the 'frontend/v1' layer"
  
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

  layer do
    layer.resource.annotations['description'] = "Hosts in this layer can fetch all 'frontend/v1' variables"

    variables.each do |var| 
      can 'read',    var[0] 
      can 'execute', var[0]
    end

    add_member "admin_host", admins
    add_member "use_host",   users
  end
end