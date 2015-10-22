policy "qa" do
  variables = [
    variable('ci_tool/api-key'),
    variable('ci_tool/report-api-key')
  ]

  admins = group "admins"
  users  = group "users"
  
  layer do
    variables.each {|var| 
      can 'read', var 
      can 'execute', var
    }
    add_member "admin_host", admins
    add_member "use_host",   users
  end
end
