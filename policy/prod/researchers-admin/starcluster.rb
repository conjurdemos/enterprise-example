policy "starcluster/v1" do
  policy_resource.annotations['description'] = 'Research admins starcluster team policy to restrict access to starcluster hosts'
  admins = group "master-admins"
  admins.resource.annotations['description'] = "admins group has ssh access with elevated privilege to starcluster master machines in layer master"

  cluster_admins = group "cluster-admins"
  cluster_admins.resource.annotations['description'] = "cluster_admins group has ssh access with elevated privilege to cluster machines in layer cluster"
  cluster_users  = group "cluster-users"
  cluster_users.resource.annotations['description'] = "cluster_users group has ssh access with user privilege to cluster machines in layer cluster"

  layer "master" do
    layer.resource.annotations['description'] = "starcluster master hosts will be added to this layer"
    add_member "admin_host", admins
  end
  
  layer "cluster" do
    layer.resource.annotations['description'] = "starcluster cluster hosts will be added to this layer"
    add_member "admin_host", cluster_admins
    add_member "use_host",   cluster_users
  end
end
