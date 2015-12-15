# Defines the Salt master layer along with an admin group
policy "salt/v1" do
  admins = group "admins"
  admins.resource.annotations['description'] = "Members have elevated SSH access privilege to hosts in the 'salt/v1/master' layer"

  layer "master" do |layer|
  	layer.resource.annotations['description'] = "Reserved for the salt-master"
    add_member "admin_host", admins
  end
end
