---
title: 'My Vim Notes Setup'
layout: post
permalink: vim-notes-setup
tags: [ vim, syncthing, notes ]
---

## Why I am writing this:

There are a ton of super fancy note apps out there. I've tried a small handful of them and while I haven't _hated_ them I also haven't loved them. I don't think it's a problem with any of the apps themselves, rather it's a problem with me: _I want to just use `vim`_ as my text editor for notes.

Here are the requirements I've wanted to meet with my workflow:
- Use `vim` as my editor

- Encrypted and private *synchronization* across devices

- Ease of use on any platform -- including mobile

All of the other apps I have used aren't `vim` and require use of some centralized service that are often invasive when it comes to privacy (Google, Dropbox, etc.). And I don't want to run Nextcloud just for notes (although, I do have lots of love Nextcloud).


## Syncronization:

I use Syncthing to keep my files in sync across devices. One big issue for my setup is that I have an iPad Pro and an iPhone and [there is no Syncthing i[Pad]OS app](https://docs.syncthing.net/users/faq.html#why-is-there-no-ios-client) but I will address how I deal with that later.

I like Syncthing because it's simple, [open source](https://github.com/syncthing/syncthing), decentralized and files are end-to-end encrypted in transit. In theory, my files are not readable by anyone but my own trusted devices.

I won't get into how to setup Syncthing but once it is running, I have a `notes` directory that I sync with Syncthing between all my devices (except for iOS devices). My basic workflow for creating a new note is this:

```bash
cd ~/Sync/notes
vim new-note.md
```

That's it. 

For reading notes I use `less` if I don't need to edit anything.

### iOS devices:

Since there is no Syncthing iOS app I have a FreeBSD VPS that I use and I access my notes on that server using SSH. Since this is a command-line focused workflow it's not really a huge inconvenience for me to have the added step of SSH-ing into a server.

My preferred iOS SSH/Mosh client is [Blink](https://blink.sh/) as it is open source and looks/feels premium.

Networks are fast enough that I don't really notice any latency since standard SSH connections are usually low on bandwidth usage. As an added measure to keep my SSH connections extra reliable I use [mosh](https://mosh.org/) to gracefully survive disconnects or generally unreliable connectivity. I use [Wireguard](https://www.wireguard.com/) to keep my server always available to my mobile devices but restrict access to my server from anywhere else.

To make these workflows extremely convenient on my phone, I use shell scripts and aliases to speed up repetitive tasks. For example, I use a BASH alias on my server named `journal` to execute the following shell script to write in my journal:

<script src="https://gist.github.com/heywoodlh/f676f11bf32bb805f25f7243e39db6b2.js"></script>

One relevant thing that I am watching for would be a way to run Syncthing on my iPad/iPhone directly through [iSH](https://ish.app/). However, [Syncthing on iSH crashes](https://github.com/ish-app/ish/issues/755) due to [lack of iNotify support in iSH](https://github.com/ish-app/ish/issues/491). And as I stated earlier, SSH-ing into a remote server to access my notes is not really an inconvenient added step for me.

## Encryption at rest:

Syncthing encrypts everything in transit. Normally for notes, I don't write anything super sensitive and don't need additional encryption for files at rest on my machines. However, for when I do want my files on my machines to be encrypted I use `gpg` to encrypt stuff. 

You can use [`vim` to edit gpg encrypted files](https://vim.fandom.com/wiki/Edit_gpg_encrypted_files#Comments). Throw the following into `~/.vimrc`:

```bash
" Don't save backups of *.gpg files
set backupskip+=*.gpg
" To avoid that parts of the file is saved to .viminfo when yanking or
" deleting, empty the 'viminfo' option.
set viminfo=

augroup encrypted
  au!
  " Disable swap files, and set binary file format before reading the file
  autocmd BufReadPre,FileReadPre *.gpg
    \ setlocal noswapfile bin
  " Decrypt the contents after reading the file, reset binary file format
  " and run any BufReadPost autocmds matching the file name without the .gpg
  " extension
  autocmd BufReadPost,FileReadPost *.gpg
    \ execute "'[,']!gpg --decrypt --default-recipient-self" |
    \ setlocal nobin |
    \ execute "doautocmd BufReadPost " . expand("%:r")
  " Set binary file format and encrypt the contents before writing the file
  autocmd BufWritePre,FileWritePre *.gpg
    \ setlocal bin |
    \ '[,']!gpg --encrypt --default-recipient-self
  " After writing the file, do an :undo to revert the encryption in the
  " buffer, and reset binary file format
  autocmd BufWritePost,FileWritePost *.gpg
    \ silent u |
    \ setlocal nobin
augroup END
```

The general workflow for creating and editing a file encrypted with `gpg` could follow like so:

```bash
cd ~/Sync/notes

# Create an empty file, encrypt it and then remove the original empty file 
touch super-secret.txt &&\
    gpg -r l.spencer.heywood@protonmail.com --encrypt super-secret.txt &&\
    rm super-secret.txt
```

Now, if you've added the above `.vimrc` snippet to edit `.gpg` files in `vim` you can edit the newly created `super-secret.txt.gpg`:

```bash
vim super-secret.txt.gpg
```

I should probably write a shell script to do this all for me automatically but I haven't yet since it's really not that often that I need encryption for my (usually) non-sensitive notes on my machines.
