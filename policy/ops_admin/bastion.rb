# Defines the bastion layer along with users and admins
policy "v1/bastion" do
  users  = group "users"
  admins = group "admins"
  
  layer do
    add_member "use_host", users
    add_member "admin_host", admins
  end
end
