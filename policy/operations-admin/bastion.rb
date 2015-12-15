# Defines the bastion layer along with users and admins
policy "bastion/v1" do
  users  = group "users"
  admins = group "admins"
  
  users.resource.annotations['description']  = "Members have user-level SSH access privilege to hosts in the 'bastion/v1' layer"
  admins.resource.annotations['description'] = "Members have elevated SSH access privilege to hosts in the 'bastion/v1' layer"

  layer do
    layer.resource.annotations['description'] = "Reserved for bastion hosts"
    add_member "use_host", users
    add_member "admin_host", admins
  end
end
