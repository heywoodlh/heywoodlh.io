---
title: 'Building Cross-Architecture Docker Images'
layout: post
permalink: cross-architecture-docker-images
tags: all, linux, docker, containers, arm, x86
---

Recently I wrote about [building ARM Docker images on an x86 machine](https://the-empire.systems/arm-containers-linux). However, my chosen method was a bit hackey where you didn't end up with a single Docker image tag that could be used on any architecture. So I did some more research and found the Docker [Buildx](https://github.com/docker/buildx) plugin which helped me get much more desirable results.

The following articles got me moving in the right direction:
- [Preparation toward running Docker on ARM Mac: Building multi-arch images with Docker BuildX](https://medium.com/nttlabs/buildx-multiarch-2c6c2df00ca2)
- [Multi-arch build and images, the simple way](https://www.docker.com/blog/multi-arch-build-and-images-the-simple-way/)


## Setup:

I'm going to make the following assumptions:
- You're going to be building your pipeline on an x86 64 bit Linux machine.
- You already have Docker installed and running on said Linux machine.
- You are running Docker version 19.03.

_Note: I tried doing these steps on my Raspberry Pi 4 8GB model and the build process was just so slow (over 20 minutes) for x86 64 bit images that I decided it wasn't worth it. Please [let me know](https://the-empire.systems/contact) if there is some way to speed this up on the Pi 4._

### Installing Buildx:

First, we need to enable experimental mode on the Docker daemon.

Create `/etc/docker/daemon.json` with the following contents:

```bash
{ 
    "experimental": true 
}
```

Then restart Docker:

```bash
systemctl restart docker.service
```

Now we need to install buildx. The official documentation is [here](https://github.com/docker/buildx#installing) but I'll run through an example setup. Replace the references to 0.4.2 with [whatever the latest version number is](https://github.com/docker/buildx/releases/latest).

```bash
mkdir -p ~/.docker/cli-plugins/

curl -L https://github.com/docker/buildx/releases/download/v0.4.2/buildx-v0.4.2.linux-amd64 -o ~/.docker/cli-plugins/docker-buildx

chmod +x ~/.docker/cli-plugins/docker-buildx
```


Just to make sure it worked, try running `docker buildx`:

```bash
# docker buildx --help

Usage:  docker buildx [OPTIONS] COMMAND

Build with BuildKit

Options:
      --builder string   Override the configured builder instance

Management Commands:
  imagetools  Commands to work on images in registry

Commands:
  bake        Build from a file
  build       Start a build
  create      Create a new builder instance
  du          Disk usage
  inspect     Inspect current builder instance
  ls          List builder instances
  prune       Remove build cache 
  rm          Remove a builder instance
  stop        Stop builder instance
  use         Set the current builder instance
  version     Show buildx version information 

Run 'docker buildx COMMAND --help' for more information on a command.
```

### Setup QEMU Binfmt:

In order for Docker to build across architectures, it can use QEMU images to emulate the other architectures.

You can use the following Docker command to set up the QEMU images:

```bash
docker run --rm --privileged linuxkit/binfmt:v0.8
```

Make sure the QEMU images exist on your system for your target architectures:

```bash
# ls -1 /proc/sys/fs/binfmt_misc/qemu-*
/proc/sys/fs/binfmt_misc/qemu-aarch64
/proc/sys/fs/binfmt_misc/qemu-arm
/proc/sys/fs/binfmt_misc/qemu-ppc64le
/proc/sys/fs/binfmt_misc/qemu-riscv64
/proc/sys/fs/binfmt_misc/qemu-s390x
```

### Setup the Builder:

Run the following command to set up a builder image/container for `buildx` to use:

```bash
docker buildx create --use --name builder
```

Then bootstrap the builder and view what architectures are available to build with:

```bash
# docker buildx inspect --bootstrap
Name:   builder
Driver: docker-container

Nodes:
Name:      builder0
Endpoint:  unix:///var/run/docker.sock
Status:    running
Platforms: linux/amd64, linux/arm64, linux/riscv64, linux/ppc64le, linux/s390x, linux/386, linux/arm/v7, linux/arm/v6
```


## Building Cross-Platform Containers:

Now, in order to build your images, you can use `docker buildx build` and specify the platforms you want to target, like so:

```bash
docker buildx build --no-cache --platform linux/amd64,linux/arm64,linux/arm -t heywoodlh/example .
```

If you want to push the images to Docker Hub automatically you can add the `--push` flag to your `buildx` command.

Some advice I have would be to use base Docker images that are cross-architecture. For a lot of my containers I _used to use_ the [official Arch Linux Docker image](https://hub.docker.com/_/archlinux?tab=tags), but that only supports x86-64 and so it can't be used on ARM. I now prefer the [Alpine](https://hub.docker.com/_/alpine) image or the [Debian](https://hub.docker.com/_/debian) image.


### Bonus: My Script/Cron for Building:

All of my Dockerfiles are on [Github](https://github.com/heywoodlh/dockerfiles). I use the following script that runs via `cron` once a day:


```bash
#!/usr/bin/env bash

dockerDir="/opt/dockerfiles"

cd ${dockerDir}
git pull origin master 


buildContainer () {
        container=$1
        echo "Building ${container} container..."
        cd ${dockerDir}/${container}/
        docker buildx build --no-cache --platform linux/amd64,linux/arm64,linux/arm --push -t heywoodlh/${container} . &&\
                error="false"
        if [[ ${error} == "false" ]]
        then
                echo "Building ${container} container succeeded!"
        else
                echo "Building ${container} container failed!" | ssmtp user@example.com
        fi
}

if [[ $1 != '' ]]
then
        container=$1
        buildContainer ${container} 
        exit 0
fi

# tomnomnom-tools build
buildContainer tomnomnom-tools

# red build
buildContainer red

# telnet build
buildContainer telnet

# metasploit build
buildContainer metasploit

# links build
buildContainer links

# aerc build
buildContainer aerc

# vt-cli build
buildContainer vt-cli

# openssh build
buildContainer openssh

# evilginx2 build
buildContainer evilginx2

# jackit build
buildContainer jackit

docker system prune -af
```


Clearly this is specific to how I organize things and you could definitely have something a bit more complex than I have here, but hopefully it's a good starting point for anyone wanting to build their own cross-architecture Docker build pipeline. 
