# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.hostname = "vagrant"
  config.vm.box = "ubuntu/trusty64"
  config.vm.synced_folder "www", "/home/vagrant/www"
  config.vm.network :forwarded_port, guest: 80, host: 8080
  config.vm.provision "shell", path: "vagrant/provision.sh"
end
