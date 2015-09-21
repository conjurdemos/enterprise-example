%w(mindy.fredricks dave.bartell carlos.vicente jill.blair russ.reed jason.knight).each do |login|
  user login, ownerid: api.group('security_admin').roleid, password: "password"
end


group '/operations' do
  add_member user('mindy.fredricks'), admin_option: true
  add_member user('dave.bartell')
end

group '/developers' do
  add_member user('carlos.vicente'), admin_option: true
  add_member user('jill.blair')
end

group '/contractors' do
  add_member user('russ.reed'), admin_option: true
  add_member user('jason.knight')
end
