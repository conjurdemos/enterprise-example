# This policy scopes privileges of jobs in the "Application Build" Jenkins folder.
# The "Application Build" Jenkins folder itself is given a host identity in Conjur.
# Two variables with secret values are created.
# Privileges of the jobs in the "Application Build" folder on those variables are defined here.
policy "jenkins/analytics_app/v1" do
  policy_resource.annotations['description'] = 'This policy declares secrets (via Conjur variables) which are available to Jenkins jobs located within the analytics-app Jenkins Folder.'
  
  variables = [
    [variable('cloud/access_key_id'), "analytics-app Jenkins job api key to cloud service"],
    [variable('cloud/secret_access_key'),"analytics-app Jenkins job secret access key"],
    [variable('rsa_key'),"RSA key to authenticate with an external service"]
  ]

  group "secret_managers" do |group|
    variables.each do |var| 
      can 'read',    var[0]
      can 'execute', var[0]
      can 'update',  var[0]
      var[0].resource.annotations['description'] = var[1]
    end
  end

  host do |host|    
    host.resource.annotations['kind'] = "Jenkins folder"
    host.resource.annotations['description'] = "Host identity for running Jenkins jobs in analytics-app folder - can access analytics-app API keys"    
    variables.each do |var| 
      can 'read',    var[0]
      can 'execute', var[0]
    end
  end 
end
