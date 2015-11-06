policy "bastion/v1" do
  policy_resource.annotations['description'] = 'Policy to restrict access to bastion hosts'
  admins = group "admins"
  admins.resource.annotations['description'] = "admins group has ssh access to the bastion hosts with elevated privilege"
  users  = group "users"
  users.resource.annotations['description'] = "users group has ssh access to the bastion hosts with user privilege"
  
  layer do |l|
  	layer.resource.annotations['description'] = "bastion hosts will be added to this layer to restrict access"
    add_member "use_host", users
    add_member "admin_host", admins
    
    host_factory "factory", layers: [ l ], role: policy_role
  end
end
