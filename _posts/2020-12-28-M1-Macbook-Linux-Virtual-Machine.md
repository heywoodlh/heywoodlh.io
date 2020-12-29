---
title: 'Create a Linux Virtual Machine on M1 Macbook'
layout: post
permalink: m1-mac-linux-vm
tags: all, mac, linux
---

In this post I'll outline my process for setting up a Linux virtual machine using [Apple's new Virtualization framework](https://developer.apple.com/documentation/virtualization).


References:

[https://finestructure.co/blog/2020/11/27/running-docker-on-apple-silicon-m1](Running Docker on Apple Silicon M1)

[https://iphonesdkdev.blogspot.com/2020/12/20201202.html](How to run docker on the new Mac Mini M1)

[https://www.adamlabay.net/2020/06/27/creating-an-arm64-debian-image/](Creating an ARM64 Debian Image)

[https://github.com/JacopoMangiavacchi/M1-Linux-SSH](Apple M1 Linux VM with SSH interface)

## Setup vftool:

[Vftool](https://github.com/evansm7/vftool) is a command-line wrapper for the virtualization framework Apple introduced in MacOS Big Sur.

```bash
git clone https://github.com/evansm7/vftool /tmp/vftool
cd /tmp/vftool
make
sudo cp build/vftool /usr/local/bin/vftool
```

The `vftool` binary should now be installed.


## Setup Virtual Machine:

Let's put the VM resources in `/opt/virtual-machine`:

```bash
sudo mkdir -p /opt/virtual-machine
sudo chown -R $USER /opt/virtual-machine
```

### Ubuntu Setup:

Grab Ubuntu arm64 image:

```bash
curl -L 'https://cdimage.ubuntu.com/releases/focal/release/ubuntu-20.04.1-live-server-arm64.iso' -o /opt/virtual-machine/ubuntu.iso
```

Mount the ISO:

```bash
sudo mkdir /Volumes/Ubuntu
sudo hdiutil attach -nomount /opt/virtual-machine/ubuntu.iso
sudo mount -t cd9660 /dev/disk4 /Volumes/Ubuntu # The disk number should be showed in the output of the last command
```

Grab initrd:

```bash
cp /Volumes/Ubuntu/casper/initrd /opt/virtual-machine/initrd.lz4
```

Extract the initrd.lz4 file (get `unlz4` with `brew install -s lz4`):

```bash
unlz4 /opt/virtual-machine/initrd.lz4 /opt/virtual-machine/initrd
```

Grab vmlinuz:

```bash
cp /Volumes/Ubuntu/casper/vmlinuz /opt/virtual-machine/vmlinuz.gz
gunzip /opt/virtual-machine/vmlinuz.gz
```


### Storage setup:

This command will create a 50GB empty file for use in the VM:

```bash
/bin/dd if=/dev/zero of=/opt/virtual-machine/data.img bs=1m count=51200
```


## Run the VM:

We will only allocate 1GB of RAM to the VM:

```bash
vftool -k /opt/virtual-machine/vmlinuz -i /opt/virtual-machine/initrd -d /opt/virtual-machine/ubuntu.iso -d /opt/virtual-machine/data.img -m 1024 -a "console=hvc0 persistent rw"
```

You should see some output that looks like this:


```bash
2020-12-28 18:17:28.479 vftool[59793:281807] +++ Waiting for connection to:  /dev/ttys002
```

In another terminal window connect to `/dev/ttys002`:

```bash
screen /dev/ttys002
```

That should boot the Virtual Machine.


## Install Ubuntu Manually:

The installer menu did not render properly in the terminal for me so I just hit CTRL+Z to enter a shell and ran through the installation manually.

Set time:

```bash
systemctl start systemd-timesyncd.service
```

I then followed my manual installation instructions: [Minimal Ubuntu Install](https://the-empire.systems/minimal-ubuntu-install)

### Disk Partitioning and Formatting:

Partitioning:

```bash
parted /dev/vdb -- mklabel gpt
parted /dev/vdb -- mkpart primary 512MiB -8GiB
parted /dev/vdb -- mkpart primary linux-swap -8GiB 100%
parted /dev/vdb -- mkpart ESP fat32 1MiB 512MiB
parted /dev/vdb -- set 3 esp on
```

Formatting:

```bash
mkfs.vfat /dev/vdb3
mkswap /dev/vdb2 && swapon /dev/vdb2
mkfs.btrfs /dev/vdb1
```


### Install and Configure Ubuntu:

Mount drives:

```bash
mount /dev/vdb1 /mnt
mkdir -p /mnt/boot/efi && mount /dev/vdb3 /mnt/boot/efi
```

Bootstrap Ubuntu:

```bash
debootstrap --arch arm64 focal /mnt http://ports.ubuntu.com/ubuntu-ports
```

Configure apt repos:

```bash
printf "deb http://ports.ubuntu.com/ubuntu-ports/ focal main restricted\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal universe\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-backports main restricted universe multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-security main restricted\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-security multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-security universe\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-updates main restricted\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-updates multiverse\ndeb http://ports.ubuntu.com/ubuntu-ports/ focal-updates universe" > /mnt/etc/apt/sources.list
```

Install some dependencies:

```bash
apt-get install -y --no-install-recommends linux-generic linux-image-generic linux-headers-generic initramfs-tools linux-firmware efibootmgr openssh-server

## Optional/opinionated dependencies
apt-get install -y vim
```

Set timezone:

```bash
dpkg-reconfigure tzdata
```

Set locale:

```bash
dpkg-reconfigure locales
```

Set hostname:

```bash
echo 'ubuntu-vm' > /etc/hostname
```

Edit `/etc/hosts`:

```bash
printf "127.0.0.1   localhost\n::1   localhost\n127.0.1.1    ubuntu-vm.localdomain ubuntu-vm\n\n" > /etc/hosts
```

Set root user password:

```bash
passwd
```

Create an admin user:

```bash
adduser myusername
usermod -aG sudo myusername
```

Enable SSH on boot:

```bash
systemctl enable ssh.service
```

Create systemd-boot config:

```bash
printf "default ubuntu\ntimeout 1\neditor 0\n\n" > /boot/efi/loader/loader.conf
```

Then create a boot entry file in `/boot/efi/loader/entries/ubuntu.conf`, replacing the `PARTUUID` section with the root partition found with blkid:

```bash
title   Ubuntu
linux   /ubuntu/vmlinuz-generic
initrd  /ubuntu/initrd.img-generic
options root=PARTUUID=YOUR_UUID rw
```


The only problem with using systemd-boot is that you’d need to manually update the kernels any time a new version of the Linux kernel is installed. To solve this, we will create a post install hook that will update the kernel entries in systemd-boot.

Create /etc/kernel/postinst.d/update-systemd-boot with the following content, replacing the PARTUUID variable value with the value of your root PARTUUID found from blkid:

```bash
#!/bin/bash
#
# This is a simple custom kernel hook to populate the systemd-boot entries
# whenever kernels are added or removed during an update.
#


# The PARTUUID of your root partition
PARTUUID="INSERTYOURPARTUUIDHERE"

vmlinuz=$(find /boot -maxdepth 1 -name "vmlinuz-*-generic")
version=$(echo $vmlinuz | grep -o -P "\d+\.\d+\.\d+\-\d+" | sort -V | head -n -1)
latest=$(echo $vmlinuz | grep -o -P "\d+\.\d+\.\d+\-\d+" | sort -V | tail -n 1)

echo ">> COPYING ${latest}-generic. LATEST VERSION."

cat << EOF > /boot/efi/loader/entries/ubuntu.conf
title   Ubuntu
linux   /ubuntu/vmlinuz-generic
initrd  /ubuntu/initrd.img-generic
options root=PARTUUID=${PARTUUID} rw
EOF

for file in initrd.img vmlinuz; do
    cp "/boot/${file}-${latest}-generic" "/boot/efi/ubuntu/${file}-generic"
done

for ver in $version; do

    echo ">> COPYING ${ver}-generic."

cat << EOF > /boot/efi/loader/entries/ubuntu-${ver}.conf
title   Ubuntu ${ver}
linux   /ubuntu/vmlinuz-${ver}-generic
initrd  /ubuntu/initrd.img-${ver}-generic
options root=PARTUUID=${PARTUUID} rw
EOF

    for file in initrd.img vmlinuz; do
        cp "/boot/${file}-${ver}-generic" "/boot/efi/ubuntu/${file}-${ver}-generic"
    done
done
```

Make the script executable and symlink it to another relevant location:

```bash
chmod +x /etc/kernel/postinst.d/update-systemd-boot
ln -s /etc/kernel/postinst.d/update-systemd-boot /etc/kernel/postrm.d/update-systemd-boot
```

Setup Systemd-boot:

```bash
bootctl --path=/boot/efi install
```

Now, execute the hook script to move the kernel images to the correct directories for our systemd-boot config to recognize them:

```bash
/etc/kernel/postinst.d/update-systemd-boot
```

Verify boot entries:

```bash
bootctl list
```

I have noticed that Ubuntu has this annoying habit of installing Grub for you, so let’s prevent grub packages from installing:

```bash
Package: grub-common grub-gfxpayload-lists grub-pc grub-pc-bin grub2-common
Pin: release *
Pin-Priority: -1
```

Use exit to get out of the chroot:

```bash
exit
```

Then poweroff the VM:

```bash
poweroff
```

## Testing the VM:

Run the VM again, without mounting the live ISO:

```bash
vftool -k /opt/virtual-machine/vmlinuz -i /opt/virtual-machine/initrd -m 1024 -d /opt/virtual-machine/data.img -a "console=hvc0 persistent rw" 
```

## Running the VM in the background:

Run the following command in a script or launchd plist file to run the virtual machine:

```bash
vftool -k /opt/virtual-machine/vmlinuz -i /opt/virtual-machine/initrd -m 1024 -d /opt/virtual-machine/data.img -t 0 -a "console=hvc0 persistent rw"
```
