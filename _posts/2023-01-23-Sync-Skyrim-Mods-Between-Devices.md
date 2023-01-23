---
title: "Sync Skyrim Mods Between Devices (with Syncthing)"
layout: post
published: true
permalink: sync-skyrim-mods-syncthing
tags: all, linux, steam, deck, steamdeck, skyrim, special, edition, syncthing, mods, vortex, mod, manager, gaming
---

This will be a quick run-down on how I'm syncing mods with Syncthing between two of my devices that have Skyrim Special Edition installed. The two devices are my gaming PC running Windows 10 and my Steam Deck running NixOS. However, this should work with any two devices that can run Syncthing.

Additionally, I suspect that this method should work with other games, I'm just using Skyrim as an example.

The reason for this is pretty simple: I have a Steam Deck and I'd like to sync my Skyrim mods with it -- but I already have a modded build on a Windows machine. Additionally, my Steam Deck is running NixOS (Linux) and it's not currently very convenient to use Vortex (nexusmods.com's mod manager) on Linux. With this setup I can install mods on my Windows machine and they should sync to my Steam Deck.

## Prerequisites:

I'm going to assume that one of your machines already has a modded build of Skyrim, I won't cover how to actually install mods (it's trivial on Windows with nexusmods.com and Vortex, Nexus' Mod Manager).

Both machines should have Skyrim installed -- I would suggest starting from a fresh install on the machine that doesn't yet have the mods/build you want. 

## Installing Syncthing
I'm not going to provide a detailed walkthrough on how to install Syncthing, but I'll provide a basic outline:

### On Windows (using Chocolatey):
Install Chocolatey: https://chocolatey.org/install

Run the following command as Administrator (search for the Powershell app, right click Powershell, Run as Administrator):
```
choco install -y syncthing
```
Note: Chocolatey will install the `syncthing.exe` executable in `C:\ProgramData\chocolatey\bin\syncthing.exe`

Set Syncthing to start automatically: https://docs.syncthing.net/users/autostart.html#windows

### On Linux:

Use your package manager to install Syncthing.

Start the syncthing service: 

```
sudo systemctl enable --now syncthing@${USER}.service
```

Alternatively, start it using just your user:

```
systemctl enable --now --user syncthing.service
```

Check out the Arch Wiki for more information on Syncthing on Linux: https://wiki.archlinux.org/title/Syncthing

### Add Both Devices to Syncthing

With your devices running Syncthing, make sure to add them both so they can share data with each other via Syncthing.

Do the following:
1. Login to the local Syncthing instance's web interface: http://localhost:8384
2. Select Actions > Show ID
3. On the other device, also login to Syncthing's web interface and select "Add Remote Device", filling out the Device ID with the ID from step 2
4. Back on your original device, a notification should appear in Syncthing's web interface that your other device would like to be added -- accept it

## Add Skyrim's Folders to Syncthing

On your modded machine, access the Syncthing web service with this URL: http://localhost:8384

In Syncthing's web interface on the device with your already modded Skyrim build, you should add Skyrim Special Edition's folder as a shared Folder. In my case, my Skyrim Special Edition folder path is at `E:\SteamLibrary\steamapps\common\Skyrim Special Edition`.

While in Syncthing, you should also add a separate shared folder for the directory on your Windows machine that contains Skyrim's `loadorder.txt` and `plugins.txt` files. By default it is at the following path on Windows:

```
C:\Users\$USER\AppData\Local\Skyrim Special Edition
```

Once your Skyrim Special Edition folder is added to Syncthing, select it, select Edit > Sharing and check the box next to the device you want to share it with.

### Share Skyrim's Syncthing Folders With Your Target Device

There are three folder paths I would recommend sharing between your devices. I'm going to presume that the sources are all coming from a Windows machine, so I will use the default Windows paths:

- `C:\Program Files (x86)\Steam\steamapps\common\Skyrim Special Edition`: Skyrim game files
- `C:\Users\$USER\Documents\My Games\Skyrim Special Edition`: Save data and local preferences
- `C:\Users\$USER\AppData\Local\Skyrim Special Edition`: contains loadorder.txt

On the other device, I would recommend deleting your freshly installed, unmodded Skyrim Special Edition folder (don't uninstall Skyrim via Steam) and then go into Syncthing's web interface and accept the shared folder from the machine with your desired build. I would set the path to the exact location where Skyrim was installed, so that way Steam thinks it is still present on your filesystem.

Really, it doesn't matter how you do it, mostly just place the Syncthing Skyrim SE folder at a location Steam will be able to view it as present.

For the shared folder in Syncthing containing `loadorder.txt`, you should place that folder at the default Windows path `C:\Users\$USER\AppData\Local\Skyrim Special Edition` or if you are on Linux (i.e. Steam Deck) using Valve's Proton compatibility to run Skyrim, the target path should be `~/.local/share/Steam/steamapps/compatdata/489830/pfx/drive_c/users/steamuser/AppData/Local/Skyrim Special Edition`. This path might not exist if you haven't already run Skyrim the first time, so either run Skyrim or just let Syncthing create that path.

## Play!

Now with Syncthing sharing folders between devices, you will be able to have your Skyrim builds synchronize. As long as both of your devices are powered on and syncing your Skyrim builds should stay in sync.

## Some Syncthing Tips

### File versioning

In Syncthing's web interface, you should edit the folders and turn on File Versioning. This will prevent files from being deleted if you have a conflict between devices.

### Setup a Server

I would highly recommend setting up a device to behave as an always-on Syncthing server. Having a third device that you sync these folders to will ensure that if only one of your two original devices with Skyrim is turned on, the folders will still be synchronized.

Basically, just dedicate a separate device (it can be small, such as a Raspberry Pi -- or it could just be any Windows, Mac, Linux machine that is always running) to always run Syncthing and share the folders with that device.
