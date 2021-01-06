---
title: 'Debootstrap ARM64 Ubuntu'
layout: post
permalink: debootstrap-arm64-ubuntu
tags: all, linux
---

Putting these commands down as a reference for debootstrapping ARM64 Ubuntu 20.04 on a drive that's mounted at `/mnt/`:

Bootstrap Ubuntu:

```bash
debootstrap --arch arm64 focal /mnt http://ports.ubuntu.com/ubuntu-ports
```

Configure apt repos:

```bash
printf "deb http://ports.ubuntu.com/ubuntu-ports/ focal main restricted\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal universe\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-backports main restricted universe multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-security main restricted\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-security multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-security universe\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-updates main restricted\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-updates multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-updates universe" > /mnt/etc/apt/sources.list
```
