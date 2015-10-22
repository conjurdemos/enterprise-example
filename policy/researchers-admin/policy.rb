policy "research" do
  variables = [
    variable('researchtoday.com/api-key'),
    variable('innovation.com/api-key'),
    variable('licenses/modeler')
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

