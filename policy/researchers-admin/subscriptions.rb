policy "subscriptions" do
  variables = [
    variable('researchtoday.com/api-key'),
    variable('innovation.com/api-key'),
    variable('licenses/modeler')
  ]

  users  = group "users" do
    variables.each {|var| 
      can 'read', var 
      can 'execute', var
    }
  end
end