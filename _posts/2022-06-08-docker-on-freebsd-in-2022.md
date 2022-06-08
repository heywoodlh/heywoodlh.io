---
title: "Running Docker on FreeBSD in 2022"
layout: post
published: true
permalink: freebsd-docker-2022
tags: all, freebsd, unix, docker 
---

## Why?

I really like the philosophies behind FreeBSD. One big blocker for me as an end-user of FreeBSD is that I rely heavily on Docker -- Docker support on FreeBSD is not functional.

On Linux, MacOS and Windows I can get full Docker functionality with Docker's official apps. Drop-in replacements for Docker such as Podman, [Lima](https://github.com/lima-vm/lima) and Rancher Desktop (which is based on Lima) are also available. Lima is based on [QEMU](https://www.qemu.org) which is available on all platforms -- including FreeBSD. So I had the thought that if I could install Lima on FreeBSD that may provide me a nice QEMU virtual machine to be able to easily handle Docker.

So I'll be using Lima + QEMU to conveniently run Docker.

## How to install Lima:

So here's the steps I performed to install Lima:

First install compilation dependencies:

```
pkg install gmake go git
```

Next clone Lima's source:

```
git clone https://github.com/lima-vm/lima /opt/lima

cd /opt/lima
```

Now, if you try to compile Lima at this point it will fail with the following error:

```
pkg/sshutil/sshutil_others.go:14:19: undefined: err
```

So let's quickly patch that file. Replace `/opt/lima/pkg/sshutil/sshutil_others.go` with the following contents:

```
//go:build !darwin && !linux
// +build !darwin,!linux

package sshutil

import (
        "runtime"

        "github.com/sirupsen/logrus"
)

func detectAESAcceleration() bool {
        var err error
        const fallback = runtime.GOARCH == "amd64"
        logrus.WithError(err).Warnf("cannot detect whether AES accelerator is available, assuming %v", fallback)
        return fallback
}
```

Now let's compile:

```
gmake
```

Once the compile completes binaries and some documentation will be available in `/opt/lima/_output/`. Let's move the binaries to `/usr/local/bin/` and the docs to `/usr/local/share/`:

```
cp /opt/lima/_output/bin/* /usr/local/bin/

mkdir -p /usr/local/share/doc/lima && cp -r /opt/lima/_output/share/doc/lima/* /usr/local/share/doc/lima/
cp -r /opt/lima/_output/share/lima /usr/local/share/lima
```

## Install QEMU:

Before we can use Lima we need to install QEMU. 

### Install QEMU via pkg:

An outdated version of QEMU is available from the FreeBSD repositories:

```
pkg install qemu-nox11
```

I would recommend installing from source to get best performance.

### Install QEMU from source:

Skip this if you installed QEMU via `pkg`.

Let's install some dependencies first:

```
pkg install ninja pkgconf glib pixman
```

Now you should be good to compile and install QEMU:

```
git clone --depth=1 git://git.qemu-project.org/qemu.git /opt/qemu
mkdir -p /opt/qemu/build
cd /opt/qemu/build

../configure
gmake ## add -j to speed up the compilation
gmake install
```

## Using Lima:

QEMU on FreeBSD does not seem to support `host` as the desired cpu type, so we have to set an environment variable to override the CPU type.

I would recommend finding your CPU with the following command: `sysctl hw.model`

Example output: `hw.model: Intel Xeon Processor (Cascadelake)`

Find the corresponding model in QEMU's available CPU processors: `qemu-system-x86_64 -cpu help`

Example output: 

```
$ qemu-system-x86_64 -cpu help | grep -i cascadelake
x86 Cascadelake-Server    (alias configured by machine type)
x86 Cascadelake-Server-noTSX  (alias of Cascadelake-Server-v3)
x86 Cascadelake-Server-v1  Intel Xeon Processor (Cascadelake)
x86 Cascadelake-Server-v2  Intel Xeon Processor (Cascadelake) [ARCH_CAPABILITIES]
x86 Cascadelake-Server-v3  Intel Xeon Processor (Cascadelake) [ARCH_CAPABILITIES, no TSX]
x86 Cascadelake-Server-v4  Intel Xeon Processor (Cascadelake) [ARCH_CAPABILITIES, no TSX]
x86 Cascadelake-Server-v5  Intel Xeon Processor (Cascadelake) [ARCH_CAPABILITIES, EPT switching, XSAVES, no TSX]
```

Once you have your desired CPU model that you'd like to emulate set the `QEMU_SYSTEM_X86_64` environment variable. In my case, I set the the environment variable with the following (and add it to one of your shell's configuration files to persist between sessions):

```
export QEMU_SYSTEM_X86_64="qemu-system-x86_64 -cpu Cascadelake-Server"
```

Now, as a non-root user, create your Lima VM:

```
limactl start default
```

At the time of writing this process is extremely slow for the VM to actually come up. You can monitor it's progress with the following command:

```
tail -f ~/.lima/default/serial.log
```

Even after the VM comes up, the cloud-init stuff takes _a while_ to run. But once everything is up and running you can actually run container images like the official [hello-world](https://hub.docker.com/_/hello-world) image:

```
$ lima nerdctl run -it --rm hello-world

WARN[0000] cannot detect whether AES accelerator is available, assuming true  error="<nil>"
Unable to find image 'hello-world:latest' locally
latest: Pulling from library/hello-world
2db29710123e: Pull complete
Digest: sha256:80f31da1ac7b312ba29d65080fddf797dd76acfb870e677f390d5acba9741b17
Status: Downloaded newer image for hello-world:latest

Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (amd64)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/

failed to resize tty, using default size
```

As you can see from the above command, the default template uses `nerdctl` -- a drop-in replacement for Docker. You can create an alias named `docker` for the `nerdctl` instance like so:

```
alias docker='lima nerdctl $@'
```

## Next steps: 

I'm going to try to figure out if there is any way to speed up the VM. Getting a Docker VM running on FreeBSD in the first place was a big starting point so speeding things up will make a big difference and hopefully make Lima on FreeBSD a lot more usable.
