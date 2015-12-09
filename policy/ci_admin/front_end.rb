# This policy scopes privileges of jobs in the "Front End" Jenkins folder.
# The "Front End" Jenkins folder itself is given a host identity in Conjur.
# Two variables with secret values are created.
# Privileges of the jobs in the "Front End" folder on those variables are defined here.

policy "jenkins/front_end" do
  policy_resource.annotations['description'] = "This policy scopes privileges to Jenkins jobs in the 'Front End' Jenkins Folder."
  variables = [
    [variable('cloud/access_key_id'), "Front End jobs use this api key to access a cloud service"],
    [variable('cloud/secret_access_key'),"Front End jobs use this cloud access key"]
  ]

  host do |host|    
    host.resource.annotations['kind'] = "Jenkins folder"
    host.resource.annotations['description'] = "This host is the Conjur identity of the 'Front End' Jenkins folder"    
    variables.each {|var| 
      can 'read', var[0]
      can 'execute', var[0]
      var[0].resource.annotations['description'] = var[1]
    }
  end  
end
