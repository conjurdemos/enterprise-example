# This policy scopes privileges of jobs in the "Application Build" Jenkins folder.
# The "Application Build" Jenkins folder itself is given a host identity in Conjur.
# Two variables with secret values are created.
# Privileges of the jobs in the "Application Build" folder on those variables are defined here.
policy "jenkins/analytics_app" do
  policy_resource.annotations['description'] = "This policy scopes privileges to Jenkins jobs in the 'Application Build' Jenkins Folder."
  variables = [
    [variable('cloud/access_key_id'), "Application Build jobs use this api key to access a cloud service"],
    [variable('cloud/secret_access_key'),"Application Build jobs use this cloud access key"]
  ]

  host do |host|    
    host.resource.annotations['kind'] = "Jenkins folder"
    host.resource.annotations['description'] = "This host is the Conjur identity of the 'Application Build' Jenkins folder - can access api key."      
    variables.each {|var| 
      can 'read', var[0]
      can 'execute', var[0]
      var[0].resource.annotations['description'] = var[1]
    }
  end  
end
