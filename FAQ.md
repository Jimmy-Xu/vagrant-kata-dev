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
