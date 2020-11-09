---
title: 'My "Linux-like" MacOS Setup'
layout: post
permalink: linux-macos-setup
tags: all, linux, macos, security, x86
---

This article is my attempt to document my attempt to take the things I like best about desktop Linux and apply them on MacOS through open source tools. 

Without the open source software I have discovered and will share in this article MacOS would not be tolerable for me. 

## MacOS _is_ Unix:

This doesn't really change much on the technical side, but it's super interesting to me. For those who are really into Linux they are probably familiar with Linux's close-ness to Unix. Unix is a family of proprietary operating systems that are derived from AT&T Unix first published in the early 1970's at Bell Laboratories. Unix's design was meant to be as convenient as possible for programmers.

Before a few years ago, I mistakenly believed that Linux was actually a Unix derivative. It is not. In my defense, people refer to it informally as "Unix" so that's where my confusion lied. Formally, Linux is considered "[Unix-like](https://en.wikipedia.org/wiki/Unix-like)". Unix-like operating systems were created to mimic all of the strengths of the proprietary Unix operating systems while allowing for even more open-ness and versatility as they are typically open source. 

While I dislike Apple's deliberate attempts to make MacOS as closed as possible, I love the strengths of Unix. [MacOS is UNIX certified](https://www.opengroup.org/openbrand/register/brand3653.htm). Many of my favorite command-line Linux tools have a MacOS port since both Linux and MacOS share a similar Unix heritage. CLI applications, in my experience, are typically easy to port between OS-es.

## Using Linux as my portable runtime everywhere (I prefer Docker for this):

With Linux as my preferred runtime, it's very easy to make my workflows cross-platform and still based on Linux due to tools like Docker.

### Server-side:

I use Unix-like OS-es exclusively for my back-end, server-side stuff to augment the applications I have available to me so there isn't much to get into that's relevant to my MacOS setup.

On a side note: I think MacOS is _the worst_ for servers. I prefer NixOS, Arch Linux and/or FreeBSD for my server-side needs.

### Client-side:

I use Docker for all of my client-side Linux workflows. Docker is cross-platform and allows me to run a virtual Linux kernel on Windows, Mac or Linux.

