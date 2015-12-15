# The host role in this policy will be used by the jobs in a folder called "admin-ui".
policy "jenkins/admin-ui/v1" do
  policy_resource.annotations['description'] = 'This policy declares secrets (via Conjur variables) which are available to Jenkins jobs located within the admin-ui Jenkins Folder.'
  variables = [
    [variable('cloud/access_key_id'), "admin-ui Jenkins job api key to cloud service"],
    [variable('cloud/secret_access_key'),"admin-ui Jenkins job secret access key"]
  ]

  group "secret_managers" do |group|
    group.resource.annotations['description'] = "Members are able to update the value of all secrets within the policy"

    variables.each do |var| 
      can 'read',    var[0]
      can 'execute', var[0]
      can 'update',  var[0]
      var[0].resource.annotations['description'] = var[1]
    end
  end

  host do |host|    
    host.resource.annotations['kind'] = "Jenkins folder"
    host.resource.annotations['description'] = "Host identity for running Jenkins jobs in admin-ui folder - can access admin-ui API keys"    
    variables.each {|var| 
      can 'read', var[0]
      can 'execute', var[0]
      var[0].resource.annotations['description'] = var[1]
    }
  end  
end
