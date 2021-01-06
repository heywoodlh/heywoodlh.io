---
title: 'Create a Linux Virtual Machine on M1 Macbook'
layout: post
permalink: m1-mac-linux-vm
tags: all, mac, linux
---

In this post I'll outline my process for setting up a Linux virtual machine using [QEMU](https://qemu.org) on an M1 Macbook Pro.

Reference:

[[SUCCESS] Virtualize Windows 10 for ARM on M1 with Alexander Graf's qemu hypervisor patch](https://forums.macrumors.com/threads/success-virtualize-windows-10-for-arm-on-m1-with-alexander-grafs-qemu-hypervisor-patch.2272354/)

## Install QEMU:

At the time of writing `brew install -s qemu` fails on my M1 Macbook. Until the Homebrew formula is updated, we need to compile QEMU manually.

Install some dependencies:

```bash
brew install -s pkg-config glib pixman ninja
```

Clone and patch QEMU:

```bash
sudo git clone https://git.qemu.org/git/qemu.git /opt/qemu
sudo chown -R $USER /opt/qemu
cd /opt/qemu

mkdir bin && cd bin
../configure
make -j6
```

Add the `/opt/qemu/bin` directory to your PATH (might want to add this to your shell's config files to make this persist):

```bash
export PATH="/opt/qemu/bin:$PATH"
```

## Install Libvirt:

Let's also install libvirt to make managing QEMU VMs easier (`brew install -s libvirt` also doesn't work at the time of writing):

```bash
brew install -s meson libxml2 zlib

sudo git clone https://gitlab.com/libvirt/libvirt.git /opt/libvirt
sudo chown -R $USER /opt/libvirt
```

Since I'm using a custom Homebrew directory, I had to set the `$PKG_CONFIG_PATH` variable for the libxml2 and zlib files to be found properly. For example: 

```bash
HOMEBREW_DIR="$HOME/opt/homebrew"

export PKG_CONFIG_PATH="$HOMEBREW_DIR/Library/Homebrew/os/mac/pkgconfig/11.1/"
```

I was able to find the directory for the `PKG_CONFIG_PATH` variable with the following commands:

```bash
find $HOMEBREW_DIR -name "libxml-2.0.pc"
find $HOMEBREW_DIR -name "zlib.pc"
```


Let's compile libvirt to `/opt/libvirt/usr`:

```bash
cd /opt/libvirt
mkdir -p /opt/libvirt/usr
meson build --prefix=/opt/libvirt/usr
ninja -C build
mv /opt/libvirt/build /opt/libvirt/usr
```

## Setup the VM:

I will assume all the resources for the VM will be in a directory called  `/opt/virtual-machine`:

```bash
sudo mkdir -p /opt/virtual-machine
sudo chown -R $USER /opt/virtual-machine
```

### Download Debian Image:

```bash
curl 'https://cdimage.debian.org/cdimage/release/current/arm64/iso-dvd/debian-10.7.0-arm64-DVD-1.iso' -o /opt/virtual-machine/debian-arm64.iso
```

### Setup the Disk File:

```bash
qemu-img create /opt/virtual-machine/debian-vm.img 40G 
```

### Setup EFI Firmware:

Download the following zip file:

https://mega.nz/file/QYB0QTrC#p6IMBJlFqqNKuGonwrDkPOVKQj8yHCVgiLOYVaGvs4M

Unzip it and move the contents of the `qemu-m1` directory to `/opt/virtual-machine/`:

```bash
cp -r qemu-m1/* /opt/virtual-machine/
```

### Start the VM:

Create a script in `/opt/virtual-machine/start.sh` with the following contents:

```bash
#!/usr/bin/env bash

root_dir="/opt/virtual-machine"
cd "${root_dir}"

DYLD_LIBRARY_PATH="${root_dir}" "${root_dir}"/qemu-system-aarch64 \
        -M virt \
	-accel hvf \
        -m 1G \
        -smp 1 \
        -cpu max \
        -device ramfb \
        -serial stdio \
        -drive file="${root_dir}"/debian-arm64.iso,if=none,id=NVME1 \
        -device nvme,drive=NVME1,serial=nvme-1 \
        -device nec-usb-xhci \
        -device usb-kbd \
        -device usb-tablet \
        -device intel-hda -device hda-duplex \
	-hda "${root_dir}/debian-vm.img" \
        -drive file="${root_dir}"/vars-template-pflash.raw,if=pflash,index=1 \
        -bios ${root_dir}/QEMU_EFI.fd
```

Make the script executable:

```bash
chmod +x /opt/virtual-machine/start.sh
```

Now run the script:

```bash
/opt/virtual-machine/start.sh
```
