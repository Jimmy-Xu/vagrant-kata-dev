function install_dependency_for_centos(){

  title "ensure dependency for provider: '${PROVIDER}'"

  title "[for common] ensure vagrant installed"
  which vagrant >/dev/null 2>&1
  if [ $? -ne 0 ];then
    wget -c ${VAGRANT_URL} -O ${WORK_DIR}/${TMP_DIR}/${VAGRANT_PKG}
    sudo -E rpm -Uvh ${WORK_DIR}/${TMP_DIR}/${VAGRANT_PKG}
    which vagrant >/dev/null 2>&1
    if [ $? -ne 0 ];then
      quit "[for common] install vagrant failed"
    else
      echo "[for common] vagrant installed successfully"
    fi
  else
    vagrant --version
    echo "[for common] vagrant already installed"
  fi

  title "[for common] ensure vagrant plugin vagrant-proxyconf installed"
  vagrant plugin list | grep vagrant-proxyconf >/dev/null 2>&1
  if [ $? -ne 0 ];then
    vagrant plugin install vagrant-proxyconf --plugin-clean-sources --plugin-source https://gems.ruby-china.com
  fi

  title "[for common] ensure ansible installed"
  ansible --version | grep "^ansible 2.9" >/dev/null 2>&1
  if [ $? -ne 0 ];then
    title "[install ansible]"
    sudo -E yum install -y ansible-2.9.0
    ansible --version | grep "^ansible 2.9" >/dev/null 2>&1
    if [ $? -ne 0 ];then
      quit "install ansible failed"
    else
      echo "install ansible successfully"
    fi
  else
    echo "ansible already installed"
    ansible --version
  fi

  if [ ${PROVIDER} == "virtualbox" ];then
  # for virtualbox
    title "[for virtualbox] ensure virtualbox5 installed"
    sudo -E yum install -y qt qt-x11
    sudo -E yum install -y kernel-devel-`uname -r` gcc
    wget -c ${VIRTUALBOX_URL} -O ${WORK_DIR}/${TMP_DIR}/${VIRTUALBOX_PKG}
    sudo -E rpm -Uvh ${WORK_DIR}/${TMP_DIR}/${VIRTUALBOX_PKG}
    # add current user to vboxusers
    sudo -E usermod -aG vboxusers $USER


  elif [ ${PROVIDER} == "libvirt" ];then
    title "[for libvirt] ensure qemu installed"
    which qemu-system-x86_64 libvirtd >/dev/null 2>&1
    if [ $? -ne 0 ];then
      sudo -E yum install -y qemu libvirt  librbd1
    fi
    grep '^unix_sock_rw_perms = "0770"' /etc/libvirt/libvirtd.conf >/dev/null 2>&1
    if [ $? -eq 0 ];then
      sudo -E sed -i 's/unix_sock_rw_perms = "0770"/unix_sock_rw_perms = "0777"/' /etc/libvirt/libvirtd.conf
      sudo -E service libvirtd restart
    fi

    title "[for libvirt] use ruby-china gem source"
    gem sources --add https://gems.ruby-china.com --remove https://rubygems.org/
    gem source -l


    title "[for libvirt] ensure ruby-libvirt ${RUBY_LIBVIRT}"
    gem list | grep "ruby-libvirt (${RUBY_LIBVIRT}" >/dev/null 2>&1
    if [ $? -ne 0 ];then
      gem list | grep "ruby-libvirt (${RUBY_LIBVIRT}" >/dev/null 2>&1
    fi
    if [ $? -ne 0 ];then
      title "install dependency for ruby-libvirt"
      sudo -E yum install -y libxslt-devel libxml2-devel libvirt-devel libguestfs-tools-c
      title "install ruby-libvirt ${RUBY_LIBVIRT}"
      gem install --source=https://gems.ruby-china.com ruby-libvirt -v "${RUBY_LIBVIRT}"
      gem list | grep "ruby-libvirt (${RUBY_LIBVIRT}" >/dev/null 2>&1
      if [ $? -ne 0 ];then
        quit "[for libvirt] ruby-libvirt ${RUBY_LIBVIRT} installed failed"
      else
        echo "[for libvirt] ruby-libvirt ${RUBY_LIBVIRT} install successfully"
      fi
    else
      echo "[for libvirt] ruby-libvirt already installed"
    fi

    title "[for libvirt] ensure vagrant plugin "
    for p in vagrant-libvirt vagrant-mutate vagrant-hostmanager vagrant-sshfs
    do
      title "[for libvirt] ensure vagrant plugin : ${p} "
      vagrant plugin list | grep ${p} >/dev/null 2>&1
      if [ $? -ne 0 ];then
        vagrant plugin install ${p} --plugin-source https://gems.ruby-china.com
      fi
    done
    vagrant plugin list

  else
    quit "unsupport provider '${PROVIDER}'"
  fi

# cat <<EOF
#
#   >FAQ 1: error "VirtualBox is complaining that the kernel module is not loaded"
#     sudo -E service vboxdrv setup
#
#   >FAQ 2: error "Stderr: VBoxManage: error: Could not find a controller named 'SATA Controller'"
#     cat ~/.vagrant.d/boxes/trusty/0/virtualbox/box.ovf | grep -i "storagecontroller name"
#     (REF: https://github.com/kusnier/vagrant-persistent-storage/issues/33)
#
# EOF
}
