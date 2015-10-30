policy "bastion/v1" do
  users = group "users"
  admins = group "admins"
  
  layer do |l|
    add_member "use_host", users
    add_member "admin_host", admins
    
    host_factory "factory", layers: [ l ], role: policy_role
  end
end
