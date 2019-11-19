FAQ
============================

# no polkit agent available to authenticate action 'org.libvirt.unix.manage'

Error occur when run vagrant up
```
Error while connecting to libvirt: Error making a connection to libvirt URI qemu:///system?no_verify=1&keyfile=/home/xjimmy/.ssh/id_rsa:
Call to virConnectOpen failed: authentication unavailable: no polkit agent available to authenticate action 'org.libvirt.unix.manage'
```
Solution
```
REF: https://www.c5a3.com/p/497

$ cat /etc/polkit-1/localauthority/50-local.d/50-org.libvirt-group-access.pkla
[libvirt group Management Access]
Identity=unix-group:libvirt
Action=org.libvirt.unix.manage
ResultAny=yes
ResultInactive=yes
ResultActive=yes

$ groupadd libvirt
$ usermod -a -G libvirt ${USERNAME}
```


# enable kvm nested

enable nested for kvm_intel module in host
```
//创建配置文件
$ cat /etc/modprobe.d/kvm-nested.conf
options kvm_intel nested=1
options kvm-intel enable_shadow_vmcs=1
options kvm-intel enable_apicv=1
options kvm-intel ept=1

//重新加载 kvm_intel
modprobe -r kvm_intel   #协助掉内核中的kvm_intel模块，注意要在所有虚拟机都关闭的情况下执行
modprobe -a kvm_intel   #重新加载该模块

//确认
$ cat /sys/module/kvm_intel/parameters/nested
Y
```

# Name `vagrant-kata-dev_default` of domain about to create is already taken. Please try to run `vagrant up` command again.

```
$ sudo virsh list --all
 Id    名称                         状态
----------------------------------------------------
 -     vagrant-kata-dev_default       关闭

$ sudo virsh undefine vagrant-kata-dev_default
域 vagrant-kata-dev_default 已经被取消定义

$ ./util.sh destroy
```

# The provider for this Vagrant-managed machine is reporting that it is not yet ready for SSH.

error
```
The provider for this Vagrant-managed machine is reporting that it
is not yet ready for SSH. Depending on your provider this can carry
different meanings. Make sure your machine is created and running and
try again. Additionally, check the output of `vagrant status` to verify
that the machine is in the state that you expect. If you continue to
get this error message, please view the documentation for the provider
you're using.
```

solution
```
./util.sh halt
./util.sh run
```

# Error: Package: fuse-sshfs-2.4-1.el6.x86_64 (epel) - Requires: fuse >= 2.2

修改 ~/.vagrant.d/gems/2.4.9/gems/vagrant-sshfs-1.3.1/lib/vagrant-sshfs/cap/guest/redhat/sshfs_client.rb
```
  # Install sshfs (comes from epel repos)
  machine.communicate.sudo("yum -y install fuse-sshfs")
```
为
```
  # Install sshfs (comes from epel repos)
  machine.communicate.sudo("yum -y install http://mirror.centos.org/centos/7/os/x86_64/Packages/fuse-2.9.2-11.el7.x86_64.rpm fuse-sshfs")
```
