password=ENV['CONJUR_ADMIN_PASSWORD']
raise 'You need to provide a CONJUR_ADMIN_PASSWORD in the environment.' if password.empty?
orgaccount="demo"

cookbook_file '/etc/init/conjur-ui.conf' do
  source 'default/conjur-ui.upstart.conf'
  mode '0644'
end

bash 'configure appliance' do
  code <<-EOH 
    set -x
    docker exec -i conjur-appliance \
      evoke configure master -h $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) \
      -p #{password} #{orgaccount}
    EOH

  not_if 'docker exec conjur-appliance test -f /opt/conjur/etc/ssl/conjur.pem'
end

cli_image='apotterri/conjur-cli'
bash 'bootstrap appliance' do
  code <<-EOH
    docker run -i --rm -v /root/conjurrc:/conjurrc --link conjur-appliance:conjur #{cli_image} conjur init -h conjur -f /conjurrc/.conjurrc <<< "yes"
    docker run -i --rm -v /root/conjurrc:/conjurrc -e CONJURRC=/conjurrc/.conjurrc --link conjur-appliance:conjur #{cli_image} conjur bootstrap <<EOF
      admin
      #{password}
      demo
      demo
      demo
      y
    EOF
    EOH

  not_if { File::exists?('/root/conjurrc/.conjurrc') }
  creates '$HOME/conjurrc/.conjurrc'
end

service 'conjur-ui' do
  action :start
end

