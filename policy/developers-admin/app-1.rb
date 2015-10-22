policy "app-1" do
  variables = [
    variable('licenses/compiler'),
    variable('licenses/profiler'),
    variable('licenses/coverity'),
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
