# The host role in this policy will be used by the jobs in a folder called "team-a".
policy "jenkins/team-a" do
  variables = [
    variable('cloud/access_key_id'),
    variable('cloud/secret_access_key')
  ]

  host do
    variables.each {|var| 
      can 'read', var 
      can 'execute', var
    }
  end  
end
