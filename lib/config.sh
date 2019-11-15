
################################################################
WORK_DIR=$(cd `dirname $0`; pwd)
TMP_DIR="../_tmp"
IMAGE_CACHE="../_image"

VAGRANT_PKG="vagrant_2.2.6_x86_64.rpm"
VAGRANT_URL="https://releases.hashicorp.com/vagrant/2.2.6/${VAGRANT_PKG}"
VIRTUALBOX_PKG="VirtualBox-5.2-5.2.22_126460_el7-1.x86_64.rpm "
VIRTUALBOX_URL="http://download.virtualbox.org/virtualbox/5.2.22/${VIRTUALBOX_PKG}"

RUBY_VER=2.6
RUBY_LIBVIRT=0.7.1

SCL_RUBY="scl enable rh-ruby26"

##################################
##            provider           #
##################################
PROVIDER="libvirt"
#PROVIDER="virtualbox"


##################################
##            libvirt            #
##################################
LV_DISTROS="centos/7"
#LV_DISTROS="fedora/22-cloud-base"
#------------------------------------------------
LV_FEDORA22_NAME="libvirt/fedora/22-cloud-base"
LV_FEDORA22_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/22/Cloud/x86_64/Images/Fedora-Cloud-Base-Vagrant-22-20150521.x86_64.vagrant-libvirt.box"
LV_FEDORA22_IMG="Fedora-Cloud-Base-Vagrant-22-20150521.x86_64.vagrant-libvirt.box"
#------------------------------------------------
LV_CENTOS7BOX_NAME="libvirt/centos/7"
LV_CENTOS7BOX_URL="https://vagrantcloud.com/centos/boxes/7/versions/1809.01/providers/libvirt.box"
LV_CENTOS7BOX_IMG="CentOS-7-x86_64-Vagrant-v1809_01.LibVirt.box"


##################################
##           virtualbox          #
##################################
VB_DISTROS="centos/7"
#VB_DISTROS="fedora/22-cloud-base"
#VB_DISTROS="ubuntu/trusty64"

#------------------------------------------------
VB_FEDORA22_NAME="virtualbox/fedora/22-cloud-base"
VB_FEDORA22_URL="https://download.fedoraproject.org/pub/fedora/linux/releases/22/Cloud/x86_64/Images/Fedora-Cloud-Base-Vagrant-22-20150521.x86_64.vagrant-virtualbox.box"
VB_FEDORA22_IMG="Fedora-Cloud-Base-Vagrant-22-20150521.x86_64.vagrant-virtualbox.box"
#------------------------------------------------
VB_UBUNTU1404BOX_NAME="virtualbox/ubuntu/trusty64"
VB_UBUNTU1404BOX_URL="https://atlas.hashicorp.com/ubuntu/boxes/trusty64/versions/20160122.0.0/providers/virtualbox.box"
VB_UBUNTU1404BOX_IMG="trusty-server-cloudimg-amd64-vagrant-disk1.box"
#------------------------------------------------
VB_CENTOS7BOX_NAME="virtualbox/centos/7"
VB_CENTOS7BOX_URL="https://atlas.hashicorp.com/centos/boxes/7/versions/1611.01/providers/virtualbox.box"
VB_CENTOS7BOX_IMG="CentOS-7-x86_64-Vagrant-1611_01.VirtualBox.box"
