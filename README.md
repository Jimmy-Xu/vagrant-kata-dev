
# Dependency

- libvirt (4.5.0)
- qemu-kvm (1.5.3)
- ruby (2.6)
  - ruby-libvirt (0.7.1)
- vagrant (2.2.6)
  - vagrant-libvirt (0.0.45)
  - vagrant-hostmanager (1.8.9)
  - vagrant-proxyconf (2.0.7)
  - vagrant-sshfs (1.3.1)
  - vagrant-mutate (1.2.0)

# Usage

## install scl and ruby first
```

$ sudo -E yum install -y centos-release-scl
$ sudo -E yum install -y rh-ruby26 rh-ruby26-ruby-devel rh-ruby26-ruby-libs
$ scl enable rh-ruby26 bash
```

## clone vagrant-kata-dev
```
$ git clone https://github.com/jimmy-xu/vagrant-kata-dev
$ cd vagrant-kata-dev
```


## prepare

```
//install vagrant and plugins
$ ./util.sh ensure_dependency centos

//download vagrant box
$ ./util.sh prepare_image
```

## start guest
```
$ ./util.sh run
```

## query guest
```
$ ./util.sh list
Id    名称                         状态
1     vagrant-kata-dev_default       running

$ ./util.sh config
Host default
  HostName 192.168.121.188
  User vagrant
  Port 22
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /home/xjimmy/gopath/src/github.com/jimmy-xu/vagrant-kata-dev/.vagrant/machines/default/libvirt/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

## enter guest
```
$ ./util.sh ssh
```