One of the downsides of Docker on Mac compared to Docker on Linux or Windows is that the MacOS kernel lacks the virtualization needed to more natively run a Linux kernel for containers. To make up for this Docker on Mac runs a Linux virtual machine. I actually view this is a good thing, though, because it separates Docker from a lot of the privileged resources in MacOS. Unless you run [rootless Docker](https://docs.docker.com/engine/security/rootless/) or a rootless alternative like [Podman](https://podman.io/) (both of which I think are better than running Docker on Linux and adding yourself to the `docker` group), it's pretty trivial to pwn a system if you have access to the Docker daemon on Linux.

In theory, Docker running within a kernel in a VM on MacOS will add some latency and performance restrictions compared to Docker running on a Linux host and sharing the same kernel as the host. I haven't seen any noticable performance hits on Mac vs Linux for what I do, however, but it's still good to be aware of. You can tweak the resource allocation for the VM in Docker's preferences.

### Keeping things in the command line:

Using command line applications for as much as possible has allowed a lot of my core workflows to remain consistent. Plus, terminal emulators and your preferred shell make things look consistent across Windows, MacOS and Linux. This allows me to use Docker for the Linux-specific workflows that don't translate well to native MacOS tools. 

## Nix-darwin and Homebrew:

### Nix-darwin:
I recently discovered the Linux distribution NixOS and absolutely fell in love with it immediately due to the configuration management with `configuration.nix`. One of the additional discoveries I made that were essential to making MacOS more hospitable for me was discovering [Nix-darwin](https://github.com/LnL7/nix-darwin). One of my biggest complaints with MacOS was how difficult it was to streamline or automate things. In contrast, on Linux I could have an almost identical build setup quickly due to Linux's nature of being so programmable and relying heavily on files for configuration -- allowing you to copy configuration files across builds.

Nix-darwin bridged the gap for me in making MacOS more programmable. I can use Nix-darwin to have nearly all the same benefits of dotfiles in a way that I consider to be cleaner than my previous setup. In essence, Nix-darwin allows me to program the majority of things I care about using `configuration.nix` like on NixOS. If you install Nix-darwin, you can see what you can configure with `man configuration.nix`

[You can see my Nix-darwin setup here (with a minimal Readme).](https://github.com/heywoodlh/nixos-builds/tree/master/darwin)

If you don't want to use Nix-darwin, you can still use the [Nix package manager](https://nixos.org/download.html#nix-quick-install) to install command line applications on MacOS. Unfortunately, you can't install graphical applications with `nix` but thankfully Homebrew can.

### Homebrew:

[Homebrew](https://brew.sh/) (or [MacPorts](https://www.macports.org/) if you'd rather not use Homebrew) is the open source package manager that MacOS is missing. I stay away from the app store as much as possible but prefer to not go to the internet for applications I need to download. Homebrew allows me to use an open source repository to download and install applications.

[I use Nix-darwin to manage my Homebrew packages](https://github.com/heywoodlh/nixos-builds/blob/master/darwin/homebrew.nix). The `nix` package manager can't install graphical applications on MacOS so using that Homebrew.nix module allows me to manage applications with Homebrew using Nix-darwin, specifically for graphical applications. I install my core command line applications with `nix`.

[You can see where I define the packages I want installed as casks in my config.](https://github.com/heywoodlh/nixos-builds/blob/master/darwin/config.nix) The Homebrew module is imported in my `darwin-configuration.nix` file, in case it isn't obvious. 

## Tiling window manager and keyboard shortcut daemon -- Yabai and Skhd:

My first and most extensive introduction to Linux was installing Arch Linux. During that time, I discovered [i3](https://i3wm.org/) and absolutely loved the way that it organized my opened applications. Without a tiling window manager, I can't stand the default non-snapping behavior of graphical applications on MacOS.

### Yabai:

My first tiling window manager on MacOS was [ChunkWM](https://github.com/saforem2/chunkwm). It was deprecated and replaced with [Yabai](https://github.com/koekeishiya/yabai/) and shortly afterward I switched to Yabai (it looks like ChunkWM has been picked back up and is now supported again).

Yabai provides all the things I love about i3 without a cost, in an extensible fashion and in a way that allows me to keep things keyboard-driven. The Mac App Store has a closed-source alternative called [Magnet](https://magnet.crowdcafe.com/) that provides a lot of the same functionality -- without being free and less extensible. I would highly recommend Magnet for anyone who doesn't like tweaking configs and just wants something to work out of the box.

### Skhd:

The lack of a flexible keyboard shortcut daemon on MacOS was super irritating to me when first using MacOS when switching away from Linux. I like being able to use keyboard shortcuts to run custom scripts whenever I need to. The clunky alternative MacOS provides is to use Automator to build a workflow to run the script and this was just painful to me.

Thankfully, the creator of Yabai also created a hotkey daemon called [skhd](https://github.com/koekeishiya/skhd) that can manage Yabai but also run anything else I need using custom keyboard shortcuts.



[You can see my config for Yabai and Skhd in my Nix-darwin config files](https://github.com/heywoodlh/nixos-builds/blob/master/darwin/wm.nix).

## Vimac and Vim Vixen -- keeping things keyboard-driven:

[Vimac](https://github.com/dexterleng/vimac) is one of those tools on MacOS that I haven't been able to find a comparable alternative for on Linux. Vimac provides keyboard hints for every significant place in the graphical environment that you would want to click on. So it allows me to (usually) click anywhere in my graphical environment and graphical applications quickly using just my keyboard. Since MacOS has a consistent graphical API across the board most applications work well with Vimac's hint mode -- some don't but that has been rare for me.

Unfortunately, I don't know if something like this could exist to this same level on Linux since graphical environments on Linux are implemented without consistency across desktop environments. Maybe someone could write something like Vimac for GNOME, KDE or specific desktop environments/graphical APIs?

[Vim Vixen](https://addons.mozilla.org/en-US/firefox/addon/vim-vixen/) provides basically the same functionality but just for Firefox (it's a Firefox extension). For Chrome/Chromium users [Vimium provides the same functionality](https://chrome.google.com/webstore/detail/vimium/dbepggeogbaibhgnhhndojpepiihcmeb) -- which is what inspired Vimac.

## Choose -- Rofi alternative:

I use [Choose-gui](https://github.com/chipsenkbeil/choose) as my MacOS alternative for [Rofi](https://github.com/davatorium/rofi). Choose-gui allows me to quickly integrate shell scripts into a graphical selection tool and thus extend my shell scripts into the GUI (and keep things keyboard-driven). Choose-gui doesn't have the same level of maturity and features as Rofi but it has been a lot better than nothing for me.

## Secretive -- SSH Key Manager:

[Secretive](https://github.com/maxgoedjen/secretive) is an SSH key manager that uses the secure enclave to store SSH keys. Secretive using the secure enclave allows me to use my Apple Watch or Touch ID to use a private SSH key to login to my SSH servers.


## Objective See's Open Source Security Tools:

Patrick Wardle writes some of the best desktop security tools for MacOS.

All of the tools he has written are open source and totally free.

[The tools are available here](https://objective-see.com/products.html).

Some of my favorites are:

- [Do Not Disturb](https://objective-see.com/products/dnd.html) -- notification agent to help detect tampering
- [Lulu](https://objective-see.com/products/lulu.html) -- application firewall
- [Oversight](https://objective-see.com/products/oversight.html) -- camera-usage detection tool
- [Reikey](https://objective-see.com/products/reikey.html) -- keylogger detection tool

## Cross-platform open source apps that are significant to my daily workflows (not comprehensive):

- [Aerc](https://aerc-mail.org/) -- command line email client
- [Bitwarden](https://bitwarden.com/) -- password manager
- [Bitlbee](https://www.bitlbee.org/main.php/news.r.html) -- instant messenger bridge for IRC clients (I use it to access Discord in Weechat)
- [Dnscrypt-proxy](https://github.com/DNSCrypt/dnscrypt-proxy) -- encrypted DNS proxy
- [Firefox](https://www.mozilla.org/en-US/firefox/new/) -- browser 
- [Ferdi](https://getferdi.com/) -- messaging browser
- [Git](https://git-scm.com/) -- version control tool
- [GPG](https://gnupg.org/) -- encryption toolset
- [Hydroxide](https://github.com/emersion/hydroxide) -- open source Protonmail bridge
- [Kitty](https://sw.kovidgoyal.net/kitty/) -- terminal emulator
- [Pass](https://www.passwordstore.org/) -- command line password manager (I use it for storing API keys I want to retrieve from the command line)
- [Signal](https://www.signal.org/) -- encrypted messenger, I try to use iMessage as little as possible (although for my friends and family who don't want to switch to Signal I will admit it's nice to be able to use iMessage on my Mac)
- [Syncthing](https://syncthing.net/) -- end-to-end encrypted file synching protocol and application
- [Ungoogled Chromium](https://github.com/Eloston/ungoogled-chromium) -- Chromium without all the Google crap
- [Vim](https://www.vim.org/) -- I use `vim` for everything text-oriented such as programming, notes, to-do lists, writing (including writing this post) so I think it's worth mentioning at the risk the look of being a vim-douchebag 
- [Weechat](https://weechat.org/) -- command-line chat client
- [Wireguard](https://www.wireguard.com/) -- open source VPN protocol and client (I Wireguard _everything_)

## Closed source apps that are significant to my daily workflows:

- [Duo Security](https://duo.com/) -- multifactor authentication -- it's super nice to accept multifactor authentication using my Apple Watch
- [Plex](https://www.plex.tv/) -- media server/client
- [Prowl](https://www.prowlapp.com/) -- simple iOS push notification tool
