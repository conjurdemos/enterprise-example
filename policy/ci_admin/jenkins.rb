policy "jenkins/v1" do
  policy_resource.annotations['description'] = 'This policy governs the Conjur layer which holds the Jenkins master and slave machines'

  admins = group "admins"
  admins.resource.annotations['description'] = "admins group has privileged SSH access to Jenkins master and slave hosts"
  users  = group "users"
  users.resource.annotations['description'] = "users group has user level SSH access to Jenkins master and slave hosts"

  layer do
  	layer.resource.annotations['description'] = "Jenkins master and slave hosts will be added to this layer so admins and users can access"
    add_member "admin_host", admins
    add_member "use_host",   users
  end
end
