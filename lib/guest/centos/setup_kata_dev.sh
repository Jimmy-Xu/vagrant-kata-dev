echo "====================="
echo "download kata repo"
echo "====================="
for REPO in proxy shim runtime agent osbuilder
do
  if [ ! -d $GOPATH/src/github.com/kata-containers/$REPO ];then
    echo "> clone repo $REPO"
    go get -v -d github.com/kata-containers/$REPO
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


echo "=========================="
echo "osbuilder - rootfs-builder"
echo "=========================="
cd $GOPATH/src/github.com/kata-containers/osbuilder/rootfs-builder
script -fec 'sudo -E GOPATH=$GOPATH USE_DOCKER=true ./rootfs.sh clearlinux'

echo "======================="
echo "install kata from repo"
echo "======================="
sudo -E install -o root -g root -m 0550 -t rootfs/bin ../../agent/kata-agent
sudo -E install -o root -g root -m 0440 ../../agent/kata-agent.service rootfs/usr/lib/systemd/system/
sudo -E install -o root -g root -m 0440 ../../agent/kata-containers.target rootfs/usr/lib/systemd/system/

echo "========================="
echo "osbuilder - image-builder"
echo "========================="
cd $GOPATH/src/github.com/kata-containers/osbuilder/image-builder
script -fec 'sudo -E USE_DOCKER=true ./image_builder.sh ../rootfs-builder/rootfs'


echo "=========================="
echo "create link for clearlinux"
echo "=========================="
sudo ln -s /usr/share/clear-containers/vmlinux.container /usr/share/kata-containers/
sudo ln -s /usr/share/clear-containers/vmlinuz.container /usr/share/kata-containers/


echo "==========================="
echo "install kata-containers.img"
echo "==========================="
commit=$(git log --format=%h -1 HEAD)
date=$(date +%Y-%m-%d-%T.%N%z)
image="kata-containers-${date}-${commit}"

sudo -E install -o root -g root -m 0640 -D kata-containers.img "/usr/share/kata-containers/${image}"
(cd /usr/share/kata-containers && ln -sf "$image" kata-containers.img)



# sudo mkdir -p /etc/systemd/system/docker.service.d

# cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/kata-containers.conf
# [Service]
# Type=simple
# ExecStart=
# ExecStart=/usr/bin/dockerd -D --default-runtime runc --add-runtime kata-runtime=/usr/local/bin/kata-runtime
# EOF

# sudo systemctl daemon-reload
# sudo systemctl restart docker
