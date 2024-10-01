---
title: "Use Tarsnap for NixOS Backups"
published: true
permalink: /nixos-tarsnap/
tags: [ linux, nixos, tarsnap, backups ]
---

All resources at the time of writing are in my [nixos-configs repo on GitHub](https://github.com/heywoodlh/nixos-configs/tree/03f55d32fcf16bf5c96a0e6c18a5f60a03eabf84). I make no guarantee that the way I organize my repo will make sense to you. :)

## NixOS Configuration

This is my NixOS configuration for Tarsnap ([./nixos/roles/backups/tarsnap.nix](https://github.com/heywoodlh/nixos-configs/blob/03f55d32fcf16bf5c96a0e6c18a5f60a03eabf84/nixos/roles/backups/tarsnap.nix)):

```
{ config, pkgs, ... }:

let
  tarsnapSetup = pkgs.writeShellScriptBin "tarsnap-setup.sh" ''
    sudo ${pkgs.tarsnap}/bin/tarsnap-keygen \
      --keyfile /root/tarsnap.key \
      --user tarsnap@heywoodlh.io \
      --machine $(hostname)
  '';
  tarsnapList = pkgs.writeShellScriptBin "tarsnap-list-archives.sh" ''
    sudo ${pkgs.tarsnap}/bin/tarsnap --list-archives --keyfile /root/tarsnap.key --cachedir /var/cache/tarsnap/nixos-archive
  '';
  tarsnapRun = pkgs.writeShellScriptBin "tarsnap-run.sh" ''
    # General tarsnap options as arguments
    sudo ${pkgs.tarsnap}/bin/tarsnap $@ --configfile "/etc/tarsnap/nixos.conf" -c -f "nixos-$(date +"%Y%m%d%H%M%S")" /etc /opt /root /home
  '';
  tarsnapDryRun = pkgs.writeShellScriptBin "tarsnap-dry-run.sh" ''
    ${tarsnapRun}/bin/tarsnap-run.sh --dry-run
  '';
  tarsnapDeleteArchives = pkgs.writeShellScriptBin "tarsnap-delete-archives.sh" ''
    backups="$(${tarsnapList}/bin/tarsnap-list-archives.sh)"

    read -p "Are you sure you want to delete all Tarsnap arhives (yY)? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]
    then
        for backup in ''${backups}
        do
          echo "Backup: ''${backup}"
          sudo ${pkgs.tarsnap}/bin/tarsnap -d --keyfile /root/tarsnap.key --cachedir /var/cache/tarsnap/nixos-archive -f "''${backup}" && echo "Backup ''${backup} deleted"
        done
    fi
  '';
in {
  environment.systemPackages = with pkgs; [
    tarsnap
    tarsnapList
    tarsnapSetup
    tarsnapDryRun
    tarsnapRun
    tarsnapDeleteArchives
  ];
  services.tarsnap = {
    enable = true;
    package = pkgs.tarsnap;
    keyfile = "/root/tarsnap.key";
    archives = {
      nixos =  {
        cachedir = "/var/cache/tarsnap/nixos-archive";
        directories = [
          "/etc"
          "/opt"
          "/root"
          "/home"
        ];
        excludes = [
          "tarsnap.key"
          "shadow"
          "passwd"
          "nixpkgs"
          "containerd"
          ".cache"
          ".lima"
          ".local"
        ];
      };
    };
  };
}
```

## Initial setup on NixOS

Once my module is deployed to my NixOS server, I generate Tarsnap keys with my helper script on the NixOS server. This allows me to run `tarsnap-setup.sh` which prompts for login and places a key for managing that machine's backups at `/root/tarsnap.key`. You should back up these keys somewhere if you ever want to access/manage the server's backups.

The other helper scripts should be self-explanatory, and can be invoked with their script name:

- `tarsnap-list-archives.sh`
- `tarsnap-run.sh`
- `tarsnap-dry-run.sh`
- `tarsnap-delete-archives.sh`

## Backing up all my keys to 1Password

I have a helper script for me to run on a machine that can SSH into all my NixOS servers and grab the `/root/tarsnap.key` file and store them in 1Password. This is the helper script that is installed with my Home-Manager configuration here: [home/base.nix#L112-L120](https://github.com/heywoodlh/nixos-configs/blob/03f55d32fcf16bf5c96a0e6c18a5f60a03eabf84/home/base.nix#L112-L120)

```
{ config, pkgs, ... }:

let
  ...
  tarsnap-key-backup = pkgs.writeShellScriptBin "tarsnap-key-backup.sh" ''
    hosts=("nix-drive" "nix-nvidia" "nixos-gaming" "nixos-mac-mini")
    op_item="fp5jsqodjv3gzlwtlgojays7qe"

    for host in "''${hosts[@]}"
    do
      ssh heywoodlh@$host "sudo cp /root/tarsnap.key /home/heywoodlh/tarsnap.key; sudo chown -R heywoodlh /home/heywoodlh/tarsnap.key" && scp heywoodlh@$host:/home/heywoodlh/tarsnap.key $host && ssh heywoodlh@$host "rm /home/heywoodlh/tarsnap.key" && op-wrapper.sh item edit fp5jsqodjv3gzlwtlgojays7qe "$host[file]=$host" && rm $host
    done
  '';
in {

  home.packages = with pkgs; [
    ...
    tarsnap-key-backup
  ];

...
}
```

This allows me to run a script named `tarsnap-key-backup.sh` on any machine with my Home-Manager configuration installed (I'm assuming I'll have 1Password and SSH access) which saves my `tarsnap.key` files to 1Password.
