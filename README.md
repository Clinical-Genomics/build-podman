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



## Adjusting user systemd services

If you have generated systemd services with the command `podman generate systemd --new` and installed them under _~/.config/systemd/user_ , you need to replace occurences of `/usr/bin/podman` with `%h/podman/bin/podman`
in your files  _~/.config/systemd/user/*.service_. 

Also adjust the environment variables for the user systemd service

```
mkdir ~/.config
echo ~/podman/bin:~/bin:$PATH > ~/.config/EnvironmentFile.systemd_podman
```

(the filename _EnvironmentFile.systemd_podman_ was arbitrarily chosen)

Then add the line

```
EnvironmentFile=%S/EnvironmentFile.systemd_podman
```
in your podman user systemd service files.

For instance the lines

```
ExecStartPre=/bin/rm -f %t/%n-pid %t/%n-cid
ExecStart=/usr/bin/podman run --conmon-pidfile %t/%n-pid --cidfile %t/%n-cid --cgroups=no-conmon -d -dit alpine
ExecStop=/usr/bin/podman stop --ignore --cidfile %t/%n-cid -t 10
ExecStopPost=/usr/bin/podman rm --ignore -f --cidfile %t/%n-cid
```
should be replaced with

```
EnvironmentFile=%S/EnvironmentFile.podman
ExecStartPre=/bin/rm -f %t/%n-pid %t/%n-cid
ExecStart=%h/podman/bin/podman run --conmon-pidfile %t/%n-pid --cidfile %t/%n-cid --cgroups=no-conmon -d -dit alpine
ExecStop=%h/podman/bin/podman stop --ignore --cidfile %t/%n-cid -t 10
ExecStopPost=%h/podman/bin/podman rm --ignore -f --cidfile %t/%n-cid
```
