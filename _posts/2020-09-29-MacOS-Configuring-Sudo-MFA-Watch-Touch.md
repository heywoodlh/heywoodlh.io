---
title: 'Configuring MacOS to Use Apple Watch or Touch ID for MFA With Sudo'
layout: post
permalink: macos-sudo-watch-touch-id
tags: [ macos, security, x86 ]
---


This article will walk through using your password _and_ touch ID/Apple Watch authentication to ensure multi factor authentication is required on all `sudo` events. This will make your setup a bit more resilient to a remote attacker with a shell needing to elevate privileges with `sudo`.

## Setup:

### Password + Touch ID or Apple Watch PAM Configuration:

The [PAM module is included in MacOS for your Mac to use Touch ID](https://opensource.apple.com/source/pam_modules/pam_modules-173.1.1/modules/pam_tid/pam_tid.c.auto.html) or your Apple Watch. However, it will not work if your Macbook's lid is closed (read below for my workaround to that issue). 

Configure `/etc/pam.d/sudo` like so:

```
# sudo: auth account password session
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
auth	   required	  pam_tid.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
```


This configuration will require both a password _and_ Touch ID/Apple Watch confirmation to run any `sudo` command.


### The pam_tid Module Does Not Work With a Macbook's Lid Closed:

I have discovered that `pam_tid.so` does not work at all unless your laptop lid is open (even if you are using an Apple Watch). To work around this I use a third party [pam_watchid](https://github.com/biscuitehh/pam-watchid) PAM module. At the time of writing we need to use a [fork of pam_watchid](https://github.com/msanders/pam-watchid) which [supports Apple Silicon and Intel Macs](https://github.com/biscuitehh/pam-watchid/pull/15).

Install `pam_watchid`:

```bash
git clone https://github.com/msanders/pam-watchid /tmp/pam-watchid
cd /tmp/pam-watchid
make install
```

Configure `/etc/pam.d/sudo`:

```bash
# sudo: auth account password session
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
auth       sufficient     pam_watchid.so
auth       required     pam_tid.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
```

This will configure PAM to use `pam_watchid.so` then `pam_tid.so`.



## MacOS Updates Will Reset Your PAM Changes:

[MacOS will wipe out custom PAM config changes after updates](https://github.com/biscuitehh/pam-watchid/issues/5). This is a trivial issue to bypass if you just write a script that installs the Apple Watch PAM module and updates the PAM config for you. MacOS updates infrequently enough that I haven't had a strong desire/need to do this yet.

## Additional Reading:

I found [this Stack Exchange post](https://unix.stackexchange.com/questions/106131/pam-required-and-sufficient-control-flag) really useful on understanding how PAM's logic is implemented between `required`, `sufficient` and `requisite`.

[Lots of articles on how to configure PAM with Touch ID](https://duckduckgo.com/?t=ffab&q=pam+sudo+touch+id+&ia=web)

[sudo with TouchID and Apple Watch, even inside tmux](https://andre.arko.net/2020/07/10/sudo-with-touchid-and-apple-watch-even-inside-tmux/)
