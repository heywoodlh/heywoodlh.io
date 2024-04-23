---
title: 'Remotely connecting to Rooted Android via ADB'
layout: post
published: true
permalink: rooted-android-remote-adb
tags: [ android, linux, ssh, adb ]
---

This post will just contain some quick snippets on how I connect to my rooted Android phone with ADB. This post assumes that your Android phone is already rooted.

## Install Termux, Termux:Boot:

First, install [F-Droid](https://f-droid.org).

Then, using F-Droid, install [Termux](https://f-droid.org/en/packages/com.termux/) and [Termux:Boot](https://f-droid.org/en/packages/com.termux.boot/).

Launch Termux and launch Termux:Boot.

## Configure Termux:

In Termux, install the `root-repo` and `tsu`:

```bash
pkg install root-repo && pkg install tsu
```

Test that you can elevate to `root`:

```bash
~ $ tsu -
:/data/data/com.termux/files/home # whoami
root
```

As the normal Termux user -- not `root` -- create `~/.termux/boot/`:

```bash
mkdir -p ~/.termux/boot
```

### Setup SSH:

With your preferred text editor, add the following to `~/.termux/boot/sshd`:

```bash
#!/data/data/com.termux/files/usr/bin/env bash

termux-wake-lock
sshd
```

Make it executable:

```bash
chmod +x ~/.termux/boot/sshd
```

The above `~/.termux/boot/sshd` script will run `sshd` on boot. You will either need to set a password for your user in Termux or set up an SSH key in the `~/.ssh/authorized_keys` file.

*Find the username of your Termux user with `whoami`*

Also, add the following to `$PREFIX/etc/ssh/sshd_config`:

```bash
Port 1024
```

This will make sure that the SSH service runs on port 1024 on your Android.

### Setup ADB:

Now add the following to `~/.termux/boot/adb`:

```bash
#!/data/data/com.termux/files/usr/bin/env bash

INTERFACE='tun0'

su -c "setprop service.adb.tcp.port 5555 && iptables -A INPUT -i ${INTERFACE} -p tcp --dport 5555 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT && stop adbd && start adbd"
```

Make sure to modify the `$INTERFACE` variable with whatever desired your desired interface is on your Android. You can list your interfaces with the `ip addr` command.

Make it executable:

```bash
chmod +x ~/.termux/boot/adb
```

The above script will run adb on TCP port 5555 of your Android. Since it is in the `~/.termux/boot` folder and you have Termux:Boot installed it will run on boot.

## Accessing ADB remotely from your workstation:

This next part assumes you're on a Unix-like machine with `adb` already installed.

### Setup your SSH config on your workstation:

I'd recommend adding something like the following to `~/.ssh/config` on your workstation:

```bash
Host kali-phone
    Host 192.168.1.10
    User u0_a107
    Port 1024
```

Change the username and IP address based on your setup. Use `whoami` while in Termux to find the username.

Once you setup your config you can use `ssh kali-phone` to login to the phone.

### Connect to ADB via SSH:

Use the following command to forward ADB to your local machine using an SSH tunnel:

```bash
ssh -L 5555:127.0.0.1:5555 kali-phone
```

Then in a separate Terminal window connect with `adb`:

```bash
adb connect localhost:5555

adb shell
```


## Conclusion:

I documented this because I wanted to access ADB over my Wireguard setup, which would encrypt the ADB connection between my Mac and my Android -- both connected to the same Wireguard instance.

## Bonus:

Here are some BASH aliases I use for ADB:

```bash
alias kali-phone-adb-start="screen -dmS kali-phone-adb ssh -L 5555:127.0.0.1:5555 -qCN kali-phone && adb connect localhost:5555"

alias kali-phone-adb-stop="screen -X -S kali-phone-adb quit && adb disconnect"

alias kali-phone-screen-capture='adb shell "while true; do screenrecord --output-format=h264 -; done" | ffplay -framerate 60 -probesize 32 -sync video -'
```
