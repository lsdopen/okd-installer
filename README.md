# OKD/OCP Installer

This container will download the OKD/OCP installer file and configure your ignition files for a bootstrap, controlplane and worker node

This container is used in conjunction with the LSDcontainer Helm chart.

On it's own this container has no worth.

Helm Repo: https://github.com/lsdopen/charts

Helm Chart: lsdcontainer-bastion 

## Build Image

```
podman build -t okd-installer:latest .
```
