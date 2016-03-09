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
    docker exec -i conjur-appliance bash -c 'openssl dhparam 256 > /etc/ssl/dhparam.pem'
    docker exec -i conjur-appliance \
      evoke configure master -h $(curl -s http://169.254.169.254/latest/meta-data/public-hostname) \
      -p #{password} #{orgaccount} 
    EOH

  not_if 'docker exec conjur-appliance test -f /opt/conjur/etc/ssl/conjur.pem'
end

bash 'generate UI seed file' do
  code <<-EOH
    set -x
    docker exec -i conjur-appliance \
      evoke seed auditor conjur-ui > /root/conjur-ui-seed.tar
    EOH
  not_if { ::File.exists?('/root/conjur-ui-seed.tar') }
end

service 'conjur-ui' do
  action :restart
  supports :restart => true
end
