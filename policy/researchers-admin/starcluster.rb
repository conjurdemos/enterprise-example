policy "starcluster/v1" do
  admins = group "master-admins"

  cluster_admins = group "cluster-admins"
  cluster_users  = group "cluster-users"
  
  layer "master" do
    add_member "admin_host", admins
  end
  
  layer "cluster" do
    add_member "admin_host", cluster_admins
    add_member "use_host",   cluster_users
  end
end
