---
title: "Using NixOS-WSL as default SSH on Windows"
published: true
permalink: /nixos-wsl-ssh/
tags: [ windows, linux, nix, ssh, openssh ]
---

These are the commands I used to setup NixOS-WSL as my default shell on my Windows 11 gaming machine running OpenSSH. This article assumes that your default WSL distribution is NixOS-WSL.

## Setup /bin/bash symlink

In order to use WSL as the default shell for OpenSSH on Windows, you need to use `C:\Windows\System32\bash.exe` -- not `C:\Windows\System32\wsl.exe`. This command assumes that `/bin/bash` exists in your WSL distribution and by default on NixOS-WSL, it does not.

Add the following to `/etc/nixos/configuration.nix` to create a symlink to bash for `bash.exe` to use:

```
wsl.extraBin = [{
  name = "bash";
  src = "${pkgs.bash}/bin/bash";
}];
```

## Set WSL as the default shell for SSH

Run the following command in an Administrator PowerShell session to set WSL as your default shell for Windows:

```
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\bash.exe" -PropertyType String -Force
```

## BONUS: SSH key auth for admin users

In an Administrator PowerShell session, place your `authorized_keys` file at the following path:

```
C:\ProgramData\ssh\administrators_authorized_keys
```

I used to the following one-liner in an Administrator PowerShell session to setup my permitted SSH keys from GitHub:

```
curl.exe -L https://github.com/heywoodlh.keys -o "C:\ProgramData\ssh\administrators_authorized_keys"
```

## Restart SSH

Run the following command in Administrator PowerShell session to restart SSH:

```
Restart-Service sshd
```
