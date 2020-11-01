# build-podman

Building [Podman](https://github.com/containers/podman) with Github actions.

This project is trying to help out in the situation where you want to be able to run 
`podman` on a CentOS compute cluster where you don't have root permission but only normal user permission. In other words
the normal installation procedure to install RPM packages (`dnf install podman` or `yum install podman`) is not possible.

In addition to downloading the built artifact (found in the GitHub action) to the compute cluster, you also need to download 

* https://github.com/rootless-containers/slirp4netns/releases/download/v1.1.4/slirp4netns-x86_64 and rename the executable to `slirp4netns`
* https://github.com/containers/crun/releases/download/0.14.1/crun-0.14.1-static-x86_64 and rename the executable to `crun`
* https://github.com/containers/fuse-overlayfs/releases/download/v1.2.0/fuse-overlayfs-x86_64 and rename the executable to `fuse-overlayfs`

TODO: provide more detailed instructions for the installation and for running some example commands

A sketch

```
podman --runtime=/home/erik.sjolund/bin/crun --storage-driver overlay  --storage-opt overlay.mount_program=/home/erik.sjolund/bin/fuse-overlayfs  run -ti -v /home/erik.sjolund/testdir/:/t:O docker.io/library/alpine
```

