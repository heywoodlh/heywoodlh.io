---
title: 'Using Volatility on Arch Linux'
slug: arch-linux-router
date: 2020-03-26
autotoc: true
excerpt: true
layout: post.html
collection: all, linux, security
---

This article will walk through using Volatility on Arch Linux. Volatility's documentation didn't make too much sense to me with generating profiles so I am taking it upon myself to write up how I set it up. Also, Volatility is written in Python 2 and I don't like having that installed on my system, so I created a Docker image to fill that need.

## Prerequisites:

The following is assumed:
- Docker is installed and setup (to actually run my Volatility container)
- Your system is up-to-date and on the latest kernel (`sudo pacman -Syu && sudo reboot` if you aren't sure)

## Install Dependencies:

### Install LiME:

LiME is a tool made for dumping the volatile memory in Linux.

```bash 
sudo git clone https://github.com/504ensicsLabs/LiME /opt/lime &&\
    sudo chown -R $USER /opt/lime/ &&\
    cd /opt/lime/src &&\
    make
```

### Install Other System Packages:

The `libdwarf` package will be used to create a Volatility profile. It allows us to collect kernel configuration information such as supported kernel symbols, modules, etc. We also need to install the Linux kernel headers. Switch `linux-headers` with whatever kernel headers if you're using a custom kernel (like `linux-lts`, `linux-hardened`, etc.).

```bash
sudo pacman -Sy libdwarf linux-headers zip git asp --noconfirm
```


## Building a Volatility Profile:

Let's create a directory where all our files will be going:

```bash
mkdir -p /tmp/volatility_demo
```


Like, I said earlier, Volatility is written in Python 2. So we won't actually use `vol.py` on our system (since Arch doesn't have Python 2 installed by default -- nor do we want that). But the repository has some tools to easily create a profile so we will clone it into the `tmp` directory:

`git clone https://github.com/volatilityfoundation/volatility.git /tmp/volatility`


Now create the dwarf file:

```bash
cd /tmp/volatility/tools/linux &&\
    make dwarf
``` 

Now let's create the Volatility profile:


```bash
sudo zip /tmp/volatility_demo/Arch.zip /tmp/volatility/tools/linux/module.dwarf /usr/lib/modules/$(uname -r)/build/System.map
```

## Create a Memory Image With LiME:

Let's create a memory dump in our staging directory (this will take a while):

```bash
sudo insmod /opt/lime/src/lime-*.ko "format=lime path=/tmp/volatility_demo/arch-memory.lime digest=sha512" 
```

## Get Volatility Ready:

Create a config file `~/.volatilityrc` with the following content:

```bash
[DEFAULT]
PROFILE=LinuxArchx64
LOCATION=file:///data/arch-memory.lime
PLUGINS=/data
```

For ease of use, let's create a BASH alias for `vol.py` so you don't have to run a super long `docker run` command every time:

```bash
alias vol.py="docker run -it --rm -v ~/.volatilityrc:/root/.volatilityrc -w /data -v ${PWD}:/data heywoodlh/volatility --conf-file /root/.volatilityrc $@"
```


Now, make sure you are in the staging directory, and then run my Volatility Docker image to check if the Profile we made earlier is correct:

```bash
cd /tmp/volatility_demo &&\
    vol.py --info | grep Arch
```

The output should include `LinuxArchx64` as one of the profiles. If the name is something else, change the `PROFILE` setting in your `~/.volatilityrc` config.


Once that is set, you are basically good to use Volatility on the image we've created. You might want to set that `vol.py` alias in a relevant BASH configuration file so that it persists if that's what you desire.


Here are some example commands that you could run:

```bash
vol.py linux_banner

vol.py linux_bash

vol.py linux_hidden_modules
```
