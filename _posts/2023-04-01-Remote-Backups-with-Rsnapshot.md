---
title: "Remote Backups Over SSH With Rsnapshot"
layout: post
published: true
permalink: rsnapshot-backups
tags: [ linux, nixos, arch, ssh, rsync, rsnapshot, backup  ]
---

During a discussion I had with a former coworker at my previous job, he introduced me to [Rsnapshot](https://rsnapshot.org/). Rsnapshot is a backup program based on [rsync](https://github.com/WayneD/rsync), which allows for simple but effective remote backups over SSH.

I've built out my home lab to now support one server, my backup server, SSH-ing into my other servers and backing up the data I care about. This will be an overview on how I have this setup.

Disclaimer: I primarily use NixOS and some Arch Linux for my servers, so some NixOS `configuration.nix` snippets will be present

## Rsnapshot server:

I have one NixOS server with Rsnapshot installed and an SSH key that I've generated without a passphrase at `/root/.ssh/id_rsa`. 

At the time of writing, this is my NixOS configuration snippet for `rsnapshot`:

```
  services.rsnapshot = {
    enable = true;
    enableManualRsnapshot = true;
    cronIntervals = {
      daily = "0 3 * * *";
      hourly = "0 * * * *";
      weekly = "0 1 * * 1";
      monthly = "0 1 1 * *";
    };
    extraConfig = ''
#Separate everything with tabs, not spaces	
#Convert spaces to tabs in vim with :%s/\s\+/\t/g
snapshot_root	/media/backups/
retain	hourly	24
retain	daily	7
retain	weekly	4
retain	monthly	6

backup	root@ct-1.wireguard:/etc/	ct-1/
    '';
  };
```

On NixOS, this installs and configures `rsnapshot` to run on an hourly, daily, weekly and monthly basis. The last line in my `extraConfig` for `rsnapshot` shows the actual backup that is going to happen over SSH:

```
backup	root@ct-1.wireguard:/etc/	ct-1/
```

This will backup the `/etc/` folder on the remote server `ct-1.wireguard` and place it in a folder named `ct-1` -- if you combine that with my `snapshot_root` config, the actual backup path for the `/etc/` folder would be `/media/backups/ct-1/etc`. 

If you aren't on NixOS, the Arch Wiki has a great entry on setting up Rsnapshot:

[rsnapshot - ArchWiki](https://wiki.archlinux.org/title/Rsnapshot)

Add all of the remote servers and their paths to your `rsnapshot` configuration.

## Target servers:

On the target servers you only need the following setup:
- SSH access, preferably as `root` -- see my recommendations below on reducing security risk
- `rsync` installed

The `root` user is easiest to use on the remote server over SSH. However, logging in as `root` is a security risk, so there are a couple of precautions I would take:
- Configure `sshd_config` to only allow `root` login using SSH keys, prohibiting password authentication, with the following configuration: `PermitRootLogin prohibit-password`
- In setting up `/root/.ssh/authorized_keys`, restrict the key to only be used from a specific IP address: [ StackExchange - How to restrict an SSH key to certain IP addresses? ](https://unix.stackexchange.com/a/353047)
- Use a VPN and limit SSH access between your `rsnapshot` server over the VPN. I like Wireguard for VPN stuff: https://www.wireguard.com/


## Profit:

Once this is setup as described, you now have a remote backup solution that works over SSH.
