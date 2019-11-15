

function vagrant_up(){
  showenv

  echo "sleep 3 seconds, then continue..."
  sleep 3

  case "${PROVIDER}" in
    libvirt)
      sudo -E service vboxdrv stop
      sudo -E service libvirtd restart
      ;;
    virtualbox)
      sudo -E service libvirtd stop
      sudo -E service vboxdrv restart
      ;;
  esac

  VAGRANT_LOG=info vagrant up --provision --provider=${PROVIDER}
}

function destroy_all(){
  vagrant destroy
  rm .vagrant -rf && rm *.vdi -rf
  case "${PROVIDER}" in
    libvirt)
      virsh list --all| grep -v Name | awk '{print $2}' | grep imaged_default | xargs -I vm_name virsh destroy vm_name
      virsh list --all| grep -v Name | awk '{print $2}' | grep imaged_default | xargs -I vm_name virsh undefine vm_name
      ;;
    virtualbox)
      VBoxManage list runningvms | awk '{print $2;}' | grep imaged_default | xargs -I vmid VBoxManage controlvm vmid poweroff
      VBoxManage list vms | awk '{print $2;}' | grep imaged_default |xargs -I vmid VBoxManage unregistervm vmid --delete
      ;;
    *)
      quit "unknown provider(${PROVIDER})"
  esac
}
