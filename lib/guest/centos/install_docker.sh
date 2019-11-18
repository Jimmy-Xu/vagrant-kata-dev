echo "======================="
echo "install docker 19.03.5"
echo "======================="
rpm -ql docker-ce docker-ce-cli > /dev/null 2>&1
if [ $? -ne 0 ];then
  sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
  sudo yum -y install docker-ce
fi

echo "> add $USER to docker group"
sudo usermod -aG docker $USER

echo "> enable http proxy for docker daemon"
echo -e "[Service]\nEnvironment='HTTP_PROXY=http://172.16.87.1:8118' 'HTTPS_PROXY=http://172.16.87.1:8118' 'NO_PROXY=localhost,127.0.0.1'" | sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf

echo "> add kata-runtime to dockerd"
# remove --containerd=/run/containerd/containerd.sock
sudo sed -i 's|^ExecStart=/usr/bin/dockerd .*$|ExecStart=/usr/bin/dockerd -H fd:// --add-runtime kata-runtime=/usr/bin/kata-runtime|' /usr/lib/systemd/system/docker.service

echo "> restart dockerd"
sudo systemctl daemon-reload
sudo service docker start
sudo service docker reload
