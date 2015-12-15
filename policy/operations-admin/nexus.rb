policy "nexus/v1" do
  admins = group "admins"
  users  = group "users"

  users.resource.annotations['description']  = "Members have user-level SSH access privilege to hosts in the 'nexus/v1' layer"
  admins.resource.annotations['description'] = "Members have elevated SSH access privilege to hosts in the 'nexus/v1' layer"

  layer do
  	layer.resource.annotations['description'] = "Reserved for Repository Manager hosts"
    add_member "admin_host", admins
    add_member "use_host", users
  end
end