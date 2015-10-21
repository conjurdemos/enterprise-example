# coding: utf-8
cwd = File.dirname(__FILE__)
File.open("#{cwd}/names.txt", "r:UTF-8").readlines.each do |login|
  login.chomp!
  if !login.empty? then
    user login, ownerid: api.group('security_admin').roleid, password: "password"
  end   
end
