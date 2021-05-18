---
title: 'Re-writing My Dotfiles'
layout: post
permalink: rewriting-dotfiles
tags: all, linux, macos, bash, fish, automation, devops
---

If you're just interested in my dotfiles and not my process for writing them:

[https://github.com/heywoodlh/conf](https://github.com/heywoodlh/conf)

## Preamble:

"Dotfiles" usually refers to a collection of configuration files on Unix/Unix-like systems. They are normally prepended with a "." which makes them hidden -- therefore they are called "dotfiles". People have tons of how-to articles on how they setup their dotfiles so here's my humble attempt to capture my train of thought with writing my dotfiles from scratch. 

[I've had dotfiles for years](https://github.com/heywoodlh/.dotfiles). I replicated a friend's setup and haven't cleaned things up drastically since I've set them up, I've only added more and more to them. I felt my dotfiles were getting a bit cluttered and I wanted to go back to the drawing board.

I also wanted to switch back to BASH as my shell. I have been using Fish as my shell on my client devices and after some deep introspection I realized that pretty much the only reason I use Fish was for the autocompletion. Autocompletion -- while nice -- is a pretty lame reason to install an entirely new shell on a system. Most of my systems (Linux, Mac) have BASH preinstalled, I'm using BASH on basically every other system that is not my laptop _and_ BASH is the shell I am most comfortable with, it just made sense to just switch back to BASH as my shell.

## Writing New Dotfiles:

### Requirements:

I want my new dotfiles setup to be super simple for me.

I think that's the only philosophical requirement. None of what I do in my dotfiles setup is groundbreaking but it was extremely easy for me to map out my entire setup in a few minutes. 

From a dependency standpoint these are the packages I rely on to setup my environment:

[GNU BASH](https://www.gnu.org/software/bash/)

[GNU coreutils (for the setup script)](https://www.gnu.org/software/coreutils/coreutils.html)

[Python 3 + Peru (for the setup script)](https://github.com/buildinspace/peru)

[curl (for the setup script)](https://curl.se/)

Coreutils, Peru and `curl` are just for the setup script itself. I rely on these tools pretty heavily so it's not an added inconvenience for me. You could setup my dotfiles manually and get away with BASH as the only dependency. Peru is a nice little tool for pulling down third party files using git or downloading them directly so I kept that from my previous dotfiles setup. I could stick to just

Note: at some point I want to write a Nix script instead of my garbage scripts (and could easily replace Peru) but I haven't gotten around to it because I'm a noob with Nix despite being a daily [NixOS](https://nixos.org/) and [nix-darwin](https://github.com/LnL7/nix-darwin) user on my Mac. So for now a crappy shell script will do.

### Layout:

This is the layout of the files and folders in my dotfiles' root directory (as of May 17, 2021):

```bash
conf :: tree -L 1
.
├── dependencies
├── dotfiles
├── home
├── peru.yaml
└── setup.sh
```

I'll just go alphabetically with each folder/file:

- `dependencies`: contains installation scripts for each major OS that I use (Arch Linux, Alpine, the Debian-based crap, FreeBSD, MacOS and WSL on Windows).

- `dotfiles`: contains my actual configuration files.

- `home`: will contain stuff I want to go in my home directory that doesn't fit into the `dotfiles` category -- unused at the time of writing, though.

- `peru.yaml`: contains all the stuff I want to pull down with Peru (mostly just the modules I want to use with `vim`)

- `setup.sh`: the shell script that sets everything up initially -- runs other scripts in the `dependencies` folder based on the OS that's detected


Note: [this is my repo for streamlining my NixOS and nix-darwin deployments](https://github.com/heywoodlh/nixos-builds).

If I ever get around to writing a Nix script for setting up my dotfiles I think it would greatly reduce the amount of files I have in the root of my repository.

### Setup:

My setup relies very heavily on symlinks to put the configuration files in their correct locations. This allows me to store my conf repository anywhere on my filesystem but puts the relevant config files in their proper location.

This is my entire setup process for my shell environment once the above dependencies are installed:

```bash
git clone https://github.com/heywoodlh/conf ~/opt/conf
cd ~/opt/conf

./setup.sh
echo 'source ~/.bash_profile' >> ~/.bashrc
```

Assuming I'm on a Linux (Arch Linux, Debian-based, Alpine), FreeBSD or MacOS system that `setup.sh` script will pretty much configure my entire shell environment for me.

## The `dotfiles` Directory:

The `dotfiles` directory is where my configuration files are actually stored and therefore it contains the content I care about in this repository. Let's take a look at how it's organized:

```bash
dotfiles :: tree -L 1
.
├── bash_aliases
├── bash.d
├── bash_profile
├── config
├── gitconfig
├── vim
└── vimrc
```

Each of the files/directories in this folder are supposed to be symlinked in my `$HOME` directory with a `.` prepended.

For example, this is the symlink path for `~/.bash_profile` after I've set the symlink up for it:

```bash
/home/heywoodlh/.bash_profile -> /home/heywoodlh/opt/conf/dotfiles/bash_profile
```

The `dotfiles/config` folder is important. The majority of command line-centric applications store their configs in the `~/.config` directory so the `~/.config` symlink will point to this `dotfiles/config` folder. The `dotfiles/config` folder in this git repository stores all my configs that I don't mind being public, which are most of them. For example, `dotfiles/config/terminator` contains my desired Terminator config (Terminator is a Linux terminal emulator for anyone not familiar). Once the `dotfiles/config` directory is symlinked to `~/.config` then Terminator will pick up the config stored in this git repository and I won't need to tweak Terminator's settings manually. Neat! 

The `dotfiles/vim` folder and `dotfiles/vimrc` file will be symlinked to `~/.vim` and `~/.vimrc`. My `vim` setup relies on a bunch of plugins which will be downloaded to the `dotfiles/vim/bundle` folder (using Peru) when you run the `setup.sh` script.

### BASH setup:

Since my shell is my most important and most used interface on my system, I'll get into how I have organized my config files for BASH specifically.

I chose to organize my BASH setup in an interesting way (at least I think it's interesting). Once the `bash_profile` and `bash_aliases` file have been placed as symlinks in the standard `~/.bash_profile` and `~/.bash_aliases` paths I use them for more global stuff and then for more nuanced configs I have created a new folder called `bash.d` which gets symlinked to `~/.bash.d`.

As an example, I use Docker very heavily on all my Linux systems. I have the following snippet in `bash_profile` to source the Docker specific BASH functions I have placed in `bash.d/docker`:

```bash
## Docker
if ! uname -a | grep -iq freebsd
then
        if which docker > /dev/null
        then
                if [ -f ${config_dir}/docker ]
                then
                        . ${config_dir}/docker
                fi
        fi
fi
```

This snippet basically uses the logic of "if the system is not FreeBSD and `docker` is an available command then use the `~/.bash.d/docker` config file". I have similar if-then statements for BASH configs when the system is MacOS, FreeBSD or WSL as I don't need the exact same configuration on every system. It's nice for me to differentiate between operating systems since I use the same shell in different environments.


## Wrap Up:

I'm planning on writing more up and editing this post when I make significant changes to my dotfiles setup. Writing this all out initially got me thinking about the inefficiencies I currently have in my setup so I've already benefitted from documenting my methodology in this process!
