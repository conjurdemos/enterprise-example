password=ENV['CONJUR_ADMIN_PASSWORD']
raise 'You need to provide a CONJUR_ADMIN_PASSWORD in the environment.' if password.empty?
orgaccount="demo"

cookbook_file '/etc/init/conjur-ui.conf' do
  source 'default/conjur-ui.upstart.conf'
  mode '0644'
end

cli_env = '/opt/conjur/bin/cli-env'
cookbook_file cli_env do
  source 'default/cli-env'
  mode '0755'
end

=begin
cookbook_file '/opt/conjur/bin/scrub-appliance' do
  source 'default/scrub-appliance'
  mode '0644'
end
=end

bash 'configure appliance' do
  code <<-EOH 
    set -x
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

file '/root/.netrc' do
  mode '0600'
end

bash 'root home' do
  code 'docker create --name root-home -v /root -v /vagrant:/vagrant tianon/true'

  # check to see if the container named 'root-home' exists
  not_if "expr $(docker  ps -q -a -f name=root-home | wc -c) '>' 0"
end

cli_image='conjurinc/conjur-cli'
bash 'conjur init' do
  code <<-EOH
    #{cli_env} conjur init -h conjur <<< "yes"
    EOH

  not_if "#{cli_env} test -f /root/.conjurrc"
end

bash 'conjur bootstrap' do
  code <<-EOH
    #{cli_env} conjur bootstrap <<EOF
      admin
      #{password}
      demo_admin
      #{password}
      #{password}
      n
    EOF && touch /root/bootstrap
    EOH

  not_if "#{cli_env} test -f /root/bootstrap"
end

bash 'install hostfactory plugin' do
  code <<-EOH
    #{cli_env} conjur plugin install host-factory
    touch /root/hostfactory
  EOH

  not_if "#{cli_env} test -f /root/hostfactory"
end

service 'conjur-ui' do
  action :restart
  supports :restart => true
end

