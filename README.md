# OKD Installer

This container will download the OKD installer file and configure your ignition files for a bootstrap, controlplane and worker node

This container is used in conjunction with the LSDcontainer Helm chart.

On it's own this container has no worth.

## Build Image

podman build -t okd-installer:4.5 .
