---
layout: default
title: My Tech Stack
permalink: /stack/
---

<center><h2>heywoodlh tech stack</h2></center>

Core principles:
- Command-line driven
- Keyboard oriented (using Vim-style keybindings)
- [Nord themed](https://www.nordtheme.com/)
- Reduced visual clutter
- Shared configuration between MacOS and Linux

---

## Unix-like development powered by Nix flakes

Nix runs on MacOS and Linux and can configure everything!

The following projects allow me to codify various environments:
- [NixOS](https://nixos.org/) => my preferred Linux distribution
- [Nix-Darwin](https://github.com/LNL7/nix-darwin) => all the benefits of NixOS on MacOS
- [Home-Manager](https://github.com/nix-community/home-manager) => dotfiles

I store all of my configurations in the following repositories:
- [github:heywoodlh/flakes](https://github.com/heywoodlh/flakes)
- [github:heywoodlh/nixos-configs](https://github.com/heywoodlh/nixos-configs)

When possible, I try to make my tooling modular and operating system agnostic. This allows me to reap the benefits of Nix anywhere as long as I can run Nix.

---

## Command line tools

I use Vim (now, mostly Helix) for all of my writing, and Tmux for productivity.

![vim](../images/vim.png "vim")

The following tools are visible in the above image:
- [My Vim flake](https://github.com/heywoodlh/flakes/tree/66d5fb1b89f9c163d96ff8ca5ee2e737f92b0429/vim)
- [My Fish flake](https://github.com/heywoodlh/flakes/tree/66d5fb1b89f9c163d96ff8ca5ee2e737f92b0429/fish)
- [My Tmux flake](https://github.com/heywoodlh/flakes/tree/66d5fb1b89f9c163d96ff8ca5ee2e737f92b0429/tmux)
- [Starship prompt](https://starship.rs/)

Try out my Vim configuration on Linux!

```
curl -L "https://github.com/heywoodlh/flakes/releases/download/appimages/vim-$(arch).appimage" -o /tmp/vim
chmod +x /tmp/vim

/tmp/vim
```


Try out my Helix configuration on Linux!

```
curl -L "https://github.com/heywoodlh/flakes/releases/download/appimages/helix-$(arch).appimage" -o /tmp/helix
chmod +x /tmp/helix

/tmp/helix
```

Or my Fish configuration:

```
curl -L "https://github.com/heywoodlh/flakes/releases/download/appimages/fish-$(arch).appimage" -o /tmp/fish
chmod +x /tmp/fish

/tmp/fish
```

(Other appimage releases for x86 and ARM64 are [here](https://github.com/heywoodlh/flakes/releases/tag/appimages))

### Terminal emulators

iTerm on MacOS:

![neofetch](../images/macos-neofetch.png)

GNOME Terminal and Guake on Linux:

![gnome-terminal](../images/gnome-terminal.png "gnome-terminal on nixos")

---

## Firefox configuration

(I have been happily using [Zen Browser](https://zen-browser.app/) as well!)

![firefox](../images/macos-firefox.png)

Home-Manager configuration in this screenshot:
- [github:heywoodlh/nixos-configs - home/desktop.nix#L11-L241](https://github.com/heywoodlh/nixos-configs/blob/a8f96221ae02a9da1d8559063a9cd4118d662134/home/desktop.nix#L11-L241)
- [github:heywoodlh/nixos-configs - home/desktop.nix#L258-L259](https://github.com/heywoodlh/nixos-configs/blob/a8f96221ae02a9da1d8559063a9cd4118d662134/home/desktop.nix#L258-L259)

---

## Honorable mentions

[Yabai for tiling windows on MacOS](https://github.com/koekeishiya/yabai) and [my config](https://github.com/heywoodlh/nixos-configs/blob/a8f96221ae02a9da1d8559063a9cd4118d662134/darwin/roles/yabai.nix#L32-L92)

[SKHD for custom keyboard shortcuts on MacOS](https://github.com/koekeishiya/skhd) and [my config](https://github.com/heywoodlh/nixos-configs/blob/a8f96221ae02a9da1d8559063a9cd4118d662134/darwin/roles/yabai.nix#L94-L237)

[My GNOME flake](https://github.com/heywoodlh/flakes/tree/main/gnome)

[Vimium](https://vimium.github.io/) for Vim-like keybindings in Firefox

[Shortcat](https://shortcat.app/) for Vim-like keybindings to navigate MacOS

[SketchyBar](https://github.com/FelixKratz/SketchyBar) and [my config](https://github.com/heywoodlh/nixos-configs/blob/a8f96221ae02a9da1d8559063a9cd4118d662134/darwin/roles/sketchybar.nix)


[Ergodox EZ keyboard](https://ergodox-ez.com/)

### Back-end stack

The following components are absolutely essential for powering my home lab:
- Proxmox
- Git (using GitHub as my Git repository hosting provider)
- NixOS servers
- Kubernetes
- GitHub Actions
