---
title: "Installing NixOS on the Steam Deck"
layout: post
published: false
permalink: nixos-steamdeck 
tags: all, linux, nix, nixos, steam, deck, steamdeck
---

## Why not keep SteamOS? 

I have a Steam Deck and I really enjoy it. SteamOS on the Steam Deck is based on Arch Linux and I'm very comfortable with Arch as a long-time user. However, there are two issues that I have with the Steam Deck's base OS:
- It wipes out custom changes I've made between updates, specifically, I have to reinstall and re-enable Wireguard between SteamOS updates
- I'm not a fan of KDE at all -- I definitely prefer GNOME

Wireguard is especially important to me on my Steam Deck because I use Wireguard and the open source [Moonlight project](https://github.com/moonlight-stream) to remotely connect to my more powerful gaming PC using Nvidia's proprietary gamestream protocol to do the majority of my gaming. 

I've been using NixOS on my Linux workstations and Nix on Darwin on my Macs and I enjoy having a declarative/reproducible workstation. So I did some initial research and found that the NixOS community is actively developing stuff for the Steam Deck here: [Jovian-NixOS](https://github.com/Jovian-Experiments/Jovian-NixOS)

## Installing NixOS on the Steam Deck:

### Requirements/Assumptions:

My desired setup uses GNOME. If you want anything besides GNOME, modify this guide to your needs.

The main requirements are the following:
- A Linux/MacOS machine with the Nix package manager installed
- Absolutely required: an external monitor and the necessary dongles/cables to connect the Steam Deck to it (required as of this Github Issue: [Jovian-Experiments/Jovian-NixOS/issues/39](https://github.com/Jovian-Experiments/Jovian-NixOS/issues/39))
- An external keyboard and mouse and necessary dongles/cables to connect to the Steam Deck

### Creating an Installer ISO:

Assuming you have the Nix package manager and `git` installed on your machine, you should be able to create a GNOME installer ISO with the following command (it takes quite a long time):

```
git clone https://github.com/Jovian-Experiments/Jovian-NixOS
cd Jovian-NixOS
nix-build -A isoGnome
```

I've uploaded a copy of my build to Google Drive, you can download it with this link (I'm not malicious but you should definitely be wary of strangers so don't download this unless you accept the risks of trusting strangers on the internet):


