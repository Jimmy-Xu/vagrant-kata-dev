#!/bin/bash

set -e
FLAG=$1
DEBUG=$2

if [ "$FLAG" == "initrd" ];then
  echo "use kata-agent as init"
  export KATA_AS_INIT="yes" # kata-agent as init ==> AGENT_INIT=yes
  export GUEST_OS="Alpine"  #Note: AGENT_INIT=yes must be used for the Alpine distribution since it does not use systemd as its init daemon.
  export GUEST_OS_TYPE=`echo $GUEST_OS | tr 'A-Z' 'a-z'`
  export ROOTFS="rootfs-${GUEST_OS}"
elif [ "$FLAG" == "image" ];then
  echo "use systemd as init"
  export KATA_AS_INIT="no"  # systemd as init  ==> AGENT_INIT=no
  export GUEST_OS="Clear"
  export GUEST_OS_TYPE="clearlinux"
  export ROOTFS="rootfs-${GUEST_OS}"
else
  echo "./setup_kata_dev.sh <initrd|image>"
  exit 1
fi
export BRANCH="stable-1.9"
export RUNTIME_VERSION="1.9.1"

cat <<EOF
-------------------------------------
KATA_AS_INIT=$KATA_AS_INIT
GUEST_OS=$GUEST_OS
GUEST_OS_TYPE=$GUEST_OS_TYPE
ROOTFS=$ROOTFS
BRANCH=$BRANCH
RUNTIME_VERSION=$RUNTIME_VERSION
-------------------------------------
EOF


if [ "$DEBUG" == "--debug" ];then
  set -x
  export DEBUG_MODE=true
else
  export DEBUG_MODE=false
fi

################################################################################################
echo "====================="
echo "download kata repo"
echo "====================="
for REPO in proxy shim runtime agent osbuilder
do
  if [ ! -d $GOPATH/src/github.com/kata-containers/$REPO ];then
    echo "> clone repo $REPO"
    go get -v -d github.com/kata-containers/$REPO  && echo ok || echo $?
  else
    echo "> repo $REPO cloned, skip"
  fi
done


echo "========================================"
echo "enable debug mode in kata configuration"
echo "========================================"
sudo sed -i -e 's/^# *\(enable_debug\).*=.*$/\1 = true/g' /usr/share/defaults/kata-containers/configuration.toml

echo "====================="
echo "build kata component"
echo "====================="
for REPO in proxy shim runtime agent
do
  echo "> build repo $REPO"
  cd $GOPATH/src/github.com/kata-containers/$REPO
  git checkout ${BRANCH}
  make && sudo make install
done


echo "====================================="
echo "osbuilder - rootfs-builder"
echo "====================================="
cd $GOPATH/src/github.com/kata-containers/osbuilder/rootfs-builder
git checkout ${BRANCH}

# patch version
grep "runtimeRevision=${RUNTIME_VERSION}" ../scripts/lib.sh >/dev/null 2>&1
if [ $? -ne 0 ];then
  sed -i "/typeset -r runtimeVersionsURL=/i\ \t\truntimeRevision=${RUNTIME_VERSION}" ../scripts/lib.sh
else
  echo "../scripts/lib.sh patched"
fi

sudo /usr/bin/rm -rf $GOPATH/src/github.com/kata-containers/osbuilder/rootfs-builder/${ROOTFS}
script -fec "sudo -E GOPATH=$GOPATH USE_DOCKER=true AGENT_VERSION=${BRANCH} AGENT_INIT=${KATA_AS_INIT} DEBUG=${DEBUG_MODE} ./rootfs.sh ${GUEST_OS_TYPE}"


################################################################################################
if [ "$FLAG" == "initrd" ];then

  echo "==========================="
  echo "osbuilder -> initrd-builder"
  echo "==========================="
  cd $GOPATH/src/github.com/kata-containers/osbuilder/initrd-builder
  git checkout ${BRANCH}
  script -fec "sudo -E USE_DOCKER=true AGENT_VERSION=${BRANCH} AGENT_INIT=${KATA_AS_INIT} DEBUG=${DEBUG_MODE} ./initrd_builder.sh ../rootfs-builder/${ROOTFS}"

  echo "=================================="
  echo "install initrd"
  echo "=================================="
  cd $GOPATH/src/github.com/kata-containers/osbuilder/
  commit=$(git log --format=%h -1 HEAD)
  date=$(date +%Y-%m-%d-%T.%N%z)

  cd $GOPATH/src/github.com/kata-containers/osbuilder/initrd-builder
  initrd_file="kata-containers-initrd-${date}-${commit}"
  sudo install -o root -g root -m 0640 -D kata-containers-initrd.img "/usr/share/kata-containers/${initrd_file}"
  (cd /usr/share/kata-containers && sudo ln -sf "$initrd_file" kata-containers-initrd.img)

elif [ "$FLAG" == "image" ];then

  echo "=========================="
  echo "osbuilder -> image-builder"
  echo "=========================="
  cd $GOPATH/src/github.com/kata-containers/osbuilder/image-builder
  git checkout ${BRANCH}
  script -fec "sudo -E USE_DOCKER=true AGENT_VERSION=${BRANCH} AGENT_INIT=${KATA_AS_INIT} DEBUG=${DEBUG_MODE} ./image_builder.sh ../rootfs-builder/${ROOTFS}"

  echo "=================================="
  echo "install image"
  echo "=================================="
  cd $GOPATH/src/github.com/kata-containers/osbuilder/
  commit=$(git log --format=%h -1 HEAD)
  date=$(date +%Y-%m-%d-%T.%N%z)

  cd $GOPATH/src/github.com/kata-containers/osbuilder/image-builder
  image_file="kata-containers-image-${date}-${commit}"
  sudo install -o root -g root -m 0640 -D kata-containers.img "/usr/share/kata-containers/${image_file}"
  (cd /usr/share/kata-containers && sudo ln -sf "$image_file" kata-containers.img)

fi

################################################################################################
echo "==========================="
echo "update dockerd config"
echo "==========================="
sudo mkdir -p /etc/systemd/system/docker.service.d

cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/kata-containers.conf
[Service]
Type=simple
ExecStart=
ExecStart=/usr/bin/dockerd -D --default-runtime runc --add-runtime kata-runtime=/usr/local/bin/kata-runtime
EOF

sudo systemctl daemon-reload
sudo service docker restart
