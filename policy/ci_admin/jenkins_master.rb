policy "jenkins-master/v1" do
  policy_resource.annotations['description'] = 'This policy governs the Conjur layer which holds the Jenkins master'

  admins = group "admins"
  users  = group "users"

  admins.resource.annotations['description'] = "Members have privileged SSH access to Jenkins masters"
  users.resource.annotations['description']  = "Members have user level SSH access to Jenkins masters"

  layer do
  	layer.resource.annotations['description'] = "Jenkins masters will be added to this layer"
    add_member "admin_host", admins
    add_member "use_host",   users
  end
end
