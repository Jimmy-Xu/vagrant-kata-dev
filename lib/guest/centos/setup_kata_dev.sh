#!/bin/bash

set -xe


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
  git checkout stable-1.9
  make && sudo make install
done


echo "====================================="
echo "osbuilder - rootfs-builder for 1.9.1"
echo "====================================="
cd $GOPATH/src/github.com/kata-containers/osbuilder/rootfs-builder
git checkout stable-1.9

# patch version for 1.9
grep 'runtimeRevision=1.9.1' ../scripts/lib.sh >/dev/null 2>&1
if [ $? -ne 0 ];then
  sed -i "/typeset -r runtimeVersionsURL=/i\ \t\truntimeRevision=1.9.1" ../scripts/lib.sh
else
  echo "../scripts/lib.sh patched"
fi
if [ ! -d rootfs-Clear ];then
  mkdir -p rootfs-Clear
fi
if [ -d rootfs ];then
  rm -rf rootfs
fi
ln -s rootfs-Clear rootfs

script -fec 'sudo -E GOPATH=$GOPATH USE_DOCKER=true AGENT_VERSION=stable-1.9 ./rootfs.sh clearlinux'

echo "======================="
echo "install kata service"
echo "======================="
ROOTFS="rootfs-Clear"
sudo install -o root -g root -m 0550 -t ${ROOTFS}/bin ../../agent/kata-agent
sudo install -o root -g root -m 0440 ../../agent/kata-agent.service ${ROOTFS}/usr/lib/systemd/system/
sudo install -o root -g root -m 0440 ../../agent/kata-containers.target ${ROOTFS}/usr/lib/systemd/system/

echo "========================="
echo "osbuilder - image-builder"
echo "========================="
cd $GOPATH/src/github.com/kata-containers/osbuilder/image-builder
git checkout stable-1.9
script -fec "sudo -E USE_DOCKER=true ./image_builder.sh ../rootfs-builder/${ROOTFS}"


echo "==========================="
echo "install kata-containers.img"
echo "==========================="
commit=$(git log --format=%h -1 HEAD)
date=$(date +%Y-%m-%d-%T.%N%z)
image="kata-containers-${date}-${commit}"
sudo install -o root -g root -m 0640 -D kata-containers.img "/usr/share/kata-containers/${image}"
(cd /usr/share/kata-containers && sudo ln -sf "$image" kata-containers.img)



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
sudo service docker start
sudo service docker reload
