---
title: 'Build ARM Docker Containers on (x86 64 bit) Linux'
layout: post
permalink: arm-containers-linux
tags: all, linux, docker, container, systems, arm
---

EDIT: [I have a much better cross-architecture build pipeline now](https://the-empire.systems/cross-architecture-docker-images)

In preparation for the eventual shift to ARM that I will experience (whether directly or indirectly) with Apple shifting their Macbooks to ARM I needed a way to build my containers for ARM.


## Prepare Your Linux Host:


### Configure Docker to Pull Multi-Architecture Images:
After installing Docker on your host, enable experimental features to allow for you to pull containers that don't match your architecture.

Add the following to `/etc/docker/daemon.json`:

```json
{ 
    "experimental": true 
}
```


Then restart the Docker service:

```bash
systemctl restart docker.service
```

To test, pull the arm version of the official Debian Docker image:

```bash
docker pull debian:stable --platform arm

stable: Pulling from library/debian
8889795e1736: Pull complete 
Digest: sha256:281dabbeb55dd7fe6603c0afafdc1800ea4f4ab057516dfb629fe30eb642daf7
Status: Downloaded newer image for debian:stable
docker.io/library/debian:stable
```

### Install Relevant Packages:

In order to emulate ARM properly, we need to install two packages: 
- qemu-user-binfmt
- qemu-user-static

Debian/Ubuntu derivatives:

```bash
apt-get update
apt-get install qemu-user-binfmt qemu-user-static -y
```

Arch Linux:

Use the following AUR packages:

[qemu-user-static](https://aur.archlinux.org/packages/qemu-user-static/)

[binfmt-qemu-static](https://aur.archlinux.org/packages/binfmt-qemu-static/)


Once the packages are installed, see if you can run the Debian arm image that we downloaded:

```bash
docker run -v /usr/bin/qemu-arm-static:/usr/bin/qemu-arm-static --platform arm --rm -ti debian:stable bash

root@25425d924f4a:/# arch
armv7l
```


## Building ARM Containers:

Let's make a new directory for our test container image:

```bash
mkdir -p test-container && cd test-container
```

Now, let's add the qemu-arm-static binary to that new directory (it will be copied to the container image):

```bash
cp /usr/bin/qemu-arm-static .
```

Now, in your Dockerfile you'll just have to make sure the qemu-arm-static binary is added. For example:

```bash
FROM debian:stable

COPY qemu-arm-static /usr/bin/qemu-arm-static

CMD ["/bin/bash"]
```

Adding the qemu-arm-static binary will add about 4 MB of space to your container but will allow your ARM images to be able to run on any x86 Linux host with qemu-arm-static installed and configured.

When you build using that Dockerfile you should specify the platform, like so:

```bash
docker build heywoodlh/test-container:arm -f Dockerfile .
```

With the `arm` tag you will have to specify that tag in order to use that image.

With the qemu-arm-static binary in `/usr/bin/` you should be able to run the container on the Linux host with qemu-arm-static installed:

```bash
docker run -it --rm heywoodlh/test-container:arm bash

root@b80788989cff:/# arch
armv7l
```
