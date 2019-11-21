#!/bin/bash

set -xe


KATA_RPM_DIR=~/script/centos/rpm/kata


echo "======================="
echo "install common"
echo "======================="
rpm -ql wget git net-tools nmap-ncat tree >/dev/null 2>&1
if [ $? -ne 0 ];then
  sudo -E yum install -y wget git net-tools nmap-ncat tree
fi


if [ -d ~/.oh-my-zsh -a -f /bin/zsh -a -f ~/.zshrc ];then
  echo "> on-my-zsh installed, skip"
else
  echo "> install oh-my-zsh"
  sudo -E yum install -y zsh
  sh -c "$(wget -O- https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
fi


rpm -qa | grep elrepo-release
if [ $? -ne 0 ];then
  echo "> install ELRepo"
  sudo -E rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
  sudo -E yum install -y https://www.elrepo.org/elrepo-release-7.0-4.el7.elrepo.noarch.rpm
else
  echo "> ELRepo instaleld, skip"
fi
sudo -E wget -O /etc/yum.repos.d/epel-aliyun.repo http://mirrors.aliyun.com/repo/epel-7.repo


echo "===================="
echo "install golang"
echo "===================="
which go > /dev/null 2>&1
if [ $? -ne 0 ];then
  echo "> install golang"
  sudo -E yum install -y golang
else
  echo "golang installed, skip"
fi

echo "===================="
echo "add GOPATH to shell"
echo "===================="
for CFG in ~/.bashrc ~/.zshrc
do
grep GOPATH $CFG >/dev/null 2>&1
if [ $? -ne 0 ];then
  echo "add GOPATH to $CFG"
  echo -e "cat >> $CFG <<EOF\n\
export GOPATH=~/gopath\n\
export PATH=~/gopath/bin:\$PATH\n\
EOF" | sh
else
  echo "GOPATH in $CFG, skip"
fi
done


echo "======================="
echo "> install kata 1.9 repo"
echo "======================="
if [ ! -f /etc/yum.repos.d/home:katacontainers:releases:x86_64:stable-1.9.repo ];then
  echo "install kata yum repo"
  cd /etc/yum.repos.d
  sudo -E wget -c http://download.opensuse.org/repositories/home:/katacontainers:/releases:/x86_64:/stable-1.9/CentOS_7/home:katacontainers:releases:x86_64:stable-1.9.repo
else
  echo "> kata yum repo installed, skip"
fi


echo "> enter dir $KATA_RPM_DIR"
mkdir -p $KATA_RPM_DIR
cd $KATA_RPM_DIR

echo "========================="
echo "> install qemu-lite"
echo "========================="
rpm -ql qemu-lite-data qemu-lite-bin qemu-lite > /dev/null 2>&1
if [ $? -ne 0 ];then
  echo "> download qemu-lite"
  for f in qemu-lite qemu-lite-bin qemu-lite-data
  do
    wget -c "http://download.opensuse.org/repositories/home:/katacontainers:/releases:/x86_64:/stable-1.9/CentOS_7/x86_64/${f}-2.11.0+git.87517afd72-6.1.x86_64.rpm"
    echo "> install qemu-lite rpm"
    sudo yum install -y *.rpm
  done
else
  echo "> qemu-lite installed, skip"
fi

echo "========================="
echo "> install qemu-vanilla"
echo "========================="
rpm -ql qemu-vanilla qemu-vanilla-data qemu-vanilla-bin qemu-guest-agent > /dev/null 2>&1
if [ $? -ne 0 ];then
  echo "> download qemu-vanilla"
  for f in qemu-vanilla qemu-vanilla-bin qemu-vanilla-data
  do
    wget -c "http://download.opensuse.org/repositories/home:/katacontainers:/releases:/x86_64:/stable-1.9/CentOS_7/x86_64/${f}-4.1.0+git.9e06029aea-6.1.x86_64.rpm"
    echo "> install qemu-vanilla rpm"
    sudo yum install -y *.rpm qemu-guest-agent
  done
else
  echo "> qemu-vanilla and qemu-guest-agent insalled, skip"
fi

echo "========================="
echo "> download kata 1.9.1 rpm"
echo "========================="
rpm -ql kata-proxy kata-runtime kata-shim-bin kata-proxy-bin kata-linux-container kata-containers-image kata-shim kata-ksm-throttler > /dev/null 2>&1
if [ $? -ne 0 ];then
  echo "> download kata"
  for f in kata-runtime kata-shim-bin kata-proxy-bin kata-shim kata-proxy kata-containers-image kata-ksm-throttler
  do
    wget -c http://download.opensuse.org/repositories/home%3A/katacontainers%3A/releases%3A/x86_64%3A/stable-1.9/CentOS_7/x86_64/${f}-1.9.1-6.1.x86_64.rpm
  done
  wget -c http://download.opensuse.org/repositories/home:/katacontainers:/releases:/x86_64:/stable-1.9/CentOS_7/x86_64/kata-linux-container-4.19.75.54-6.1.x86_64.rpm

  echo "> install kata rpm"
  sudo yum install -y *.rpm qemu-guest-agent
else
  echo "> kata installed, skip"
fi
