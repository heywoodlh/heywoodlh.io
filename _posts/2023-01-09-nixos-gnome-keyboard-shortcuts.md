---
title: "NixOS: Managing GNOME Keyboard Shortcuts and Settings with Home Manager"
layout: post
published: true
permalink: nixos-gnome-settings-and-keyboard-shortcuts
tags: all, linux, nix, nixos, keyboard, settings, home, manager
---

This will be a quick snippet on how I'm using Home Manager in my NixOS configuration to manage GNOME keyboard shortcuts and other various settings.

## Use Home Manager as a NixOS config module:

This config basically explains how I'm importing Home Manager (version 22.11) in my `/etc/nixos/configuration.nix`:

```
{ config, pkgs, ... }:

let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-22.11.tar.gz";
in {
  imports = [ <home-manager/nixos> ];
...
```

## Using Home Manager to manage GNOME:

With Home Manager imported, I can now use it's `home-manager.users.<username>.dconf.settings` option. I'll just dump my current `home-manager.users.heywoodlh` configuration to show what I currently have set as an example (I feel like it's pretty self-explanatory):

```
  home-manager.users.heywoodlh = {
    home.stateVersion = "22.11";
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disabled-extensions = "@as []";
        enabled-extensions = [
          "native-window-placement@gnome-shell-extensions.gcampax.github.com"
          "pop-shell@system76.com"
          "caffeine@patapon.info"
          "hidetopbar@mathieu.bidon.ca"
          "gsconnect@andyholmes.github.io"
        ];
        favorite-apps = ["firefox.desktop" "kitty.desktop"];
        had-bluetooth-devices-setup = true;
        remember-mount-password = false;
        welcome-dialog-last-shown-version = "42.4";
      };
      "org/gnome/shell/extensions/hidetopbar" = {
        enable-active-window = false;
        enable-intellihide = false; 
      };
      "org/gnome/desktop/interface" = {
        clock-show-seconds = true;
        clock-show-weekday = true;
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
        font-antialiasing = "grayscale";
        font-hinting = "slight";
        gtk-theme = "Nordic";
        toolkit-accessibility = true;
      };
      "org/gnome/desktop/wm/keybindings" = {
        activate-window-menu = "@as []";
        toggle-message-tray = "@as []";
        close = "['<Super>q', '<Alt>F4']";
        maximize = "@as []";
        minimize = "['<Super>comma']";
        move-to-monitor-down = "@as []";
        move-to-monitor-left = "@as []";
        move-to-monitor-right = "@as []";
        move-to-monitor-up = "@as []";
        move-to-workspace-down = "@as []";
        move-to-workspace-up = "@as []";
        toggle-maximized = "['<Super>m']";
        unmaximize = "@as []";
      };
      "org/gnome/desktop/wm/preferences" = {
        button-layout = "close,minimize,maximize:appmenu";
        num-workspaces = 10;
      };
      "org/gnome/shell/extensions/pop-shell" = {
        focus-right = "@as []";
        tile-by-default = true;
        tile-enter = "@as []";
      };
      "org/gnome/desktop/peripherals/touchpad" = {
        tap-to-click = true;
        two-finger-scrolling-enabled = true;
      };
      "org/gnome/settings-daemon/plugins/media-keys" = {
        next = [ "<Shift><Control>n" ];
        previous = [ "<Shift><Control>p" ];
        play = [ "<Shift><Control>space" ];
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        ];
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "kitty super";
        command = "kitty -e tmux";
        binding = "<Super>Return";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "kitty ctrl_alt";
        command = "kitty -e tmux";
        binding = "<Ctrl><Alt>t";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "rofi-rbw";
        command = "rofi-rbw --action copy";
        binding = "<Ctrl><Super>s";
      };
      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
        name = "rofi launcher";
        command = "rofi -theme nord -show run -display-run 'run: '";
        binding = "<Super>space";
      };
    };
  };
```

Using Home Manager this way allows me to have an easy, declarative GNOME setup.

## Tips for modifying dconf settings:

If you install `dconf-editor` you can see what options are available when you run the `dconf-editor` application.

One of the things that I do when I want to make a setting persist in my config, is I run the following command:

```
dconf dump / > old-conf.txt
```

Then I make a change in my GNOME settings and run `dconf dump` again:

```
dconf dump / > new-conf.txt
```

You can now run `diff old-conf.txt new-conf.txt` to figure out what options in your GNOME settings changed and then codify it in your `configuration.nix` with the `home-manager.users.<username>.dconf.settings` attribute.