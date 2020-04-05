---
layout: post.html
date: 2018-10-27
title: 'Install Arch Linux on Dell XPS 12/Dell XPS 12 Crash on Arch Linux'
collections: all, linux
---

_TL;DR: set the kernel boot parameter `i915.modeset=0` in Grub and then downgrade to a Linux kernel earlier than 4.16 (preferably an LTS)._ 


## The Dilemma:

_The i985 driver packaged with the Linux kernel beginning at Linux kernel 4.16 was causing the machine to crash._


I am an avid Arch Linux user. I also own a Dell XPS 12 which I use as a more portable alternative to my heavier, larger Macbook Pro. Arch Linux is a natural fit for this machine's operating system. 

I kept running into a specific issue: when booting into Arch Linux, my computer would die. It was frustrating and I found NO help online so that's why I'm posting the fix.

After a very long period of trial and error and perusing through every forum known to man I found the source of the issue: in all Linux kernels beginning at 4.12 Intel began to include the i985 graphics driver in the Linux kernel and starting at kernel 4.16 the driver apparently had code which is not compatible with the Dell XPS 12 (maybe earlier than 4.16 -- I'm at the 4.14 LTS at the time of writing and am not having issues).

 

## The Temporary Fix:

_Set `i915.modeset=0` as a boot parameter in Grub._

To actually get my machine not to crash, I had to set a kernel parameter in Grub (press 'e' in the Grub boot menu). The parameter is `i915.modeset=0` (this tells the kernel to not set the i915 graphics driver during startup and let the X server handle it). Once I did this I was able to boot into a super slow but functional Arch Linux system. I ran through my Arch Linux installation and rebooted. 


## The Long-Term Fix:

_Downgrade to a kernel that is older than kernel 4.16 (in this case, the LTS)._

I had to set the `i915.modeset=0` parameter in the Grub boot menu on my fresh install once again. Upon figuring out what the issue was I decided to install the `linux-lts` package through `pacman`:

`sudo pacman -S linux-lts`

This installs the LTS Linux kernel which at this time is Linux kernel 4.14.78. I then uninstalled the `linux` package via `pacman`:

`sudo pacman -R linux`

Now that the rolling Linux kernel is no longer an option, Grub will automatically use the LTS after a reboot:

`sudo reboot`




Hopefully this provides help for any Dell XPS 12 users who want to run Arch Linux on their machine. I really could have used this while looking for this issue.
