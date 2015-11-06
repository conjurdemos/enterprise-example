policy "subscriptions" do
  policy_resource.annotations['description'] = 'Research team policy to restrict access to research subscriptions by research hosts and users'

  variables = [
    [variable('researchtoday.com/api-key'), "API key for access to researchtoday.com"],
    [variable('innovation.com/api-key'), "API key for access to innovation.com"],
    [variable('licenses/modeler'), "License for the Research Modeler App"]
  ]

  users  = group "users" do
    users.resource.annotations['description'] = "users group has access to research subscription API keys and licenses to grant users access to subscription web apps"
    variables.each {|var| 
      can 'read', var[0]
      can 'execute', var[0]
      var[0].resource.annotations['description'] = var[1]
    }
  end
end
