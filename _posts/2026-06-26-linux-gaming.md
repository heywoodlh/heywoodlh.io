---
title: "My 2026 Linux (NixOS) gaming setup"
published: true
permalink: /linux-gaming-2026/
tags: [ linux, steam, gaming ]
---

I use Linux, specifically NixOS, for the majority of my gaming, so I wanted to compile a list of references for anyone interested in replicating my setup.

## My general-purpose Linux gaming recommendations

Before getting into the specifics of my setup, I'll provide some general-purpose advice.

### Use CachyOS

If you came here for a recommendation on what Linux gaming distro to use, I would recommend [CachyOS](https://cachyos.org/) for the following reasons:
- It is based on Arch, which makes it easy to get bleeding edge updates
- The CachyOS Gaming Wiki is an awesome Linux gaming resource (even if you don't use CachyOS): [Gaming with CachyOS Guide](https://wiki.cachyos.org/configuration/gaming/)
- CachyOS' publicly documented kernel settings are excellent: [github:CachyOS/CachyOS-Settings](https://github.com/CachyOS/CachyOS-Settings)

### A quick rant: don't use Nvidia 50xx GPUs for Linux gaming

If you're exploring buying a dedicated GPU for a Linux gaming rig, I cannot recommend buying a 50xx series GPU because of Nvidia's driver UX. When I first got my 50xx series GPU, driver updates were absolutely horrendous, often breaking things on Linux _and_ Windows. Thankfully, as of June 2026 my anecdotal experience is that driver updates are far less disruptive, but I would never recommend a 50xx series GPU if you have options.

Additionally, to use the Nvidia driver on Linux, you have to disable secure boot. On my one system that I dual-boot Windows, I cannot play Battlefield 6 because Secure Boot has to be disabled for the Linux Nvidia driver to work. I'm not a fan of how invasive these anti-cheat engines are -- but I'm also not a fan of my GPU driver on Linux preventing me from playing specific games at all.

The feeling I am left with is that Linux gaming experience is definitely second-class. AMD sucks, too, for various reasons, but Linux support is far better and a dedicated AMD GPU would be my recommendation for a dedicated Linux gaming machine.

### My overall Linux GPU recommendation: Intel Arc Battlemage

Even with the current AI bubble inflating costs of computer parts, the Intel Arc GPUs are far more affordable than the AMD and Nvidia GPUs. Additionally, the Intel Arc GPU driver is bundled with the Linux kernel -- so a relatively modern Linux kernel version should allow the Intel Arc to _just work_ on Linux.

The Intel Arc won't exceed AMD and Nvidia GPUs, but it will be a far cheaper option and a better RoI.

## My gaming machines

I have three gaming machines I use (ordered by how much I play on them):
1. [nixos-gaming (custom dedicated gaming machine) configuration](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/hosts/gaming.nix)
2. [nixos-blade (Razer Blade 14) configuration](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/flake.nix#L1011-1043)
3. [steam-deck configuration](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/hosts/steam-deck.nix)

I mostly play on my `nixos-gaming` machine which sits in a closet, but find myself falling back to my Razer Blade 14 when I play away from home, or my Steam Deck when I need an ultra-portable setup.

There are some hardware-specific deviations I'll share below, but the majority of the configuration is shared amongst these machines.

## Dedicated gaming `nixos-gaming` machine hardware

My dedicated gaming machine is a custom build with the following hardware:
- CPU: AMD Ryzen 7 5700X3D
- GPU: Nvidia 5070 Ti (16 GB VRAM)
- RAM: 32 GB DDR5 RAM

For game streaming with Sunshine I also have a 120Hz HDMI dummy dongle that I leave plugged into my GPU.

For more details on the specific hardware configuration I have see: <https://pcpartpicker.com/user/heywoodlh/saved/#view=qrD7vK>

### Dual booting NixOS and Windows

I dual-boot Windows on my dedicated gaming machine and have a nice little shell script to easily reboot into Windows if I ever want to play games that are unsupported on Linux: [reboot-windows](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/hosts/gaming.nix#L42-44)

## NixOS Steam Deck

I have a first generation Steam Deck. I wrote a post a while ago on how I installed NixOS on my Steam Deck (that is mostly still applicable): [Installing NixOS on the Steam Deck](https://heywoodlh.io/nixos-steamdeck)

It is enabled by Jovian NixOS: [github:Jovian-Experiments/Jovian-NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS)

Overall, if you like NixOS and you like the Steam Deck, I highly recommend installing NixOS on it -- otherwise SteamOS is awesome, too!

## NixOS configuration

I have my configuration separated into custom NixOS modules:
- General purpose gaming configuration: [gaming.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/modules/gaming.nix)
- Nvidia driver configuration with nvidia-patch: [nvidia-patch.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/modules/nvidia-patch.nix)
- Sunshine for game streaming: [sunshine.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/modules/sunshine.nix)

I do the majority of my gaming via Moonlight + Sunshine on an Apple TV with a controller or an M4 iPad Pro with an Xbox Elite 2 controller.

### Desktop environments: KDE and Hyprland

I'm using KDE as my desktop environment for dedicated gaming machines, with a relatively minimal config here: [kde.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/modules/kde.nix)

For general-purpose Linux machines I use Hyprland (i.e. on my Razer Blade 14 away from home):
- [[nixos] hyprland.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/nixos/modules/hyprland.nix)
- [[home-manager] hyprland.nix](https://tangled.org/heywoodlh.io/nixos-configs/blob/5c53f838926eab9608ea7713e63debe7e8f84b4d/home/modules/hyprland.nix)

I used to daily drive GNOME, but when it came to gaming, I found it could be inconsistent. KDE has felt far better when I want things to _just work_. Hyprland has been a good experience as well, although, certain games' windowing can behave a bit strangely with Hyprland's automatic window tiling.

## CachyOS settings

The following links will be helpful for anyone wanting to reference CachyOS settings:
- [CachyOS-Settings repository](https://github.com/CachyOS/CachyOS-Settings)
- [CachyOS Kernel](https://wiki.cachyos.org/features/kernel/) on NixOS via [github:xddxdd/nix-cachyos-kernel](https://github.com/xddxdd/nix-cachyos-kernel)
- [Proton CachyOS](https://github.com/CachyOS/proton-cachyos) fetched via my custom script [proton-custom.sh](https://tangled.org/heywoodlh.io/nixos-configs/blob/82b05e519f236e9b9fc75fafd94c920a6fef5276/nixos/modules/gaming.nix#L17-82)
- My `git` diff for my NixOS configuration replicating their settings: <https://github.com/heywoodlh/nixos-configs/compare/68cdc39..f43d984>
