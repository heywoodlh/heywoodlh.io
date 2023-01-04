---
title: "Installing NixOS on the Steam Deck"
layout: post
published: false
permalink: nixos-steamdeck 
tags: all, linux, nix, nixos, steam, deck, steamdeck
---

I have a Steam Deck and I really enjoy it. SteamOS on the Steam Deck is based on Arch Linux and I'm very comfortable with Arch as a long-time user. However, there are two issues that I have with the Steam Deck's base OS:
- It wipes out custom changes I've made between updates, specifically, I have to reinstall and re-enable Wireguard between SteamOS updates
- I'm not a fan of KDE at all -- I definitely prefer GNOME

Wireguard is especially important to me on my Steam Deck because I use Wireguard and the open source [Moonlight project](https://github.com/moonlight-stream) to remotely connect to my more powerful gaming PC to do the majority of my gaming. 

I've been using NixOS on my Linux workstations and Nix on Darwin on my Macs and I absolutely love it. So I did some initial research and found that the NixOS community is actively develop
