# Defines the Salt master layer along with an admin group
policy "v1/salt" do
  admin = group "admins"
  
  layer "master" do
    add_member "admin_host", admin
  end
end
