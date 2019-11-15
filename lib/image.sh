
function prepare_image(){
  # centos/7 (libvirt/virtualbox) https://atlas.hashicorp.com/centos/boxes/7
  # ubuntu/trusty64 (virtualbox)  https://atlas.hashicorp.com/ubuntu/boxes/trusty64
  mkdir -p ${WORK_DIR}/${IMAGE_CACHE}
  case ${PROVIDER} in
    virtualbox)
      CUR_DISTROS=${VB_DISTROS}
      case "${CUR_DISTROS}" in
        "centos/7")
          CUR_IMAGE_NAME=${VB_CENTOS7BOX_NAME}
          CUR_IMAGE_URL=${VB_CENTOS7BOX_URL}
          CUR_IMAGE_IMG=${VB_CENTOS7BOX_IMG}
          ;;
        "fedora/22-cloud-base")
          CUR_IMAGE_NAME=${VB_FEDORA22_NAME}
          CUR_IMAGE_URL=${VB_FEDORA22_URL}
          CUR_IMAGE_IMG=${VB_FEDORA22_IMG}
          ;;
        "ubuntu/trusty64")
          CUR_IMAGE_NAME=${VB_UBUNTU1404BOX_NAME}
          CUR_IMAGE_URL=${VB_UBUNTU1404BOX_URL}
          CUR_IMAGE_IMG=${VB_UBUNTU1404BOX_IMG}
          ;;
        *) quit "unknown osdistro for provider(virtualbox)"
          ;;
      esac
      echo "update device name"
      ;;
    libvirt)
      CUR_DISTROS=${LV_DISTROS}
      case "${CUR_DISTROS}" in
        "centos/7")
          CUR_IMAGE_NAME=${LV_CENTOS7BOX_NAME}
          CUR_IMAGE_URL=${LV_CENTOS7BOX_URL}
          CUR_IMAGE_IMG=${LV_CENTOS7BOX_IMG}
          ;;
        "fedora/22-cloud-base")
          CUR_IMAGE_NAME=${LV_FEDORA22_NAME}
          CUR_IMAGE_URL=${LV_FEDORA22_URL}
          CUR_IMAGE_IMG=${LV_FEDORA22_IMG}
          ;;
        *) quit "unknown osdistro for provider(virtualbox)"
          ;;
      esac
      echo "update device name"
      ;;
    *)
      quit "unknown provider:${PROVIDER}"
      ;;
  esac

  echo "============================================"
  echo " current image info "
  echo "============================================"
  echo "CUR_IMAGE_NAME: ${CUR_IMAGE_NAME}"
  echo "CUR_IMAGE_URL : ${CUR_IMAGE_URL}"
  echo "CUR_IMAGE_IMG : ${CUR_IMAGE_IMG}"
  echo
  echo "========================================="
  echo "ensure box ${CUR_IMAGE_NAME}"
  vagrant box list | grep "${CUR_IMAGE_NAME}.*(${PROVIDER}," >/dev/null 2>&1
  if [ $? -ne 0 ];then
    echo "download and add box ${CUR_IMAGE_NAME} (${PROVIDER})"
    wget -c ${CUR_IMAGE_URL} -O ${WORK_DIR}/${IMAGE_CACHE}/${CUR_IMAGE_IMG}
    if [ -s ${WORK_DIR}/${IMAGE_CACHE}/${CUR_IMAGE_IMG} ];then
      vagrant box add --name "${CUR_IMAGE_NAME}" ${WORK_DIR}/${IMAGE_CACHE}/${CUR_IMAGE_IMG}
    fi
  else
    echo "box '${CUR_IMAGE_NAME}' already exist,skip"
  fi
  echo "============================="
  echo "list all box:"
  echo "-----------------------------"
  vagrant box list
  echo "============================="

}
