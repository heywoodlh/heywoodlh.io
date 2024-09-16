---
title: "Install Nix on Alpine Linux"
published: true
permalink: /install-nix-alpine-linux/
tags: [ linux, alpine, nix, nix-daemon ]
---

I've started using Alpine Linux as a fun experiment. I use Nix heavily, and I don't feel like it's very well documented for Alpine Linux. My experience is that it works extremely well and is a nice way to use _normal_, glibc packages.

## A note on installation

I won't cover the Alpine Linux installation process in detail, but here are a couple of notes.

Use the following command to install Alpine Linux when you boot into Alpine:

```
setup-alpine
```

On a normal workstation with full disk encryption, I choose `syscrypt` for my disk type. After the installation completes, you can run the following to walk you through a guided installation for a desktop environment:

```
setup-desktop
```

## Commands to install Nix

These commands should be run as `root`.

{% gist 535deea20a2a5b13339d1ee096bf6692 %}

## [BONUS] Install rootless Docker on Alpine

First, install Docker:

```
apk add docker docker-rootless-extras docker-cli-compose
```

In `/etc/rc.conf` set `rc_cgroup_mode="unified"` and then run the following command to start `cgroups` automatically on boot:

```
rc-update add cgroups
```

Ensure `/etc/subuid` and `/etc/subgid` are configured for your user:

```
myuser="heywoodlh"
echo "${myuser}:231072:65536" >> /etc/subuid
echo "${myuser}:231072:65536" >> /etc/subgid
```

Add the following to `/etc/init.d/docker-rootless` (make sure to put you replace to values in `command_user`, `supervise_daemon_args` to reflect your user configuration):

```
#!/sbin/openrc-run

name=$RC_SVCNAME
description="Docker Application Container Engine (Rootless)"
supervisor="supervise-daemon"
command="/usr/bin/dockerd-rootless"
command_args=""
command_user="heywoodlh"
supervise_daemon_args=" -e PATH=\"/home/heywoodlh/bin:/sbin:/usr/sbin:$PATH\" -e HOME=\"/home/heywoodlh\" -e XDG_RUNTIME_DIR=\"/run/user/1000\""

reload() {
    ebegin "Reloading $RC_SVCNAME"
    /bin/kill -s HUP \$MAINPID
    eend $?
}
```

Make the file executable:

```
chmod +x /etc/init.d/dockerd-rootless
```

Then run the following to start rootless Docker on boot for your user and start the service:

```
rc-update add dockerd-rootless
rc-service dockerd-rootless restart
```
