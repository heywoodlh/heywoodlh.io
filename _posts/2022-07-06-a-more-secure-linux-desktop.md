---
title: "A More Secure Linux Desktop"
layout: post
published: true
permalink: a-more-secure-linux-desktop
tags: [ linux, security, desktop, gnome, firejail, containers ]
---

This is going to be a guide on some tooling and workflows I use to secure my Linux desktop. As with all security tooling, nothing except for being completely disconnected from the internet can keep you perfectly secure -- this guide will serve to add some layers of protection. A lot of this tooling could be made more elegant but rather than focus on making something without flaws, I'm publishing this guide to serve as a starting point.

## Why?

_Note: this section is all my opinion, feel free to skip this if you just want the details on the workflows/tooling_

Linux has a (justified) reputation for being very secure. I think on the server-side this is absolutely true. On the desktop, I feel that there are some big gaps in functionality in regard to tooling compared to some of the security tooling available for Windows or MacOS. My experience is that people consider Linux on the desktop "more secure" but it's really not very secure by default -- it's just a much less lucrative target for bad actors because of how little market share it has. 

My thought process is this: if you were phished and a bad actor got a shell on your machine what could they access? With my security experience as a security engineer and Linux enthusiast, I don't think I would have any problem eventually getting `root` on a Linux workstation because there are so few desktop protections enabled by default.

