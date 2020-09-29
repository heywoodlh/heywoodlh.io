---
title: 'Configuring MacOS to Use Apple Watch or Touch ID for MFA With Sudo'
layout: post
permalink: macos-sudo-watch-touch-id
tags: all, macos, security, x86
---


Using the Apple Watch or Touch ID as a second factor to run `sudo` commands on Macbook Pros is not only convenient but also adds a second layer of physical security to your machine. In theory, it could help mitigate security risk if an attacker has an unprivileged shell on your Mac and somehow steals your password. 

I found a few articles that covered some of the PAM configuration but none that configured PAM to require your password AND a confirmation via Touch ID or Apple Watch. Most of the articles covered how to use your Apple Watch/Touch ID to bypass the password completely. In my case I want to have my Apple Watch/Touch ID on my Macbook Pro to serve as an additional factor to my password, specifically for the `sudo` command.

MacOS' configuration system is built in a way that even with `sudo` access there isn't as much that you can do with a shell to screw around with the operating system configuration in comparison to Linux or Windows with an elevated shell. Despite that, it's still nice to have the added security. 

## Setup:

### Disclaimer:

YOU CAN SERIOUSLY MESS UP YOUR SYSTEM IF YOU MESS UP YOUR PAM CONFIGURATION. 

What I recommend doing is opening a terminal window, elevating to root with `sudo su -` and leave that terminal window open in the background and test your configuration changes by opening a new terminal window and running `sudo echo hello` (or something like that). 

I would also recommend backing up your `/etc/pam.d/sudo` file before modifying it like so:

```bash
sudo cp /etc/pam.d/sudo{,.bak}
```


### Password + Touch ID PAM Configuration:

If you don't have an Apple Watch but have Touch ID, you don't need to set anything additional up as the [PAM module is included in MacOS for your Mac to use Touch ID](https://opensource.apple.com/source/pam_modules/pam_modules-173.1.1/modules/pam_tid/pam_tid.c.auto.html). 

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


This configuration will require both a password _and_ Touch ID to run any `sudo` command.


### Password + Apple Watch _or_ Touch ID PAM Configuration:

There is no Apple Watch PAM module available for use on MacOS out of the box (that I know of anyway). Thankfully, [someone wrote one](https://github.com/biscuitehh/pam-watchid). Install it with the following commands:


```
git clone https://github.com/biscuitehh/pam-watchid /tmp/pam-watchid
cd /tmp/pam-watchid
sudo make install
```


Once the install completes, configure `/etc/pam.d/sudo` like so:

```
# sudo: auth account password session
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
auth	   sufficient	  pam_watchid.so
auth	   required	  pam_tid.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
```

This configuration will require you to enter in your password and authenticate with either your Apple Watch or Touch ID. From the configuration you can see that you will be prompted to use your Apple Watch first and then Touch ID if you fail to authenticate with Apple Watch.


### Password + Touch ID _or_ Apple Watch PAM Configuration:

If you want Touch ID to be the first method attempted before authenticating with Apple Watch then follow the instructions above except you'll flip the `pam_watchid.so` reference with `pam_tid.so` in the PAM configuration:

```
# sudo: auth account password session
auth       sufficient     pam_smartcard.so
auth       required       pam_opendirectory.so
auth       sufficient     pam_tid.so
auth       required       pam_watchid.so
account    required       pam_permit.so
password   required       pam_deny.so
session    required       pam_permit.so
```


## One Thing to Look Out For:

[MacOS will wipe out custom PAM config changes after updates](https://github.com/biscuitehh/pam-watchid/issues/5). This is a trivial issue to bypass if you just write a script that installs the Apple Watch PAM module and updates the PAM config for you. MacOS updates infrequently enough that I haven't had a strong desire/need to do this yet.

## Additional Reading:

I found [this Stack Exchange post](https://unix.stackexchange.com/questions/106131/pam-required-and-sufficient-control-flag) really useful on understanding how PAM's logic is implemented between `required`, `sufficient` and `requisite`.

[Lots of articles on how to configure PAM with Touch ID](https://duckduckgo.com/?t=ffab&q=pam+sudo+touch+id+&ia=web)

[sudo with TouchID and Apple Watch, even inside tmux](https://andre.arko.net/2020/07/10/sudo-with-touchid-and-apple-watch-even-inside-tmux/)
