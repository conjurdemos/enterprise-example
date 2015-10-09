cwd = File.dirname(__FILE__)
logins = File.open("#{cwd}/names.txt", "r:UTF-8").readlines.map! { |x| x.chomp! }

logins.each do |login|
  login.chomp!
  if !login.empty? then
    user login, ownerid: api.group('security_admin').roleid, password: "password"
  end   
end

group '/hradmins' do
  add_member user('june.riley'), admin_option: true
  add_member user('riekje.tieman'), admin_option: true
end

group '/employees' do
  logins.each { |login| add_member user(login) }
end

group '/operations' do
  add_member user('russ.reed'), admin_option: true
  add_member user('jason.knight'), admin_option: true
  add_member user('kyle.wheeler'), admin_option: true
  add_member user('marin.dubois'), admin_option: true
  add_member user('carol.rodriquez'), admin_option: true
  add_member user('karen.wood'), admin_option: true
  add_member user('caroline.mccoy'), admin_option: true
  add_member user('june.riley'), admin_option: true
  add_member user('riekje.tieman'), admin_option: true
end
