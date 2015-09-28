%w(june.riley riekje.tieman steven.nelson julius.autio angel.ruiz marian.tucker clara.philippe john.chapman noah.wilson rasmus.kauppi katarina.meij mindy.fredricks dave.bartell carlos.vicente jill.blair russ.reed jason.knight).each do |login|
  user login, ownerid: api.group('security_admin').roleid, password: "password"
end


group '/hradmins' do
  add_member user('june.riley'), admin_option: true
  add_member user('riekje.tieman'), admin_option: true
end

group '/employees' do
  add_member user('steven.nelson')
  add_member user('julius.autio')
  add_member user('angel.ruiz')
  add_member user('marian.tucker')
  add_member user('clara.phillipe')
  add_member user('john.chapman')
  add_member user('noah.wilson')
  add_member user('rasmus.kauppi')
  add_member user('katarina.meij')
  add_member user('jill.blair')
end

group '/operations' do
  add_member user('russ.reed'), admin_option: true
  add_member user('jason.knight'), admin_option: true
end
