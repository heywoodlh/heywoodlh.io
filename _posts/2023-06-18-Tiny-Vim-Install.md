---
title: "Tiny Vim Install"
layout: post
published: true
permalink: tiny-vim-install
tags: all, linux, vim, ide, github, actions
---

## Some background

A friend recently pointed me to this repository as a place to grab a self-contained `vim` binary: [https://github.com/dtschan/vim-static](https://github.com/dtschan/vim-static)

The most recent commit is about 4 years old and the `build.sh` script uses an old version of Vim. I wanted to see if I could improve on this process and build Vim on an automated, regular cadence and publish the binaries.

So here's my solution to that: [https://github.com/heywoodlh/vim-builds](https://github.com/heywoodlh/vim-builds)

My build process deviates slightly from the original build.sh script but uses mostly the same process. The most notable deviation in my build is that I'm building whatever version of Vim is available at the main repository at the time of the build, and I'm using GitHub Actions + Docker's `buildx` plugin to provide an automated build that produces multiarch (x86_64, and ARM64) Linux binaries.

## Installation

Find the latest release and grab the link for the binary of your desired architecture here: [https://github.com/heywoodlh/vim-builds/releases](https://github.com/heywoodlh/vim-builds/releases)

Assuming I was grabbing the latest binary for the `9.0` tag for the `x86_64` architecture on my Git repo, these are all the commands necessary for a fully functional Vim installation:

```
mkdir -p ~/bin
curl -L 'https://github.com/heywoodlh/vim-builds/releases/download/9.0/vim-x86_64' -o ~/bin/vim
chmod +x ~/bin/vim
PATH="~/bin:$PATH" # Add this to your ~/.bashrc or other shell config file to make it persistent
```

To disable the warning about not being able to read `defaults.vim`, create an empty `~/.vimrc`:

```
touch ~/.vimrc
```

## Why?

This static Vim binary is tiny and should work out of the box on all Linux distributions. If you aren't aware, many binaries compiled on a Glibc-centered system (Ubuntu, Arch Linux, etc.) don't work on a Musl-based system (Alpine Linux). This makes these Vim binaries a potentially ideal candidate for installations where portability is desired (containers, ephemeral environments, etc.).

I'm a huge fan of Vim and love the idea of being able to build/host a totally package-manager-independent Vim binary.

But mostly, I wanted to see if I could do it.
