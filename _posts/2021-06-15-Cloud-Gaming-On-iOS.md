---
title: 'My Cloud Gaming Setup for iOS on Paperspace'
layout: post
published: false
permalink: cloud-gaming-ios
tags: all, cloud, paperspace, gaming, apple, ios, ipados, ipad, iphone, apple, shortcuts
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

### Install Steam:

Use the following command to install Steam with Chocolatey:

```
choco install -y steam
```


