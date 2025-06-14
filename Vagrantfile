# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.define "server" do |server|
    server.vm.box = "hashicorp-education/ubuntu-24-04"
    server.vm.provision "shell", path: "server.sh"
    server.vm.network "forwarded_port", guest: 6443, host: 6443
    server.vm.hostname = "server"
    server.vm.network "private_network", ip: "192.168.56.10"
  end

  config.vm.define "node1" do |node1|
    node1.vm.box = "hashicorp-education/ubuntu-24-04"
    node1.vm.provision "shell", path: "worker.sh"
    node1.vm.hostname = "node-1"
    node1.vm.network "private_network", ip: "10.200.0.12"
  end

  config.vm.define "node2" do |node2|
    node2.vm.box = "hashicorp-education/ubuntu-24-04"
    node2.vm.provision "shell", path: "worker.sh"
    node2.vm.hostname = "node-2"
    node2.vm.network "private_network", ip: "10.200.1.14"
  end

end
