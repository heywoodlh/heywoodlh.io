---
title: "Installing NixOS on the Steam Deck"
layout: post
published: true
permalink: nixos-steamdeck 
tags: all, linux, nix, nixos, steam, deck, steamdeck
---

![alt text](../images/steam-deck.gif "Steam Deck booting NixOS")

January 14, 2023 update: added changes to make GNOME touch friendly (using Home Manager to manage GNOME settings) with this commit: [https://github.com/heywoodlh/nixos-configs/commit/e20277093d53390e5a5cb0bb516f80022ff0be37](https://github.com/heywoodlh/nixos-configs/commit/e20277093d53390e5a5cb0bb516f80022ff0be37)

## Why not keep SteamOS? 

I have a Steam Deck and I really enjoy it. SteamOS on the Steam Deck is based on Arch Linux and I'm very comfortable with Arch as a long-time user. However, there are two issues that I have with the Steam Deck's base OS:
- It wipes out custom changes I've made between updates, specifically, I have to reinstall and re-enable Wireguard between SteamOS updates
- I'm not a fan of KDE at all -- I definitely prefer GNOME

Wireguard is especially important to me on my Steam Deck because I use Wireguard and the open source [Moonlight project](https://github.com/moonlight-stream) to remotely connect to my more powerful gaming PC using Nvidia's proprietary gamestream protocol to do the majority of my gaming. 

I've been using NixOS on my Linux workstations and Nix on Darwin on my Macs and I enjoy having a declarative/reproducible workstation. So I did some initial research and found that the NixOS community is actively developing stuff for the Steam Deck here: [Jovian-NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS)

## Installing NixOS on the Steam Deck:

For those uninterested in the rest of the how-to, here's my current NixOS config on the Steam Deck: https://github.com/heywoodlh/nixos-configs/blob/master/workstation/steam-deck.nix

### Requirements/Assumptions:

My desired setup uses GNOME as the desktop environment and installs NixOS as the exclusive operating system on the Steam Deck. If you want anything outside of these constraints, modify this guide to your needs.

The main requirements are the following:
- Absolutely required: an external monitor and the necessary dongles/cables to connect the Steam Deck to it (required as of this Github Issue: [Jovian-Experiments/Jovian-NixOS/issues/39](https://github.com/Jovian-Experiments/Jovian-NixOS/issues/39))
- An external keyboard and mouse and necessary dongles/cables to connect to the Steam Deck

### Creating an Installer ISO and to Bootable USB:

Assuming you have the Nix package manager installed on a Linux or MacOS machine and `git` installed on your machine, you should be able to create a GNOME installer ISO with the following command (it takes quite a long time):

```
git clone https://github.com/Jovian-Experiments/Jovian-NixOS
cd Jovian-NixOS
nix-build -A isoGnome
```

When the command completes, it should show the resulting ISO in your filesystem. 

I've uploaded a copy of my ISO to Google Drive, which may save some time if you download it. Feel free to use this link (I'm not malicious but you should definitely be cautious of strangers on the internet):

[nixos-steam-deck-22.11-x86_64-linux.iso](https://drive.google.com/file/d/1veXUlM-48ODxdnmRZ5YnaHS6jQefu_3m/view?usp=sharing)

Use your preferred method to flash the ISO to a bootable USB. [Balena Etcher](https://www.balena.io/etcher/) is a very user friendly option for creating bootable USB drives.

### Boot the Bootable USB:

Shut down your Steam Deck. Before powering it on, connect it to an external display -- this is absolutely required as of this Github issue: https://github.com/Jovian-Experiments/Jovian-NixOS/issues/39. At least for me, I couldn't boot from USB until I had an external display connected.

To enter the boot menu, hold down the Volume- and tap the Power button with the bootable USB connected to the Steam Deck.

### Install NixOS:

These steps are mostly identical to the NixOS [Manual Installation Instructions](https://nixos.org/manual/nixos/unstable/index.html#sec-installation-manual), just modified for the internal storage as the target drive to install.

Run these commands as the root user in the live environment:

```
parted /dev/nvme0n1 -- mklabel gpt

parted /dev/nvme0n1 -- mkpart primary 512MB -8GB

parted /dev/nvme0n1 -- mkpart primary linux-swap -8GB 100%

parted /dev/nvme0n1 -- mkpart ESP fat32 1MB 512MB

parted /dev/nvme0n1 -- set 3 esp on

mkfs.ext4 -L nixos /dev/nvme0n1p1

mkswap -L swap /dev/nvme0n1p2

mkfs.fat -F 32 -n boot /dev/nvme0n1p3

mount /dev/disk/by-label/nixos /mnt

mount /dev/disk/by-label/boot /mnt/boot

swapon /dev/nvme0n1p2

nixos-generate-config --root /mnt
```

Before installing NixOS, you can download my current (as of writing) config for the Steam Deck which sets up GNOME and the relevant modules from the Jovian-NixOS repository:

```
curl -L 'https://raw.githubusercontent.com/heywoodlh/nixos-configs/ebe30a392abee0426a80158af2f97ad56975d946/workstation/steam-deck.nix' -o /mnt/etc/nixos/steam-deck.nix
```

You should modify the newly downloaded `/mnt/etc/nixos/steam-deck.nix` file -- particularly lines 4 and 5 to match your username and user description. Additionally, you should modify the rest of the config files in `/mnt/etc/nixos/` to work for your 

Your `/mnt/etc/nixos/configuration.nix` can look something like this:

```
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./steam-deck.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nix-steam-deck"; # Define your hostname.

  # Set your time zone.
  time.timeZone = "America/Denver";

  system.stateVersion = "22.11";

}
```

Once your config suits your needs, install NixOS:

```
nixos-install
```

Set the root password and reboot. Once you login as root, run the following command to change the password for your normal, non-root user:

```
passwd <username>
```

## Conclusion:

With this setup, by default, NixOS will boot into the handheld Steam UI. For me, it works identically to SteamOS until I use "Switch to Desktop" -- which then boots into my preferred desktop environment (GNOME) and preferred OS (NixOS).

### Switch back to Steam after running "Switch to Desktop": 

I'm currently working on this, but in order to switch back into Steam's handheld Steam Deck UI after running "Switch to Desktop" I run the following command while in GNOME:

```
pkill -9 gnome-shell
```
