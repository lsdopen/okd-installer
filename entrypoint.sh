#!/bin/sh

# You need the following variables in the deployment
# OKD_VERSION (OKD_VERSION=4.5.0-0.okd-2020-10-15-235428)
# FEDORA_CORE_VERSION (FEDORA_CORE_VERSION=32.20201104.3.0)
# BASTION_IP_PORT (BASTION_IP_PORT=10.1.0.1:8080)

echo ""
echo "creating pxe files ..."
echo ""
mkdir -p /srv/pxe/pxelinux.cfg/
cp /opt/pxe/* /srv/pxe/

echo ""
echo "creating pxe default file ..."
echo ""
cat > /srv/pxe/pxelinux.cfg/default <<EOF
default menu.c32
prompt 0
timeout 100

LABEL Boot Local Hard Drive
 LOCALBOOT 0

LABEL Bootstrap Installaion - fedora-coreos-$FEDORA_CORE_VERSION
  KERNEL http://$BASTION_IP_PORT/fedora-coreos-$FEDORA_CORE_VERSION-live-kernel-x86_64
  APPEND initrd=http://$BASTION_IP_PORT/fedora-coreos-$FEDORA_CORE_VERSION-live-initramfs.x86_64.img coreos.live.rootfs_url=http://$BASTION_IP_PORT/fedora-coreos-$FEDORA_CORE_VERSION-live-rootfs.x86_64.img coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url=http://$BASTION_IP_PORT/installation/bootstrap.ign

LABEL ControlPlane Installaion - fedora-coreos-$FEDORA_CORE_VERSION
  KERNEL http://$BASTION_IP_PORT/fedora-coreos-$FEDORA_CORE_VERSION-live-kernel-x86_64
  APPEND initrd=http://$BASTION_IP_PORT/fedora-coreos-$FEDORA_CORE_VERSION-live-initramfs.x86_64.img coreos.live.rootfs_url=http://$BASTION_IP_PORT/fedora-coreos-$FEDORA_CORE_VERSION-live-rootfs.x86_64.img coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url=http://$BASTION_IP_PORT/installation/master.ign

LABEL Worker Installaion - fedora-coreos-$FEDORA_CORE_VERSION
  KERNEL http://$BASTION_IP_PORT/fedora-coreos-$FEDORA_CORE_VERSION-live-kernel-x86_64
  APPEND initrd=http://$BASTION_IP_PORT/fedora-coreos-$FEDORA_CORE_VERSION-live-initramfs.x86_64.img coreos.live.rootfs_url=http://$BASTION_IP_PORT/fedora-coreos-$FEDORA_CORE_VERSION-live-rootfs.x86_64.img coreos.inst.install_dev=/dev/sda coreos.inst.ignition_url=http://$BASTION_IP_PORT/installation/worker.ign
EOF

echo ""
echo "making directory: /srv/okd-installer/ ..."
echo ""
mkdir -p /srv/okd-installer/

echo ""
echo "downloading fedora coreos version $FEDORA_CORE_VERSION"
echo ""
curl -L -C - https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$FEDORA_CORE_VERSION/x86_64/fedora-coreos-$FEDORA_CORE_VERSION-live-initramfs.x86_64.img -o /srv/okd-installer/fedora-coreos-$FEDORA_CORE_VERSION-live-initramfs.x86_64.img
curl -L -C - https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$FEDORA_CORE_VERSION/x86_64/fedora-coreos-$FEDORA_CORE_VERSION-live-kernel-x86_64 -o /srv/okd-installer/fedora-coreos-$FEDORA_CORE_VERSION-live-kernel-x86_64
curl -L -C - https://builds.coreos.fedoraproject.org/prod/streams/stable/builds/$FEDORA_CORE_VERSION/x86_64/fedora-coreos-$FEDORA_CORE_VERSION-live-rootfs.x86_64.img -o /srv/okd-installer/fedora-coreos-$FEDORA_CORE_VERSION-live-rootfs.x86_64.img

echo ""
echo "downloading openshift-install-linux-$OKD_VERSION.tar.gz ..."
echo ""
curl -L -C - https://github.com/openshift/okd/releases/download/$OKD_VERSION/openshift-install-linux-$OKD_VERSION.tar.gz -o /srv/okd-installer/openshift-install-linux-$OKD_VERSION.tar.gz

echo ""
echo "extracting openshift-install-linux-$OKD_VERSION.tar.gz ..."
echo ""
tar zxvf /srv/okd-installer/openshift-install-linux-$OKD_VERSION.tar.gz -C /srv/okd-installer/
mv /srv/okd-installer/openshift-install /srv/okd-installer/openshift-install-$OKD_VERSION

echo ""
echo "creating ignition files ..."
echo ""

if [ -f /srv/okd-installer/installation/bootstrap.ign ] ; then
  echo "there already appears to be a installation file at /srv/okd-installer/installation/bootstrap.ign"
  echo "we will not recreate the files"
  echo "if you want a new installation remove the directory /srv/okd-installer/installation/"
  echo ""
  echo "running installation ..."
  /srv/okd-installer/openshift-install-$OKD_VERSION --dir=/srv/okd-installer/installation/ wait-for bootstrap-complete --log-level=info
  echo ""
  /srv/okd-installer/openshift-install-$OKD_VERSION --dir=/srv/okd-installer/installation/ wait-for install-complete --log-level=info
else
  mkdir -p /srv/okd-installer/installation 
  cp /opt/okd/install-config.yaml /srv/okd-installer/installation/install-config.yaml
  /srv/okd-installer/openshift-install-$OKD_VERSION create manifests --dir=/srv/okd-installer/installation/
  sed -i 's/mastersSchedulable: true/mastersSchedulable: false/g' /srv/okd-installer/installation/manifests/cluster-scheduler-02-config.yml
  /srv/okd-installer/openshift-install-$OKD_VERSION create ignition-configs --dir=/srv/okd-installer/installation/
  chmod 0666 /srv/okd-installer/installation/*.ign
  echo ""
  echo "running installation ..."
  /srv/okd-installer/openshift-install-$OKD_VERSION --dir=/srv/okd-installer/installation/ wait-for bootstrap-complete --log-level=info
  echo ""
  /srv/okd-installer/openshift-install-$OKD_VERSION --dir=/srv/okd-installer/installation/ wait-for install-complete --log-level=info
fi

echo ""
echo "sleeping ..."
echo ""
sleep 600
