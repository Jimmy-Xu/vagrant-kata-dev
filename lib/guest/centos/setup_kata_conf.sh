#!/bin/bash

KATA_CONF_DIR="/etc/kata-containers"
KATA_CONF_FILE="configuration.toml"
echo "================================================================================="
echo "ensure $KATA_CONF_DIR/$KATA_CONF_FILE"
echo "================================================================================="
if [ ! -f $KATA_CONF_DIR/$KATA_CONF_FILE ];then
  echo "ensure $KATA_CONF_DIR/$KATA_CONF_FILE"
  sudo mkdir -p $KATA_CONF_DIR
  sudo /usr/bin/cp -Lf /usr/share/defaults/kata-containers/$KATA_CONF_FILE $KATA_CONF_DIR/$KATA_CONF_FILE
else
  echo "$KATA_CONF_DIR/$KATA_CONF_FILE exist, skip"
fi

echo "================================================================================="
echo "update $KATA_CONF_DIR/$KATA_CONF_FILE"
echo "================================================================================="
if [ ! -f /usr/bin/qemu-system-x86_64 ];then
  echo "create softlink for /usr/bin/qemu-system-x86_64"
  sudo ln -s /usr/bin/qemu-vanilla-system-x86_64 /usr/bin/qemu-system-x86_64
else
  echo "/usr/bin/qemu-system-x86_64 exist, skip"
fi

sudo sed -i 's/^image = "/#image = "/' $KATA_CONF_DIR/$KATA_CONF_FILE
