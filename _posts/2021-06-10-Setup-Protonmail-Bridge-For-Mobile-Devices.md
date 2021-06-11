---
title: 'Protonmail Bridge for Mobile Devices'
layout: post
permalink: protonmail-bridge-mobile
tags: all, docker, linux, protonmail, ios, ipados, ipad, iphone, apple, android
---

This post will go over setting up a bridge to use Protonmail with other devices that don't have the [official Protonmail Bridge available for them](https://protonmail.com/bridge/). The Protonmail Bridge allows you to get all the benefits of Protonmail with other mail clients. 

I'm writing this because I think Protonmail's mobile client kind of sucks and because [Apple announced some pretty nice privacy features coming in i[Pad]OS 15]() that I would love to take advantage of. Plus, I wouldn't mind having one less app on my phone.

## Requirements:

- A Linux server to host the bridge
- Docker installed on your Linux host

I'm gonna assume you have a Linux server setup that you'd like to dedicate to the bridge. I'd recommend setting up Wireguard or some sort of VPN to encrypt the connection between your client and the server and as a way to restrict access to the bridge.

## Setup the Bridge:

I'm going to use [hydroxide](https://github.com/emersion/hydroxide), an open source Protonmail bridge for making Protonmail accessible to my other devices.

I created a cross-architecture [Docker image](https://hub.docker.com/r/heywoodlh/hydroxide) to simplify this process greatly for myself and others.

First, install Docker on your host:

[Get Docker](https://docs.docker.com/get-docker/)

For the rest of the post I'll assume that the following Docker commands will be run as root or as a user who can access the Docker daemon. Alternatively, I would suggest looking into [rootless Docker](https://docs.docker.com/engine/security/rootless/) and running the hydroxide container as an unprivileged user. Regardless, just make sure you're at a place where you can run `docker` commands without an issue.

Now, let's login to Protonmail with `hydroxide`:

```bash
mkdir -p ~/.config/hydroxide

docker run -it --rm -v ~/.config/hydroxide:/root/.config/hydroxide heywoodlh/hydroxide auth <user>
```

Now run the following command to run Hydroxide's IMAP, SMTP and CalDav instance:

```bash
docker run --restart unless-stopped -p 1025:1025 -p 1143:1143 -p 8080:8080 -d -v ~/.config/hydroxide:/root/.config/hydroxide --name hydroxide heywoodlh/hydroxide serve
```

Check if your container is running:

```bash
docker logs hydroxide
```

## Connect Your Client:

Now all you have to do is connect your app to your Hydroxide instance using the following settings:

IMAP: hydroxide-host:1143
SMTP: hydroxide-host:1025
CardDAV: hydroxide-host:8080
