# Defines the Salt master layer along with an admin group
policy "salt/v1" do
  admins = group "admins"
  
  layer "master" do
    add_member "admin_host", admins
  end
end
