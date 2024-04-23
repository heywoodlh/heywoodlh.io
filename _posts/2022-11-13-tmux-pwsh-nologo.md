---
title: "Launch Powershell in Tmux with -NoLogo Argument"
layout: post
published: true
permalink: tmux-pwsh-nologo
tags: [ linux, tmux, pwsh, nologo, banner, powershell, core ]
---

I recently switched to Powershell as my main shell on Linux and MacOS and I couldn't find any examples online on how to launch Powershell Core, `pwsh`, in `tmux` with the `-NoLogo` argument. So this is my quick solution to that.

I placed this at the beginning of my `~/.tmux.conf`:

```
if-shell "bash -c 'echo ${SHELL} | grep -q pwsh'" "set -g default-command 'pwsh -NoLogo'"
```

This will run a check using BASH (because if I'm running a system with `tmux` installed, it will likely have `bash` installed as well) to see if Powershell Core is my default shell. If it is, then `tmux` will use `pwsh -NoLogo` as its default command.
