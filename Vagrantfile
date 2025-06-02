# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  config.vm.define "server" do |server|
    server.vm.box = "hashicorp-education/ubuntu-24-04"
    # server.vm.provision "shell", path: "server.sh"
    # server.vm.network "forwarded_port", guest: 8080, host: 8080
    # server.vm.network "forwarded_port", guest: 3100, host: 3100
    # server.vm.network "forwarded_port", guest: 12345, host: 12345
    # server.vm.network "forwarded_port", guest: 9090, host: 9090
    # server.vm.network "forwarded_port", guest: 9100, host: 9100
    server.vm.hostname = "server"
    server.vm.network "private_network", ip: "192.168.56.10"
  end

  config.vm.define "client" do |client|
    client.vm.box = "hashicorp-education/ubuntu-24-04"
    client.vm.provision "shell", path: "server.sh"
    client.vm.hostname = "client"
    client.vm.network "private_network", ip: "192.168.56.33"
  end

end
