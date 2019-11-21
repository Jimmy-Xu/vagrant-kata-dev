#!/bin/bash

KERNEL_RPM_DIR=~/script/centos/rpm/kernel

cd $KERNEL_RPM_DIR
mkdir -p $KERNEL_RPM_DIR

INSTALL_KERNEL_FROM_SRC=true

if [ "$INSTALL_KERNEL_FROM_SRC" != "true" ];then

  echo "========================="
  echo "download kernel 4.9.199-35"
  echo "========================="
  for f in kernel kernel-devel kernel-headers perf
  do
    rpm -qa | grep "$f-4.9.199-35.el7.x86_64" >/dev/null 2>&1
    if [ $? -ne 0 ];then
      echo "install $f-4.9.199-35.el7.x86_64"
      wget -c https://cbs.centos.org/kojifiles/packages/kernel/4.9.199/35.el7/x86_64/$f-4.9.199-35.el7.x86_64.rpm
    else
      echo "$f-4.9.199-35.el7.x86_64 installed, skip"
    fi
  done

  echo "========================="
  echo "install kernel 4.9.199-35"
  echo "========================="
  rpm -ql kernel-4.9.199-35 kernel-headers-4.9.199-35 kernel-devel-4.9.199-35
  if [ $? -ne 0 ];then
    sudo -E yum install -y *.rpm
  else
    echo "kernel 4.9.199-35 installed, skip"
  fi

else

  echo "================================="
  echo "download kernel source 4.9.199-35"
  echo "================================="
  wget -c https://cbs.centos.org/kojifiles/packages/kernel/4.9.199/35.el7/src/kernel-4.9.199-35.el7.src.rpm
  rpm -Uvh kernel-4.9.199-35.el7.src.rpm

  cd ~/rpmbuild
  rpm -ql rpm-build >/dev/null 2>&1
  if [ $? -ne 0 ];then
    echo "install rpm-build"
    sudo -E yum install -y rpm-build
  else
    echo "rpm-build installed, skip"
  fi

  echo "==================================="
  echo "install dependency for build kernel"
  echo "==================================="
  sudo -E yum install -y centos-release-scl
  sudo -E yum install -y devtoolset-7 devtoolset-7-gcc ncurses-devel
  sudo -E yum-builddep -y SPECS/kernel.spec


  echo "==================================="
  echo "update kernel config"
  echo "==================================="
  rpmbuild -bp SPECS/kernel.spec
  cp /boot/config-`uname -r` .config
  cd BUILD/kernel-*/linux-*
  make menuconfig

  if [ ! -f  ~/rpmbuild/SOURCES/config-x86_64.orig ];then
    cp  ~/rpmbuild/SOURCES/config-x86_64  ~/rpmbuild/SOURCES/config-x86_64.orig
  else
    echo  ”~/rpmbuild/SOURCES/config-x86_64.orig exist, skip”
  fi
  /usr/bin/cp -rf .config ~/rpmbuild/SOURCES/config-x86_64

  echo "==================================="
  echo "build kernel"
  echo "==================================="
  cd ~/rpmbuild
  grep VSOCK SOURCES/config-x86_64

  # 编译环境: vmware fusion虚拟机(centos),嵌套了qemu虚拟机(centos)，2cpu 用时1小时30分钟左右
  rpmbuild -bb SPECS/kernel.spec

  echo "==================================="
  echo "install kernel"
  echo "==================================="
  sudo rpm -Uvh RPMS/x86_64/{kernel,kernel-devel,kernel-headers}-4.9.199-35.el7.x86_64.rpm

fi
