#!/bin/bash
################################################################
# requirement:
# --------------------------------------------------------------
#  - ansible 2.9.0
#  - vagrant 2.2.6
#    - vagrant-libvirt (0.0.45)
#    - vagrant-mutate (1.2.0)
#    - vagrant-proxyconf (2.0.7)
# ----ruby(2.5)----
# ----libvirt------
#  - qemu(4.0.0), libvirt(4.5.0)
#  - ruby-libvirt(0.7.1)
# ----virtualbox------
#  - virtualbox 5.2.22
################################################################
# test env:
# --------------------------------------------------------------
# host os : centos 7.6.1810
# provider: libvirt
# image   : centos/7
# ansible : 2.9
################################################################


# manage virtualbox vm
##########################################
# VBoxManage list runningvms
# VBoxManage controlvm <uuid> poweroff
# VBoxManage unregistervm <uuid>

#magage libvirt vm
##########################################
# virsh list --all
# virsh undefine <vm_name>


################################################################
. lib/config.sh
. lib/common.sh
. lib/host/centos.sh
. lib/image.sh
. lib/vagrant.sh


function show_usage(){
  cat <<EOF
  usage: ./util_centos.sh <command>
  <command>:
    -----------------------------------------------------------------------------
    ensure_dependency <OS>   # install dependency, OS could be 'centos'
    prepare_image            # prepare vagrant box
    -----------------------------------------------------------------------------
    run                      # 'vagrant up --provision --provider=${PROVIDER}'
    mount                    # 'vagrant sshfs --mount'
    halt                     # 'vagrant halt'
    destroy                  # 'vagrant destroy'
    list                     # show VM list via 'sudo -E vagrant list'
    status                   # show VM status via 'vagrant status'
    -----------------------------------------------------------------------------
    config                   # show ssh config via 'vagrant ssh-config'
    ssh                      # enter VM ssh via 'vagrant ssh default'
    console                  # enter VM console via 'sudo -E virsh console ${PROJECT}default'
                               default account is vagrant:vagrant
    -----------------------------------------------------------------------------
EOF
}


## main #################################################
cd ${WORK_DIR}
mkdir -p ${WORK_DIR}/${IMAGE_CACHE} ${WORK_DIR}/${TMP_DIR}
case "$1" in
  ensure_dependency)
    case $2 in
      centos)
        checkdep
        install_dependency_for_centos
        ;;
      *)
        quit "support centos only! please specify os"
        ;;
      esac
      showenv
      echo "DONE"
    ;;
  prepare_image)
    prepare_image
    ;;
  run)
    checkdep
    vagrant_up
    ;;
  mount)
    vagrant sshfs --mount
    ;;
  list)
    sudo -E virsh list | awk "NR==1 || /${PROJECT}/"
    ;;
  status)
    vagrant status
    ;;
  halt)
    vagrant halt
    ;;
  destroy)
    destroy_all
    ;;
  ssh)
    vagrant ssh default
    ;;
  console)
    sudo -E virsh console ${PROJECT}default
    ;;
  config)
    vagrant ssh-config
    ;;
  *)
    show_usage
    ;;
esac
