# Defines the teamcity server layer along with an admin group
policy "teamcity/v1" do
  admin = group "admin"

  layer "server" do
    add_member "admin_host", admin
  end  
end
