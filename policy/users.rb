users = YAML.load(File.read(File.expand_path('users.yml', File.dirname(__FILE__)), encoding: "UTF-8"))
logins = users.keys

users = logins.map do |login|
  user_data = users[login]
  user = user login, ownerid: api.group('security_admin').roleid
  (user_data['groups']||[]).each do |gname|
    api.group(gname).add_member user
  end
  user
end

users.each do |user|
  user.resource.annotations['ldap-sync/source'] = 'ldaps://active-directory'
end
