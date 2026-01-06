---
layout: default
title: My Tech Stack
permalink: /stack/
---

<center><h2>heywoodlh tech stack</h2></center>

> _Updated January 5th, 2026_

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
- [Kubernetes](https://kubernetes.io/), specifically, k3s on NixOS: [github:heywoodlh/nixos-configs - nixos/roles/containers/k3s.nix](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/nixos/roles/containers/k3s-server.nix)

I store all of my meaningful configuration in the following repository:
- [github:heywoodlh/nixos-configs](https://github.com/heywoodlh/nixos-configs)

When possible, I try to make my tooling modular and operating system agnostic (aside from the constraint of being on a Unix-like operating system -- I don't really use Windows outside of gaming). This allows me to reap the benefits of Nix anywhere as long as I can run Nix.

---

## Command line tools

I use Helix for all of my writing, and Tmux for productivity.

![helix](../images/helix.png "helix")

The following tools are visible in the above image:
- [My Helix flake](https://github.com/heywoodlh/nixos-configs/tree/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/flakes/helix)
- [My Fish flake](https://github.com/heywoodlh/nixos-configs/tree/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/flakes/fish)
  - Tmux output: `github:heywoodlh/nixos-configs?dir=flakes/fish#tmux`
  - [Ghostty](ghostty.org) configuration: [github:heywoodlh/nixos-configs: flakes/fish/flake.nix#L343-L369](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/flakes/fish/flake.nix#L343-L369)
- [Starship prompt](https://starship.rs/)
- [MacOS] [Shortcat](https://shortcat.app/) for Vim-like keybindings to navigate MacOS.
- [MacOS] [SketchyBar](https://github.com/FelixKratz/SketchyBar): [sketchybar.nix](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/darwin/modules/sketchybar.nix)
- [MacOS] [Yabai](https://github.com/asmvik/yabai) tiling window manager: [yabai.nix](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/darwin/modules/yabai.nix)

Try out my Helix configuration on MacOS or Linux!

```
nix --extra-experimental-features "flakes nix-command" run "github:heywoodlh/nixos-configs?dir=flakes/helix"
```

Or my Fish/Tmux configuration:

```
# Fish
nix --extra-experimental-features "flakes nix-command" run "github:heywoodlh/nixos-configs?dir=flakes/fish"

# Tmux
nix --extra-experimental-features "flakes nix-command" run "github:heywoodlh/nixos-configs?dir=flakes/fish#tmux"
```

### Communication

Email:
- [Protonmail Bridge](https://proton.me/mail/bridge): [protonmail-bridge.yaml](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/flakes/kube/manifests/protonmail-bridge.yaml)
- [Aerc](https://aerc-mail.org/): [home/base.nix#programs.aerc](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/home/base.nix#L464-L490)

Messaging:
- [Matrix](https://matrix.org/), [Beeper](https://beeper.com) bridges: [beeper-bridges.yaml](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/flakes/kube/manifests/beeper-bridges.yaml)
- [Gomuks](https://go.mau.fi/gomuks)

## Firefox configuration

![firefox](../images/macos-firefox.png)

Home-Manager Firefox configuration in this screenshot:
- [github:heywoodlh/nixos-configs - home/desktop.nix#L11-L241](https://github.com/heywoodlh/nixos-configs/blob/a8f96221ae02a9da1d8559063a9cd4118d662134/home/desktop.nix#L11-L241)
- [github:heywoodlh/nixos-configs - home/desktop.nix#L258-L259](https://github.com/heywoodlh/nixos-configs/blob/a8f96221ae02a9da1d8559063a9cd4118d662134/home/desktop.nix#L258-L259)

---

## Honorable mentions

- [Vimium](https://vimium.github.io/) for Vim-like keybindings in Firefox.

- [Linux] [Hyprland](https://hypr.land/) tiling window manager:
  - Home-Manager module: [hyprland.nix](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/home/modules/hyprland.nix)
  - NixOS module: [hyprland.nix](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/nixos/modules/hyprland.nix)
