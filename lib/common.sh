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
