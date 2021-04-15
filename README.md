# build-podman

Building [Podman](https://github.com/containers/podman) with Github actions.

This project is trying to help out in the situation where you want to be able to run 
`podman` on a CentOS compute cluster where you don't have root permission but only normal user permission. In other words
the normal installation procedure to install RPM packages (`dnf install podman` or `yum install podman`) is not possible.

The GitHub actions workflow [.github/workflows/build.yml](.github/workflows/build.yml) contains a matrix

```
    strategy:
      matrix:
        go-version: [1.15.3]
        podman-version: [ad1aaba8df96cb25e12fe28ec96f3c131e572e3e]
        conmon-version: [v2.0.27]
        centos-version: [8, 7]
        CNI-plugins-version: [v0.9.1]
        crun-version: [0.18]
        slirp4netns-version: [v1.1.9]
        fuse-overlayfs-version: [v1.4.0]
        installprefix: [/home/erik.sjolund/podman]
```
where different versions can be specified. 

The executables

* crun
* slirp4netns
* fuse-overlayfs

are not built but instead downloaded and added to the tar archive together with the Podman build results.
The tar archive is then uploaded as an artifact to GitHub.


#### TODO and caveats

* There is an unnecessary warning https://github.com/containers/podman/issues/9389 (that can be ignored).
* After untarring the archive, there might be a need to set file SELinux security contexts with `chcon -R ` (TODO: investigate this. It seems to be a problem only when untarring outside of the home directory)
* Investigate if the installprefix matters at all. (Does it have to match the path where the tar archive is untarred?)

## Install into home directory

A sketch:

```
cd ~
unzip ~/Downloads/build-podman_7272d09c0f846af0c728b014a87aafb3ab4a5d78__centos_7__podman_ad1aaba8df96cb25e12fe28ec96f3c131e572e3e__conmon_v2.0.27__CNI-plugins_v0.9.1__go_1.15.3__crun_0.18__slirp4netns_v1.1.9__fuse-overlayfs_v1.4.0.tar.zip
tar xf build-podman_7272d09c0f846af0c728b014a87aafb3ab4a5d78__7__ad1aaba8df96cb25e12fe28ec96f3c131e572e3e__v2.0.27__v0.9.1__1.15.3__0.18__v1.1.9__v1.4.0.tar
mv output podman
```

Create the configuration files _~/.config/containers/containers.conf_
and _~/.config/containers/storage.conf_. (TODO: provide examples of how they could look like)

## Usage

Run podman

```
podman --runtime=~/podman/bin/crun --storage-driver overlay --storage-opt overlay.mount_program=~/podman/bin/fuse-overlayfs run --rm -ti docker.io/library/alpine
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
EnvironmentFile=%S/EnvironmentFile.systemd_podman
ExecStartPre=/bin/rm -f %t/%n-pid %t/%n-cid
ExecStart=%h/podman/bin/podman run --conmon-pidfile %t/%n-pid --cidfile %t/%n-cid --cgroups=no-conmon -d -dit alpine
ExecStop=%h/podman/bin/podman stop --ignore --cidfile %t/%n-cid -t 10
ExecStopPost=%h/podman/bin/podman rm --ignore -f --cidfile %t/%n-cid
```
