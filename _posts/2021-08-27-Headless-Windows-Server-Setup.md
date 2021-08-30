---
title: 'Headless Windows Server Setup'
layout: post
published: true
permalink: headless-windows-server
tags: all, windows, server, 2022, microsoft, ssh, powershell
---

This post will be used to document how I prefer to setup a fresh installation of Windows Server. Specifically, I am using Windows Server 2022 Standard Core.


## Install and Configure OpenSSH:

```
Add-WindowsCapability -Online -Name "OpenSSH.Server"
```

Now start the sshd service:

```
Start-Service sshd
```

Then let's make sure the service starts on boot:

```
Set-Service -Name sshd -StartupType 'Automatic'
```

Make sure it's allowed through the firewall (it should have been automatically added when installed):

```
Get-NetfirewallRule -Name *ssh*
```

If the rule doesn't exist, create it with the following:

```
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

Now you'll be able to SSH into your Windows machine. 

### Set Powershell as the default shell via SSH:

Run the following Powershell snippet to set Powershell as the default shell when you login via SSH:

```
New-ItemProperty -Path "HKLM:\SOFTWARE\OpenSSH" -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force
```

## User management:

Let's create an admin user. I like the `SConfig` command for this:

```
SConfig
```

At the time of writing you can use option 3 `Add local administrator` to create a new admin user and password.

## Elevating privileges:

I liked the following explanation on elevating privileges in Powershell:

[windows core run command with elevated privileges](https://stackoverflow.com/a/56199970)

TL;DR you can run the following commands to create an alias called `Enter-AdminPSSession`:

```
function Enter-AdminPSSession {
  Start-Process -Verb RunAs (Get-Process -Id $PID).Path
}

Set-Alias psa Enter-AdminPSSession
```

Then run it:

`Enter-AdminPSSession`

If you want this to be permanent, add the above snippet to `$Home\[My ]Documents\WindowsPowerShell\Profile.ps1`.

## Package Management:

### Chocolatey:

I really like [Chocolatey](https://chocolatey.org) for managing packages.

Install Chocolatey with the following command:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Then make sure Chocolatey's default location is added to your `$PATH` so you can run it:

```
$env:PATH = "C:\ProgramData\chocolatey\bin;$env:PATH"
```

Place that in `$Home\[My ]Documents\WindowsPowerShell\Profile.ps1` if you want it to be permanent.

The syntax for finding, installing or uninstalling packages is pretty simple (using `vim` as my example):

```
choco search vim
```

```
choco install -y vim 
```

```
choco uninstall -y vim 
```

### Built in package management:

Here are some relevant cmdlets I know of for installing packages via Powershell:

`Find-Package`, `Install-Package`, `Uninstall-Package`

`Get-WindowsCapability`, `Add-WindowsCapability`, `Remove-WindowsCapability`

`Find-Module`, `Install-Module`, `Uninstall-Module`

I won't go into each of them, but check out Microsoft's documentation on each cmdlet for more information.

## Wireguard:

I use the following post for instructions to install Wireguard: [Wireguard Windows Setup](https://r-pufky.github.io/docs/services/wireguard/windows-setup.html)

I added `C:\Program Files\Wireguard\` to my `$PATH`:

```
$env:PATH = "C:\Program Files\WireGuard\;C:\ProgramData\chocolatey\bin;$env:PATH"
```

If you want this to be permanent, add the above snippet to `$Home\[My ]Documents\WindowsPowerShell\Profile.ps1`.

To bring my interface up I use the following command after placing my config in `C:\Wireguard\wireguard.conf`:

```
wireguard.exe /installtunnelservice C:\Wireguard\wireguard.conf
```
