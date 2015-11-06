# The host role in this policy will be used by the jobs in a folder called "team-a".
policy "jenkins/team-a" do
  policy_resource.annotations['description'] = 'This policy declares secrets (via Conjur variables) which are available to Jenkins jobs located within the team-a Jenkins Folder.'
  variables = [
    [variable('cloud/access_key_id'), "team-a Jenkins job api key to cloud service"],
    [variable('cloud/secret_access_key'),"team-a Jenkins job secret access key"]
  ]

  host do |host|    
    host.resource.annotations['kind'] = "Jenkins folder"
    host.resource.annotations['description'] = "Host identity for running Jenkins jobs in team-a folder - can access team-a API keys"    
    variables.each {|var| 
      can 'read', var[0]
      can 'execute', var[0]
      var[0].resource.annotations['description'] = var[1]
    }
  end  
end
