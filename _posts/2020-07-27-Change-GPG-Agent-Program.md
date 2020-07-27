---
title: 'Change GPG Agent Program to Console Based Pinentry-Curses'
layout: post
permalink: change-gpg-agent-program
tags: all, linux, security, macos, gpg
---

I'm documenting this because it is a bit obscure. My original source for these commands can be found [here](https://superuser.com/questions/520980/how-to-force-gpg-to-use-console-mode-pinentry-to-prompt-for-passwords).

I prefer to just use `pinentry-curses` for unlocking GPG keys because it's so simple and I'm really only using my GPG keys from the terminal. And the GPG agent on Mac will always try to save the passwords in the keyring -- which I don't want.

Add the following `~/.gnupg/gpg-agent.conf`:

```
pinentry-program /usr/bin/pinentry-curses
```

Or if you're on MacOS using the Homebrew version:

```
pinentry-program /usr/local/bin/pinentry-curses
```


Then reload your GPG agent: 

```bash
gpg-connect-agent reloadagent /bye
```
