---
title: "Mouseless Workflows on MacOS"
layout: post
published: true
permalink: mouseless-workflows-on-macos
tags: [ macos, mouseless, keyboard, trackpad, skhd, cliclick ]
---

I've recently-ish been obsessed with getting my keyboard driven workflows honed in after getting an ErgoDox EZ ergonomic keyboard and have pretty much abandoned my mouse. While on my ergonomic keyboard I don't have to use a mouse at all because it has a mouse emulation mode built into the firmware.

However, I don't like the idea of only being able to be mouseless when I'm on my ergonomic keyboard so I built some workflows on my Mac to keep things keyboard driven. I want to keep things keyboard driven on any keyboard without a mouse being necessary.

## Getting Feature-Parity with My Linux Workflows:

I also created mouseless workflows on my Linux builds but there are plenty of articles on how to do this on Linux and not as many on MacOS so I will briefly sum up my workflows on Linux.

These are the components in my Linux workflows that help me keep things keyboard-driven (GNOME is my preferred desktop environment):
- Xorg (not Wayland -- I can't seem to get my keyboard-driven workflows as well developed on Wayland)
- [PopOS' GNOME shell plugin](https://github.com/pop-os/shell)
- [Vimium](https://vimium.github.io) on Chromium browsers or [Vim Vixen](https://github.com/ueokande/vim-vixen) on Firefox
- As many command-line utilities as I can use (notably: `tmux`, `vim`, and `gomuks`)
- [Rofi](https://github.com/davatorium/rofi)
- [Keynav](https://github.com/jordansissel/keynav)
- [Xdotool](https://github.com/jordansissel/xdotool)
- Custom keyboard shortcuts

Here are the mouse emulation commands I have mapped to keyboard shortcuts in GNOME's settings:

- Move mouse left: `xdotool mousemove_relative -- -15 0` 
- Move mouse right: `xdotool mousemove_relative 15 0`
- Move mouse up: `xdotool mousemove_relative -- 0 -15`
- Move mouse down: `xdotool mousemove_relative 0 15`
- Left click: `xdotool click --clearmodifiers 1`
- Right click: `xdotool click --clearmodifiers 3`
- Scroll up: `xdotool click 4` 
- Scroll down: `xdotool click 5`

## MacOS:

When Googling around for similar workflows on MacOS most of the posts I found pretty much said that they use Amethyst, Yabai or Magnets (yuck) and that they use Vimari in Chrome (or something similar) and maybe some keyboard shortcuts in VSCode or their terminal with Tmux. This is cool but doesn't really help outside of the browser, IDE or terminal. So not only will I cover some app-specific stuff that I do but also how I am able to go mouseless everywhere.

As covered in [My "Linux-like" MacOS Setup](https://heywoodlh.io/linux-macos-setup) I use [Yabai](https://github.com/koekeishiya/yabai) and [skhd](https://github.com/koekeishiya/skhd) for tiling window functionality and custom keyboard shortcuts.

I use [Nix-Darwin](https://github.com/LnL7/nix-darwin) to manage my Macs. The MacOS specific Nix configuration that I currently use is here and will have more information for those who wish to dig more into my setup: https://github.com/heywoodlh/nixpkgs/tree/master/darwin 

### Emulating the mouse:

To emulate the mouse on MacOS I use [cliclick](https://github.com/BlueM/cliclick). Once that has been installed and the proper permissions have been given I use the following keyboard shortcuts in `skhd` (I use `vim`-like keybindings):

```
ctrl - k : cliclick "m:+0,-20" #up
ctrl - j : cliclick "m:+0,+20" #down
ctrl - l : cliclick "m:+20,+0" #right
ctrl - h : cliclick "m:-20,+0" #left

ctrl + shift - k : cliclick "m:+0,-40" #up (faster)
ctrl + shift - j : cliclick "m:+0,+40" #down (faster)
ctrl + shift - l : cliclick "m:+40,+0" #right (faster)
ctrl + shift - h : cliclick "m:-40,+0" #left (faster)

ctrl - 0x21 : cliclick ku:ctrl c:. #click
ctrl - 0x1E : cliclick ku:ctrl rc:.  #right click
```

This allows me to fully control my mouse with my keyboard in any application. For scrolling I use Vimac.

### Vimac (Vimium for the MacOS desktop):
[Vimac](https://github.com/dexterleng/vimac) is an app that allows you to quickly click on fields on the MacOS desktop with a powerful hint-mode comparable to Vimium. It also provides a scroll mode so you can scroll through an app with the keyboard.

I don't really use Vimac as much because some of the apps I tried it in don't work fully with it but it totally makes keeping things keyboard-driven so nice when apps work with it. I mostly use it for the scroll-mode.

### Vimari (Vimium for Safari):
I have recently switched to Safari primarily at the time of writing this. The only reason is because of Private Relay. 

I use [Vimari](https://github.com/televator-apps/vimari) to provide some of Vimium's functionality in Safari. It doesn't work nearly as well as Vimium or Vim Vixen due to Safari/Apple limitations but it's still a step in the right direction and I am grateful the developer made it.

In my experience, Safari is poor when it comes to keeping things keyboard-driven but with the shortcuts to control my mouse it is just a minor irritation. 

### Keep things in the terminal/command line:
With the exception of Safari and Zoom, I keep everything I possibly can in the command-line. Sticking to the command line allows you to keep things as text-driven/keyboard-driven as possible.

For messaging I use Matrix and bridges to connect to my favorite messaging platforms (Signal, iMessage, etc.). This allows me to use [gomuks](https://github.com/tulir/gomuks) for messaging. For Slack, specifically, I use [wee-slack](https://github.com/wee-slack/wee-slack) a plugin for Weechat.

For development, text editing, general writing, I use `vim`. At the time of writing [here is my Vimrc](https://gist.github.com/heywoodlh/abd45a72d34eabcdd5f63afff748d5e1#file-mouseless-on-macos-vimrc) and [here are the plugins I use](https://github.com/heywoodlh/conf/blob/b75a248fb550d7920ba7ed5bc08c5cb94287d5dc/peru.yaml#L20-L39).
