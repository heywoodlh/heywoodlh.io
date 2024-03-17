---
title: "NixOS Server on M1 Mac Mini"
layout: post
published: true
permalink: nixos-mac-mini
tags: all, linux, nixos, asahi, m1, mac, mini, server, plex
---

This weekend I spent a bunch of time switching my media server from a really beefy Dell machine to an M1 Mac Mini. There were two primary reasons for this:
1. Reduce power consumption
2. Morbid curiosity to see how much mileage I can get with a powerful ARM64 Linux server

Outside of Asahi Linux on M1 hardware, my only ARM64 hardware running Linux has been with Raspberry Pis. I've been a long-time owner of many Raspberry Pis and I've grown increasingly uninterested in the Raspberry Pi hardware as it seems very incapable compared to M1-M3 Apple hardware. On top of that, it costs at least $100 to get a full kit for a really low-spec Raspberry Pi and a used M1 Mac Mini provides so much more for a reasonable price. A base model can be found on Swappa at the time of writing for around $400.

## Installing NixOS and Asahi Linux

This repository does most of the heavy lifting of getting NixOS set up with Asahi Linux to easily work on Apple hardware: [tpwrules/nixos-apple-silicon](https://github.com/tpwrules/nixos-apple-silicon)

With the Asahi Linux installer, I used the minimum amount of space for the macOS partition and the rest of the space for the NixOS partition. I went this route instead of completely nuking MacOS because as I understand it there is no way to install firmware updates without MacOS. On top of that, power-on failure needs to be configured in MacOS. With Asahi's defaults, my NixOS partition is the default boot option, and I can hold the power button to boot into MacOS.

These are my relevant NixOS configuration snippets for this setup at this time:
- [flake.nix#L153-L172](https://github.com/heywoodlh/nixos-configs/blob/c38c4d6f85fd1268530db3eea0e56b5664114d5f/flake.nix#L153-L172)
- [nixos/roles/nixos/asahi.nix](https://github.com/heywoodlh/nixos-configs/blob/c38c4d6f85fd1268530db3eea0e56b5664114d5f/nixos/roles/nixos/asahi.nix)

## My media server stack

You can see the primary media server things I'm running in my home network related to media consumption here: [plex.nix](https://github.com/heywoodlh/nixos-configs/blob/c38c4d6f85fd1268530db3eea0e56b5664114d5f/nixos/roles/media/plex.nix). My primary goal this weekend was to just get Plex up and running. My previous experiences with ARM64 and Linux has made me skeptical about how smooth the process would be (not because of ARM64 _or_ Linux -- but because of how little faith I have in software vendors to support ARM64 Linux).

Spoiler: it went really well -- a primary contributor is that Plex and the rest of the *arr stack supports ARM64 Linux and it's packaged in nixpkgs.

## Gotchas

One weird gotcha I ran into was that the huge pages configuration provided with Asahi Linux did _not_ like the cache provided by one of my BTRFS drives. I cleared the cache, and had to set the `space_cache=v2` mount option to get it to work.

Also I don't get hardware-accelerated streaming anymore, I recently enabled transcoding with an Nvidia Quadro GPU I had sitting in my former Plex server's hardware. [According to Plex's documentation](https://support.plex.tv/articles/115002178853-using-hardware-accelerated-streaming/) hardware-accelerated streaming is limited to Intel CPUs and Nvidia GPUs. It being day one of my new server hardware running Plex and streaming for a few hours, the responsiveness doesn't seem noticeably different to me -- but I'll update this post if I notice any performance issues.

Hopefully sometime Plex adds support for ARM64 hardware-accelerated streaming, but I'm really not unhappy with the current results I'm getting.

## Conclusion

This post was pretty short, but it's been fun to run Plex on Linux on M1 hardware! I'm looking forward to what I'll be able to run on this machine.
