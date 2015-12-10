# The host role in this policy will be used by the jobs in a folder called "".
policy "jenkins/front_end/v1" do
  policy_resource.annotations['description'] = 'This policy declares secrets (via Conjur variables) which are available to Jenkins jobs located within the front_end Jenkins Folder.'
  
  variables = [
    [variable('cloud/access_key_id'), "front_end Jenkins job api key to cloud service"],
    [variable('cloud/secret_access_key'),"front_end Jenkins job secret access key"],
    [variable('rsa_key'),"RSA key to authenticate with an external service"]
  ]

  group "secret_managers" do |group|
    variables.each {|var| 
      can 'read', var[0]
      can 'execute', var[0]
      can 'update', var[0]
      var[0].resource.annotations['description'] = var[1]
    }
  end

  host do |host|    
    host.resource.annotations['kind'] = "Jenkins folder"
    host.resource.annotations['description'] = "Host identity for running Jenkins jobs in front_end folder - can access front_end API keys"    
    variables.each {|var| 
      can 'read', var[0]
      can 'execute', var[0]
    }
  end  
end
