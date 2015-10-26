group 'employees'

users = YAML.load(File.read(File.expand_path('users.yml', File.dirname(__FILE__)), encoding: "UTF-8"))

groups = users.values.map do |u|
  u['groups']
end.flatten.compact.uniq

groups.each do |gname|
  group gname do |g|
    g.resource.annotations['ldap-sync/source'] = 'Group creation script'
  end
end
