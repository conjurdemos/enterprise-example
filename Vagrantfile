Vagrant.configure(2) do |config|
  config.vm.box = 'phusion/ubuntu-14.04-amd64'

  config.vm.provider :aws do |aws, override|
    override.vm.box_url="https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box"
    
    aws.access_key_id = ENV['AWS_ACCESS_KEY_ID']
    aws.secret_access_key = ENV['AWS_SECRET_ACCESS_KEY']
        
    aws.ami = ENV['AWS_BASE_AMI']
    aws.keypair_name = ENV['AWS_KEYPAIR_NAME']
    aws.instance_type="m3.medium"
    override.ssh.private_key_path = ENV['SSH_PRIVATE_KEY_PATH']
    override.ssh.username = 'ubuntu'

    override.vm.provision :shell, :inline => 'echo "http://$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)/ui"'
  end

  config.vm.provision :chef_solo do |chef|
    chef.binary_env="CONJUR_ADMIN_PASSWORD=#{ENV['CONJUR_ADMIN_PASSWORD']}"
    chef.add_recipe 'enterprise-example::default'
  end

  config.vm.provision :shell, :name => 'Populating appliance',
    inline: "/opt/conjur/bin/cli-env /bin/bash -c 'cd /vagrant; ./populate.sh >/vagrant/populate.log 2>&1'"

end
