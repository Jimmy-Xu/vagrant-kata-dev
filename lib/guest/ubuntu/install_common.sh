function install_common() {
  GO_VER = "1.9.3"

  apt-get -y install apt-transport-https ca-certificates wget software-properties-common
  add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sh -c "echo 'deb http://download.opensuse.org/repositories/home:/clearcontainers:/clear-containers-3/xUbuntu_$(lsb_release -rs)/ /' >> /etc/apt/sources.list.d/clear-containers.list"
  wget -qO - http://download.opensuse.org/repositories/home:/clearcontainers:/clear-containers-3/xUbuntu_$(lsb_release -rs)/Release.key | sudo apt-key add -
  wget -qO - https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  if [ ! -f /tmp/go#{GO_VER}.linux-amd64.tar.gz ]
  then
    wget https://dl.google.com/go/go#{GO_VER}.linux-amd64.tar.gz -O /tmp/go#{GO_VER}.linux-amd64.tar.gz
    tar -C /usr/local -xzf /tmp/go#{GO_VER}.linux-amd64.tar.gz
  fi

  apt-get update && apt-get -y full-upgrade
  apt-get -y install docker-ce make gcc cc-runtime cc-proxy cc-shim
  systemctl enable docker.service
  systemctl restart docker.service

  mkdir -p /root/go/{bin,pkg,src}
  echo "export GOPATH=$HOME/go" >> /root/.bashrc
  echo "export KATA_RUNTIME=cc" >> /root/.bashrc
  echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> /etc/profile
  echo "export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin" >> /root/.bashrc
}
