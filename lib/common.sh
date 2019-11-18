function quit(){
  echo "$1"
  exit 1
}

function title() {
  echo
  echo "----------------------------------------------------------"
  echo $@
  echo "----------------------------------------------------------"
}

function showenv() {
  checkdep
  cat <<EOF

==========================================
Ansible        : $(ansible --version | head -n 1 | grep -o "[0-9]\.[0-9]\.[0-9]")
------------------------------------------
Ruby           : $(ruby --version | grep -o "[0-9]\.[0-9]\.[0-9]")
Germ           : $(gem list | grep ruby-libvirt)
------------------------------------------
Vagrant        : $(vagrant --version | grep -o "[0-9]\.[0-9]\.[0-9]")
Vagrant plugins: $(vagrant plugin list| awk '{printf "%s  | ", $0}')
------------------------------------------
VirtualBox     : $(vboxmanage --version 2>/dev/null | grep -o "[0-9]\.[0-9]\.[0-9]")
------------------------------------------
Libvirt        : $(libvirtd --version | grep -o "[0-9]\.[0-9]\.[0-9]")
Qemu           : $(qemu-system-x86_64 --version | grep -o "[0-9]\.[0-9]")
==========================================
EOF
}

function checkdep() {
  which scl > /dev/null 2>&1
  if [ $? -ne 0 ];then
    cat <<EOF
> please run the following commands:

sudo -E yum install -y centos-release-scl
sudo -E yum install -y rh-ruby26

EOF
    quit "please install centos-release-scl and rh-ruby26, then try again"
  fi
  which ruby > /dev/null 2>&1
  if [ $? -ne 0 ];then
    cat <<EOF
> please run the following command:

scl enable rh-ruby26 bash

EOF
    quit "please enable rh-ruby26 with scl"
  fi
}
