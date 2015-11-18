policy "bastion/v1" do
  policy_resource.annotations['description'] = 'Policy to restrict access to bastion hosts'
  admins = group "admins"
  admins.resource.annotations['description'] = "This group has admin privilege on the bastion hosts in the prod/bastion/v1 layer"
  users  = group "users"
  users.resource.annotations['description'] = "This group has user-level privilege on the bastion hosts in the prod/bastion/v1 layer"
  
  layer do |l|
  	layer.resource.annotations['description'] = "This layer is designated for internet-facing machines that accept external connections"
    add_member "use_host", users
    add_member "admin_host", admins
    
    host_factory "factory", layers: [ l ], role: policy_role
  end
end
