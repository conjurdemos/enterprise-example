policy "hr" do
  variables = [
    variable('app1'),
    variable('reporting-api-key'),
    variable('mybank.com/api-key'),
    variable('myinsurance.com/api-key')
  ]
  
  admins = group "admins"
  users  = group "users"
  
  layer do |layer|
    variables.each {|var| 
      can 'read', var 
      can 'execute', var
    }
    layer.add_member "admin_host", admins
    layer.add_member "use_host",   users
  end
end
