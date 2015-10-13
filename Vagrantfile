# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provider "virtualbox" do |vb|
     vb.memory = 2048
  end
  config.vm.network :private_network, ip: '192.168.10.11'
  config.vm.hostname = "magento2.vagrant"

  config.vm.synced_folder '.', '/vagrant'
  config.vm.synced_folder '../magento2ce/var/generation', '/var/www/magento2ce/var/generation'
  config.vm.synced_folder '../magento2ce/app/etc', '/var/www/magento2ce/app/etc'

  config.vm.provision "install_environment", type: "shell" do |s|
      s.path = "install_environment.sh"
  end

  config.vm.provision "deploy_magento_code", type: "file", source: '../magento2ce', destination: '/var/www'

  config.vm.provision "install_magento", type: "shell" do |s|
      s.path = "install_magento.sh"
  end
end
