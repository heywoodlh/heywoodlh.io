---
title: 'Minimal Ubuntu Install (Install Ubuntu the Arch Way)'
slug: minimal-ubuntu-install
date: 2020-04-03
autotoc: true
excerpt: true
layout: post.html
collection: all, linux
---

This article will walk through a minimal and manual installation of Ubuntu, comparable to the Arch Linux installation process.

Inspired by the following Reddit Post: [Passing the Time in Quarantine (Installed Ubuntu the Arch Way)](https://www.reddit.com/r/archlinux/comments/fnilaf/passing_the_time_in_quarantine_installed_ubuntu/?utm_source=share&utm_medium=web2x)

## Setup:

### Boot Into Live Environment:

- [Download the latest desktop or server Iso](https://ubuntu.com/download) (I would recommend the desktop Iso for simplicity).
- Create bootable media (using something like [Etcher](https://www.balena.io/etcher/), then boot off of your live media. 
- Make sure to select "Try Ubuntu" not "Install Ubuntu" when you get to the Grub menu options.

### Requirements:

Make sure your Ubuntu environment has a network connection. If you used the desktop Iso, just use the Network Manager applet in the top right hand corner to connect. I will not get into the details of getting wifi connected via CLI, just use an ethernet cable if you can't figure it out.

I will assume that UEFI is desired boot mode.

I will also assume that you have elevated to root to run all the remaining commands (`sudo su -`).

## Installation:

### Dependencies:

```bash
## Add the Universe repository for arch-install-scripts
add-apt-repository universe

apt-get update
apt-get install -y debootstrap arch-install-scripts
```

### Disk Partitioning:

List your disks and their partitions with the following command:

`lsblk`

The output will show a list of disks, their partitions and their sizes. My disk is an 80 GB drive named `/dev/sda`. Change your drive paths as needed in the following commands to fit your installation.

Now, let's edit the drive partitions with `fdisk`

`gdisk /dev/sda`


Create the EFI partition:

Press n, 1 [Enter], [Enter], +512M [Enter], ef00 [Enter]


Create the swap partition (I'm just going to use 4GB of swap space):

Press n, 2 [Enter], [Enter], +4G [Enter], 8200 [Enter]



Create the root partition:

Press n, 3 [Enter], [Enter], [Enter], [Enter]


Write the changes:

Press w, Y [Enter]


### Partition Formatting:

Use the following commands to format your disk.

```bash
mkfs.vfat /dev/sda1

mkswap /dev/sda2 && swapon /dev/sda2

mkfs.btrfs /dev/sda3
```


### Bootstrap Ubuntu:

Mount the partitions we created earlier:

```bash
mount /dev/sda3 /mnt
mkdir -p /mnt/boot/efi && mount /dev/sda1 /mnt/boot/efi
```

Then bootstrap your base Ubuntu install (using Ubuntu 20.04 "Focal Fossa"):

```bash
debootstrap --arch amd64 focal /mnt http://archive.ubuntu.com/ubuntu
```

Edit `/mnt/etc/apt/sources.list` to not only have the `main` repository but also `universe` (community packages) and `restricted` (proprietary drivers) and the security repo:

```bash
release="focal"

printf "deb http://archive.ubuntu.com/ubuntu/ ${release} main restricted universe\ndeb http://security.ubuntu.com/ubuntu/ ${release}-security main restricted universe\ndeb http://archive.ubuntu.com/ubuntu/ ${release}-updates main restricted universe\n" > /mnt/etc/apt/sources.list 
```

Create a new fstab for the new installation:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```

Look at `/mnt/etc/fstab` and fix any errors if needed.



### Configuring Ubuntu:

Chroot into the new installation:

```bash
arch-chroot /mnt
```


Update repository data and install additional dependencies (modify packages as needed):

```bash
apt-get update

## Necessary dependencies
apt-get install -y --no-install-recommends linux-generic linux-image-generic linux-headers-generic initramfs-tools linux-firmware efibootmgr

## Optional/opinionated dependencies
apt-get install -y vim
```

Set timezone:

```bash
dpkg-reconfigure tzdata
```

Set locale (I use `en_US.UTF-8`):

```bash
dpkg-reconfigure locales
```


Set hostname: 

Edit `/etc/hostname` to equal whatever value you want your computer name to be:

```bash
echo 'myhostname' > /etc/hostname
```

Set root password:

```bash
passwd
```


Then install your preferred desktop environment, display manager, etc. I'll just use GNOME Shell + GDM as an example because I'm boring:

```bash
apt-get install -y gnome-shell gnome-terminal gdm3 firefox
```

Add a sudo user:

```bash
adduser myusername

usermod -aG sudo myusername
```

Create new directories:

```bash
mkdir -p /boot/efi/ubuntu/
mkdir -p /boot/efi/loader/entries
```

Create a systemd-boot config file `/boot/efi/loader/loader.conf` with the following lines:

```bash
default ubuntu
timeout 1
editor 0
```

Then create a boot entry file in /boot/efi/loader/entries/ubuntu.conf, *replacing the PARTUUID with the root partition found with `blkid`*:

```bash
title   Ubuntu
linux   /ubuntu/vmlinuz-generic
initrd  /ubuntu/initrd.img-generic
options root=PARTUUID=YOUR_UUID rw
```


The only problem with using `systemd-boot` is that you'd need to manually update the kernels any time a new version of the Linux kernel is installed. To solve this, we will create a post install hook that will update the kernel entries in systemd-boot.

Create `/etc/kernel/postinst.d/update-systemd-boot` with the following content, *replacing the `PARTUUID` variable value with the value of your root PARTUUID found from `blkid`*:

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


Now, execute the hook script to move the kernel images to the correct directories for our `systemd-boot` config to recognize them:

```bash
/etc/kernel/postinst.d/update-systemd-boot
```


Verify boot entries:

```bash
bootctl list
```


### Exit:

Use the `exit` command to get out of the chroot.

Then reboot!

```bash
reboot
```
