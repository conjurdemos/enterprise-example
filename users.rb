# coding: utf-8
cwd = File.dirname(__FILE__)
logins = File.open("#{cwd}/names.txt", "r:UTF-8").readlines.map! { |x| x.chomp! }
logins.select! { |x| !x.empty? }

hradmin_logins = logins[0..1]
operation_logins = logins[2..11]
developer_logins = logins[12..42]
research_logins = logins[43..73]

logins.each do |login|
  user login, ownerid: api.group('security_admin').roleid, password: "password"
end

group '/hradmins' do
  hradmin_logins.each { |login| add_member user(login), admin_option: true }
end

group '/employees' do
  logins.each { |login| add_member user(login) }
end

group '/operations' do
  operation_logins.each { |login| add_member user(login), admin_option: true }
end

group '/developers' do
  developer_logins.each { |login| add_member user(login) }
end

group '/researchers' do
  research_logins.each { |login| add_member user(login) }
end