Again, I specifically mean there is a lack of tooling to protect desktop users. For example, on MacOS [Little Snitch](https://www.obdev.at/products/littlesnitch/index.html) and [Lulu](https://objective-see.org/products/lulu.html) exist to help a user monitor network connections if a non-whitelisted application tries to connect to the internet. Patrick Wardle has developed a gigantic list of tools that help users increase visibility on their machine: [Objective See's MacOS Tools]. 

There are a number of tools and workflows that I have found that help close the gaps I have mentioned.

## What Gaps?

I will be focusing on what I consider are _simple to implement_ tweaks. I will not be focusing on tools like SELinux that make your system so secure to the point it's difficult to use.

These are the security gaps that I'll focus on:
- Basic security suggestions 
- Application autostart monitoring
- Application sandboxing
- Network application firewalling/monitoring
- Container security
- Miscellaneous tweaks

## Assumptions:

As there is a wide variety of Linux distributions, I will try to avoid distribution-specific instructions (i.e. how to install a package on one distribution) -- however, I will admit I have zero interest in Red Hat based distros (RHEL, CentOS, Fedora, Rocky, AlmaLinux, etc.) so most of my suggestions have been tested by me on Arch Linux and Debian-based distributions. Apologies to any Fedora users who find my instructions to be not as compatible with their environment. 

I will assume you're using a systemd-based distribution. 

I am going to assume the desktop environment in use will be GNOME.

I will also assume that the reader will implement my opinionated suggestions so I won't try to cover all alternatives that are available to a tool/workflow that I recommend.

## Basic Security:

I'm mostly going to focus on things I do that are specific to desktop systems. I would recommend using this more comprehensive guide for best hardening practices for Linux systems generally:

[madaidan's Linux Hardening Guide](https://madaidans-insecurities.github.io/guides/linux-hardening.html) -- an _excellent and detailed document_.

### Disk Encryption:

This is more of a physical security suggestion so I'll keep this brief: implementing disk encryption is a great way to secure your data on your hard drive (i.e. if somebody steals your laptop). You should encrypt your drives using full-disk encryption.

If you can't use full-disk encryption (or have setup an unencrypted system that you don't want to reinstall) and are on a system with a more aggressive release cycle (Arch Linux or Fedora), check out my entry in the 'Misc' section on systemd-homed for a decent alternative.

### Use UFW:

UFW is a simple wrapper script around `iptables`. IPTables is a powerful, but complex Linux firewall and UFW makes it much simpler.

Install UFW on your distribution.

After UFW is installed, enable the service and activate it to block all incoming connections to your machine:

```
systemctl enable ufw.service
ufw enable
```

By default this will block all incoming connections and allow outbound connections. You can configure UFW to block outbound connections, but as that can be terribly inconvenient I will not cover doing that.

_Note: Docker circumvents IPTables/UFW -- I would recommend either setting up rootless Docker, Docker Desktop for Linux, Podman, or follow my instructions for using Lima for running Docker in a VM_ 

### ClamAV:

Disclaimer: I can't stand most proprietary Antivirus products. But I think it's very useful to know if a known malicious file is on your machine. ClamAV gets you access to a great malware database without all the other buzz-word features and spyware that comes with a lot of antivirus.

Install ClamAV and ClamTK (a graphical interface to ClamAV).

Run the following command to update the local ClamAV database on your machine:

```
sudo freshclam
```

Open ClamTK > Settings > Check the following boxes:

- Scan files beginning with a dot

- Scan directories recursively

- Optionally: Scan files larger than 20MB

Back in settings select Scheduler and choose a time to scan your home directory daily. 

If you want to be able to scan files from your file manager, I would recommend checking out the plugins:

[https://github.com/dave-theunsub/clamtk#plugins](https://github.com/dave-theunsub/clamtk#plugins)

Further reading on ClamTK's usage: 

[https://github.com/dave-theunsub/clamtk#usage](https://github.com/dave-theunsub/clamtk#usage)

## Application Autostart Monitoring:

### Prerequisites:

I've chosen to use `inotify` to monitor each these so please install the `inotify-tools` package. Please also install `notify-send` so desktop notifications can be sent to alert the user.

### Why?

If I were a bad actor on your machine with an unprivileged shell there are a couple of places I would place a malicious application to run on startup (for persistence): the user's cron jobs, and the `~/.config/autostart` directory and the user's `~/.config/systemd/user` directory.

### User cron monitoring:

For those unfamiliar with cron jobs: cron is a tool for running jobs on a schedule. You can easily modify a cron to run a job as a particular user on a regular basis. As a bad actor (with an unprivileged shell), I could easily setup a cron to repeatedly attempt to do a malicious task such as establish a reverse shell to a server somewhere. 

Create a script in `~/opt/scripts/cron-monitor.sh` with the following contents:

```
#!/usr/bin/env bash

notify-send "Started cron monitoring script"

mkdir -p ~/.tmp/

crontab -l > ~/.tmp/orig-cron.txt

while true
do
    crontab -l > ~/.tmp/new-cron.txt

    if cmp ~/.tmp/orig-cron.txt ~/.tmp/new-cron.txt
    then
	echo 'Crontab unmodified'
    else
	crontab -l > ~/.tmp/orig-cron.txt
	notify-send 'User crontab modified: check crontab with `crontab -l`'
    fi

    sleep 5
done
```

Make it executable:

```
chmod +x ~/opt/scripts/cron-monitor.sh
```

Now create a file at `~/.local/share/applications/cron-monitor.desktop` to execute our monitoring script with the following content:

```
[Desktop Entry]
Name=Crontab Monitoring Script
Exec=bash -c "${HOME}/opt/scripts/cron-monitor.sh"
Icon=org.gnome.Terminal
Type=Application
Categories=Security;
```

Now, symlink that application to the `~/.config/autostart` directory so the application runs when you login:

```
ln -s ~/.local/share/applications/cron-monitor.desktop ~/.config/autostart
```

If you open the "Cron Monitoring Script" application it should notify you that the monitoring script has started. You can test that you get notifications with the following command:

```
crontab -l | { cat; echo "* * * * * echo hello world";  } | crontab -
```

Make sure to remove the test cron job with `crontab -e`.

### $HOME/.config/autostart monitoring:

On most Linux desktop, desktop applications are defined in a `.desktop` file with a bunch of parameters defining the application. Any valid `.desktop` files placed in the `~/.config/autostart` directory will be executed when a user logs in to their desired desktop environment such as GNOME. This could be used to create a false, malicious application that can will start when a user logs in.

Create a script in `~/opt/scripts/autostart-monitor.sh` with the following contents:

```
#!/usr/bin/env bash

notify-send "Started autostart monitoring script"

inotifywait --format='%f' -m -e create $HOME/.config/autostart | while read filename
do
    notify-send "Desktop autostart file added: ${filename}"
done
```

Make it executable:

```
chmod +x ~/opt/scripts/autostart-monitor.sh
```

Now create a file at `~/.local/share/applications/autostart-monitor.desktop` to execute our monitoring script with the following content:

```
[Desktop Entry]
Name=Autostart Monitoring Script
Exec=bash -c "${HOME}/opt/scripts/autostart-monitor.sh"
Icon=org.gnome.Terminal
Type=Application
Categories=Security;
```

Now, symlink that application to the `~/.config/autostart` directory so the application runs when you login:

```
ln -s ~/.local/share/applications/autostart-monitor.desktop ~/.config/autostart
```

If you open the "Autostart Monitoring Script" application it should notify you that the monitoring script has started. You can test that you get notifications with the following command:

```
touch ~/.config/autostart/dummy-application.desktop && rm ~/.config/autostart/dummy-application.desktop
```

### $HOME/.config/systemd/user monitoring:

I would say that Systemd is the backbone of most modern Linux systems as it manages all the services. As an unprivileged user you can create user services so that repeated tasks are executed as you which could easily be used for running repeated, malicous tasks for a bad actor to establish persistence.

Create a script in `~/opt/scripts/systemd-monitor.sh` with the following contents:

```
#!/usr/bin/env bash

notify-send "Started systemd monitoring script"

inotifywait --format='%f' -m -e create $HOME/.config/systemd/user | while read filename
do
    notify-send "User systemd file added: ${filename}"
done
```

Make it executable:

```
chmod +x ~/opt/scripts/systemd-monitor.sh
```

Now create a file at `~/.local/share/applications/systemd-monitor.desktop` to execute our monitoring script with the following content:

```
[Desktop Entry]
Name=Systemd User Monitoring Script
Exec=bash -c "${HOME}/opt/scripts/systemd-monitor.sh"
Icon=org.gnome.Terminal
Type=Application
Categories=Security;
```

Now, symlink that application to the `~/.config/autostart` directory so the application runs when you login:

```
ln -s ~/.local/share/applications/systemd-monitor.desktop ~/.config/autostart
```

If you open the "Systemd User Monitoring Script" application it should notify you that the monitoring script has started. You can test that you get notifications with the following command:

```
touch ~/.config/systemd/user/dummy.service && rm ~/.config/systemd/user/dummy.service
```

## Application Sandboxing:

Unlike MacOS, most Linux distributions don't have application sandboxing at all or very minimal application sandboxing. So if a malicious actor gets a shell by exploiting an application like Firefox they would be able to see anything your user could access. With sandboxing, getting a shell via an application exploit would severely limit what the malicious actor could access.

There are a couple of not-so-invasive methods for implementing restrictions around what an application can access:

1. AppArmor (an alternative to SELinux that is very non-intrusive in my experience)
2. Snaps/Flatpaks
3. Firejail
4. Bubblewrap
5. Containers

I'm going to focus on AppArmor and Firejail. I actively dislike Canonical's approach to Snaps and [Flatpak's sandbox implementation isn't very good](https://flatkill.org/). 

### AppArmor

AppArmor provides similar functionality to SELinux while not making your system impossible to work with. AppArmor allows you to define clear boundaries for what a process can and cannot access on your system. It can be configured to be more restricted if desired. Additionally, [AppArmor can integrate with Firejail](https://wiki.archlinux.org/title/Firejail#Enable_AppArmor_support).

AppArmor is installed and enabled by default on Ubuntu systems: [Ubuntu Docs: AppArmor](https://ubuntu.com/server/docs/security-apparmor)

Once AppArmor is installed you can check its status with the following command:

```
sudo aa-status
```

On Debian-based systems, additional AppArmor profiles can be installed with the following commands:

```
sudo apt-get update && sudo apt-get install -y apparmor-profiles apparmor-profiles-extra 
```

On Arch, those profiles can be loaded by enabling and starting the `apparmor` service:

```
sudo systemctl enable --now apparmor.service
```

You can get notifications when the AppArmor policies denies an application:

[Arch Wiki: AppArmor -- Get desktop notifications on DENIED actions](https://wiki.archlinux.org/title/AppArmor#Get_desktop_notification_on_DENIED_actions)

Additional Reading:

[Arch Wiki: AppArmor](https://wiki.archlinux.org/title/AppArmor)

### Firejail:

After installing Firejail on your machine, use the following command to set up profiles for all of your installed applications that are already defined:

```
sudo firecfg
```

I would recommend integrating AppArmor with Firejail:

[Arch Wiki: Enable AppArmor support](https://wiki.archlinux.org/title/Firejail#Enable_AppArmor_support)

[Ubuntu Manpage: Firejail AppArmor](https://manpages.ubuntu.com/manpages/bionic/man1/firejail.1.html#apparmor)

On Arch you can integrate `pacman` operations with Firejail:

[Arch Wiki: Using Firejail by default](https://wiki.archlinux.org/title/Firejail#Using_Firejail_by_default)

## Application Firewall:

On Linux, there aren't many fully-featured/working application firewalls comparable to Little Snitch on MacOS. For those unfamiliar with what an application firewall does: an application firewall allows a user to permit or block access to network resources per application. For example, if I run `curl google.com` an application firewall would block `curl` from accessing `google.com` until I either permit or block the request. This is beneficial if an application is making undesirable network requests (i.e. a malicious binary attempts to connect to a server, or a program is collecting unwanted analytics, etc.).

There are two application firewalls on Linux that I am aware of:

- [OpenSnitch](https://github.com/evilsocket/opensnitch)
- [Portmaster](https://safing.io/portmaster/)

I've never had success with OpenSnitch, but Portmaster has worked very well for me and seems to be very polished with GNOME.

[Portmaster Docs: Install on Linux](https://docs.safing.io/portmaster/install/linux)

Once Portmaster is running, open the Portmaster application and go to Settings > Privacy Filter > General > Default Network Action and set it to "Prompt". This will set Portmaster to prompt you to Allow or Deny every network request to a new host per process. For example, if I run `curl google.com` and I deny that request in Portmaster any future network request to `google.com` by `curl` will be denied. 

## Container Security:

If you are a Docker user, using the default, privileged Docker daemon is a poor practice on a workstation as it completely bypasses the local firewall. Even worse, if your user has access to that privileged Docker daemon (i.e. added to the `docker` group) it is fairly trivial to access restricted resources if that user is compromised.

Some alternatives to the privileged Docker Daemon:
- [Lima](https://github.com/lima-vm/lima)
- [Rancher Desktop](https://rancherdesktop.io/)
- [Docker Desktop for Linux](https://docs.docker.com/desktop/linux/install/)
- [Rootless Docker](https://docs.docker.com/engine/security/rootless/)
- [Podman](https://podman.io/)

For rootless Docker and Podman, the following warning from the Arch Wiki applies: "Rootless Podman relies on the unprivileged user namespace usage `CONFIG_USER_NS_UNPRIVILEGED` which has some serious security". However, this `CONFIG_USER_NS_UNPRIVILEGED` parameter is required for sandboxing in things like Electron applications (for example, the Zoom application on Linux won't work if this parameter isn't set). Another note from the Arch Wiki explains more: "Note: The user namespace configuration item `CONFIG_USER_NS` is currently enabled in linux (4.14.5 or later), linux-lts (4.14.15 or later), linux-zen (4.14.4-2 or later) and linux-hardened. Lack of it may prevent certain sandboxing features from being made available to applications."

Lima, Rancher Desktop and Docker Desktop all utilize virtual machines to run Docker rather than attaching to the host's kernel and resources like the privileged Docker daemon does. My preference is Lima as it leverages QEMU and in my experience is the most minimal and simple (for me) of all those options. I prefer using a VM to provide a bit of isolation from my system.

## Misc:

### Systemd-homed:

If you use Arch Linux or Fedora, you can use [systemd-homed](https://systemd.io/HOME_DIRECTORY/) to create an ultra-portable home directory for your user.

The security benefits of systemd-homed are the following:
- Totally portable home directory
- LUKS encrypted home directory
- Automatic locking of your home directory when your system is suspended
- Better handling of credentials compared to the decades old Shadow system (admittedly, I don't understand the details as to why or how it's better but that is a feature touted by the systemd contributors)

If you have already setup your user without systemd-homed, don't fret as the systemd folks have a nice guide on migrating an existing user to systemd-homed:

[systemd.io: Converting Existing Users to systemd-homed managed Users](http://systemd.io/CONVERTING_TO_HOMED/)

If you want to use LUKS encryption as the storage mechanism for your home directory create your user with the `--storage=luks` flag set:

```
homectl create --storage=luks <username>
```

Additional reading: [Arch Wiki: systemd-homed](https://wiki.archlinux.org/title/Systemd-homed)
