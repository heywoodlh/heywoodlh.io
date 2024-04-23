---
title: 'My Cloud Gaming Setup for iOS on Paperspace'
layout: post
published: true
permalink: paperspace-cloud-gaming-ios
tags: [ cloud, paperspace, gaming, apple, ios, ipados, ipad, iphone, apple, shortcuts, fallout, bethesda ]
---

This post will outline my setup for cloud gaming on Paperspace for my i[Pad]OS devices.

## What Got Me Here:

Xfinity is my ISP and their upload speeds suck. I pay for 1 Gb/second download and the highest upload rate I can get is 36 Mb/second. This isn't an issue when I'm streaming to my devices at home over wifi as there is rarely any detectable latency. When I'm away from home, I don't have nearly as much success as typically my upload speed really limits my possibilities with streaming remotely _on top of the fact that the remote networks I am at usually aren't optimized_ for speed. So I wanted a gaming rig that got rid of the bottleneck that is my upload speed with Xfinity.

There aren't that many cloud gaming services for iOS compared to what's available for Android. I don't blame those companies for not wanting to deal with the App Store/Apple. 

Finally, I've been camping way too much on Fallout 76 and there are very few cloud gaming providers that even allow you to stream Fallout 76 _and support iOS_.

A bonus reason: it's pretty awesome to have a fully remote cloud gaming machine.

## Downsides:

Let's get the downsides out of the way before I dig into the setup.

### Latency:
Game streaming to a mobile device is way better locally compared to a remote VPS that may be hundreds/thousands of miles away. The latency is noticeable for me as I'm in Utah and the nearest Paperspace datacenter is in California. However, for a casual gamer like me on a game that isn't extremely competitive like Fallout 76 it really isn't a huge issue for me.

### Expense:
I'll share some ways I work with it but having a cloud gaming machine is expensive. Even if my machine with Paperspace is turned off for the entire month, I'll still be paying around $15/month just for storage.

### You should probably just buy a low-end gaming machine:
To be honest, I think that the best gaming experience with streaming will be with a gaming machine that is on your home network. But I'm doing this for science.

## Set Up Your VM:

I went with [Paperspace](https://paperspace.com) as my VPS host for my cloud gaming machine. They specifically provide VPS-es with awesome graphics cards. I find their billing to be really straightforward, especially compared to how confusing AWS' billing is. They also have hourly billing in which a powered off VM doesn't cost outside of the cost for the storage you have set aside for it.

[Please use my referral code for Paperspace if you feel inclined to](https://console.paperspace.com/signup?R=LP56CQW).

I followed this guide for deploying the VM using the Paperspace Parsec template:

[Setting up your cloud gaming rig with Paperspace + Parsec](https://blog.paperspace.com/setting-up-your-cloud-gaming-rig-with-paperspace-parsec/)

I set my instance to go with hourly billing and to turn off after one hour. The GPU+ plan was enough for my needs with Fallout 76.

It's really straightforward so I'm not gonna get much deeper into deploying the VM in Paperspace.

### Install Chocolatey:

First thing I do on Windows is I install [Chocolatey](https://chocolatey.org) with this command on the Windows machine in an Administrator session in Powershell:

```
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
```

That'll be helpful if you want to run the commands I use to install the apps. Otherwise, download the apps from the internet like a barbarian.

### Install Nvidia GeForce Experience for GPU Drivers:

Once the VM was setup I noticed that the display looked a bit weird in the console and found that the Nvidia drivers for the graphics card were out of date.


Once Chocolatey was installed, I installed GeForce Experience in an Administrator Powershell session:

```
choco install -y geforce-experience
```

After GeForce Experience is installed, open it, login with your Nvidia account, then go to Settings > Driver > Check for Updates > Express Installation. Once the installation finishes you should be good to go on your driver.

### Remote Access:

I installed RealVNC Server on my machine and set up my free RealVNC account on it so that way I can access the VM without it needing a public IP address (RealVNC can proxy your connection assuming the remote machine has an internet connection).

### Install Steam:

Use the following command to install Steam on my Windows host with Chocolatey:

```
choco install -y steam
```

Once logged into Steam, turn on Remote Play and link Steam Link on your mobile device.


## Apple Shortcuts for Paperspace VM:

Since I set my gaming VM to hourly, it will shut off pretty quick. I wanted a way to turn the VM on and off really quickly from my mobile devices so that I don't have all the added steps of logging into the web console and managing the VM there.

Paperspace has an API that makes it really simple to accomplish this using external tools. Since my Paperspace VM is going to be exclusively accessed from my iOS devices I used Apple Shortcuts to give me a nice little applet to run on my iPhone or iPad to power my VM off or on by running a single shortcut.

Look to Paperspace's documentation on how to obtain an API token:

[Obtaining an API Key](https://docs.paperspace.com/paperspace-core-api/get-started/obtaining-an-api-key)

### Setting up the shortcut:

So, the way my shortcut works, it expects that a json file will store your API key and VM ID. Shortcuts only allow for file access in iCloud Drive, so turn on iCloud Drive on your mobile device. I went this route because it's the most secure way to store secrets for Shortcuts to use that I could find as somebody would need to compromise your Apple account to access the file. But it'd be nice if Shortcuts supported local, encrypted secrets on your device.

Anyway, place the file in `iCloud Drive/Shortcuts/paperspace.json` with the following content:

```
{
  "paperspace_api": "xxxxxxxxxx",
  "paperspace_gaming_vm_id": "xxxxxxx"
}
```

If it's not obvious, `paperspace_api` should equal the value of your token and `paperspace_gaming_vm_id` should equal the value of your Paperspace VM's ID.

Once that is setup, you are ready to import the shortcut:

[Paperspace Manage VM Power](https://www.icloud.com/shortcuts/7f6601b153b34bdfab4aa65d7d6f5fcf)

Once you import the shortcut, I would suggest adding it to your homescreen so you can easily launch it using an applet on your iOS device.

### Making sure the VM stays off:

I set up an automation in Shortcuts to ensure that every morning at 3:00 a.m. my VM will be powered off using the following shortcut:

[Paperspace Power Off VM](https://www.icloud.com/shortcuts/c0fb3eaa178e47d7802008fdc03766d5)

This makes sure that my VM doesn't accidentally stay on and I get a massive bill by the end of the month.
