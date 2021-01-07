#!/bin/sh

OKD_VERSION=4.5.0-0.okd-2020-10-15-235428

echo "making directory: /srv/okd-installer/ ..."
echo ""
mkdir -p /srv/okd-installer/
echo "downloading openshift-install-linux-$OKD_VERSION.tar.gz ..."
echo ""
curl -L -C - https://github.com/openshift/okd/releases/download/4.5.0-0.okd-2020-10-15-235428/openshift-install-linux-$OKD_VERSION.tar.gz -o /srv/okd-installer/openshift-install-linux-$OKD_VERSION.tar.gz
echo "extracting openshift-install-linux-$OKD_VERSION.tar.gz ..."
echo ""
tar zxvf /srv/okd-installer/openshift-install-linux-$OKD_VERSION.tar.gz
