# -*- mode: ruby -*-
# vi: set ft=ruby :

BOX_IMAGE = "libvirt/centos/7"
#BOX_IMAGE = "alios_20190923"
HOSTNAME = "kata-dev"

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-proxyconf")
    config.proxy.http     = "http://172.16.87.1:8118/"
    config.proxy.https    = "http://172.16.87.1:8118/"
    config.proxy.no_proxy = "localhost,127.0.0.0/8,::1,/var/run/docker.sock,172.16.87.1"
  end

  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  config.vm.box = BOX_IMAGE
  config.vm.box_check_update = false
  config.vm.hostname = HOSTNAME
  config.hostmanager.enabled = true
  config.hostmanager.manage_guest = true
  config.hostmanager.manage_host = true
  config.hostmanager.ignore_private_ip = false


  config.hostmanager.ip_resolver = proc do |machine|
    result = ""
    machine.communicate.execute("hostname -I | cut -d ' ' -f 2") do |type, data|
      result << data if type == :stdout
    end
    ip = result.split("\n").first[/(\d+\.\d+\.\d+\.\d+)/, 1]
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  config.vm.network :public_network,
   :dev => "virbr1",
   :mode => "bridge",
   :type => "bridge"


  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  config.vm.provider "libvirt" do |libvirt|
    # Customize the amount of memory on the VM:
    libvirt.memory = "2048"
    libvirt.cpus = "2"

    # Management network device
    libvirt.management_network_device = 'virbr0'
  end
  #
  # View the documentation for the provider you are using for more
  # information on available options.


  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  if Vagrant.has_plugin?("vagrant-sshfs")
    config.vm.synced_folder "./lib/guest", "/home/vagrant/script", type: "sshfs"   # fuse-sshfs will be installed in guest vm
  end


  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  config.vm.provision "shell", inline: <<-SHELL
      # sudo -E yum install -y epel-release
      # wget -c http://mirror.centos.org/centos/7/os/x86_64/Packages/fuse-2.9.2-11.el7.x86_64.rpm
      # sudo -E yum reinstall -y fuse-2.9.2-11.el7.x86_64.rpm
  SHELL

end
