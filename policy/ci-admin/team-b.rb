# The host role in this policy will be used by the jobs in a folder called "team-b".
policy "jenkins/team-b" do
  variables = [
    variable('cloud-2/access_key_id'),
    variable('cloud-2/secret_access_key')
  ]

  host do
    variables.each {|var| 
      can 'read', var 
      can 'execute', var
    }
  end  
end