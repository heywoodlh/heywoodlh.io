---
title: "NixOS on Thinkpad X13s"
layout: post
published: true
permalink: nixos-thinkpad-x13s
tags: all, linux, nixos, arm64, thinkpad, lenovo, x13s
---

This will be a short article pointing to some resources I struggled to find when initially setting up my new Lenovo X13s with NixOS.

I became interested in the X13s at this time because it looks like one of the only real competitors to the M1 Macbooks in regard to power efficiency. It's got a great battery life, is relatively powerful and better Linux support for this hardware seems to be on Lenovo's (and Canonical's) roadmap:

[Ubuntu runs on Arm Powered Thinkpad Lenovo Thinkpad X13S at Mobile World Congress 2023 #mwc23](https://www.youtube.com/watch?v=NwjnMozHXuU)

## Run all Windows updates -- seriously

Before doing anything, boot into Windows 11, run ALL of your updates -- especially the firmware updates.

I initially tried out Ubuntu on the X13s without updating the firmware. There were so many issues (keyboard not registering keystrokes, randomly being unable to power the laptop back on), it was terribly frustrating.

## Get a hardware-compatible ISO for the installation

At the time of writing, you can download the official Canonical Ubuntu 23.10 ISO for the X13s here: [Ubuntu 23.10.1 (Manic Minotaur)](https://cdimage.ubuntu.com/releases/mantic/release/)


## Install NixOS

First, get the tools needed to install NixOS:

```
sudo apt-get update && sudo apt-get install -y curl
sh <(curl -L https://nixos.org/nix/install) --daemon
sudo -i
nix-env -iA nixpkgs.nixos-install-tools
```

I won't go through the NixOS installation process itself, but you're going to have to do that manually. Here are some installation links I like to reference:

[NixOS Manual: Manual Installation](https://nixos.org/manual/nixos/stable/#sec-installation-manual)

[Installing NixOS with Full Disk Encryption](https://gist.github.com/mara-schulke/43e2632ce73d94028f50f438037c1578)

This is the most user-friendly resource I found to easily configure NixOS for the x13s: [codeberg:adamcstephens/nixos-x13s](https://codeberg.org/adamcstephens/nixos-x13s)

Before running `nixos-install`, you will need to add hardware compatibility for the X13s. I wasn't able to figure out how to do a fully flaked _initial_ install, so this is what I did for the initial `nixos-install`:

```
git clone https://codeberg.org/adamcstephens/nixos-x13s /mnt/etc/nixos/nixos-x13s
```

And then this was my initial `/mnt/etc/nixos/configuration.nix`:

```
{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./nixos-x13s/module.nix
    ];

  nixos-x13s.enable = true;
  nixos-x13s.kernel = "jhovold"; # jhovold is default, but mainline supported
  specialisation = {
    mainline.configuration.nixos-x13s.kernel = "jhovold";
  };
  nixpkgs.config.allowUnfree = true;
  nix.settings = {
    substituters = [
      "https://nixos-x13s.cachix.org"
    ];
    trusted-users = [
      "heywoodlh"
    ];
    trusted-public-keys = [
      "nixos-x13s.cachix.org-1:SzroHbidolBD3Sf6UusXp12YZ+a5ynWv0RtYF0btFos="
    ];
  };

  boot = {
    loader.systemd-boot.enable = true;
  };

  networking.hostName = "nixos-thinkpad";
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "America/Denver";

  users.users.heywoodlh = {
    isNormalUser = true;
    home = "/home/heywoodlh";
    extraGroups = ["wheel" "networkManager"];
  };

  system.stateVersion = "24.05";
}
```

You'll probably want to change the `users.users.heywoodlh` and `networking.hostname` to match your configuration, but I think the rest is self-explanatory.

After enabling the `nixos-x13s` module, you should be ready to run `nixos-install`.

After installing NixOS initially, I was able to pivot to my Flake at my [nixos-configs repo](https://github.com/heywoodlh/nixos-configs).

For reference, here's the X13s-specific configuration in my flake at the time of writing: [flake.nix](https://github.com/heywoodlh/nixos-configs/blob/3f002704691051a3fdcb018d60a32383caaa568c/flake.nix#L155-L190)

## Drawbacks

~~The Ubuntu image worked out of the box with fingerprint scanner -- it doesn't with my current configuration. I haven't tried to fix that yet.~~

This NixOS configuration gets the fingerprint scanner working (with GNOME at least):

```
services.fprintd.enable = true;
services.fprintd.tod.enable = true;
services.fprintd.tod.driver = pkgs.libfprint-2-tod1-goodix;
```

Battery life is the best I've ever experienced on a Linux machine (that isn't a super underpowered Chromebook) -- but it's noticeably not as good as Windows 11. But, at least I'm not being force-fed ads about Bing, Microsoft Edge and Teams. :)

## Additional resources

Here are some other resources I found that were helpful in piecing together how to install NixOS on the X13s:

[github.com/cenunix/x13s-nixos](https://github.com/cenunix/x13s-nixos)

[github.com/LunNova/nixos-configs: amayadori](https://github.com/LunNova/nixos-configs/tree/94c71df589ba2adf1b96bee7c7f87d5a4bf85a9a/hosts/amayadori)

[Linux on ThinkPad X13s Gen 1](https://openwebcraft.com/linux-on-thinkpad-x13s-gen-1/)

[NixOS on ThinkPad X13s: minimal configuration](https://dumpstack.io/1675806876_thinkpad_x13s_nixos.html)
