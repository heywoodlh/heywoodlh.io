---
title: "Simple nfdump Setup (in Containers) for Netflow Collection and Analysis"
layout: post
published: true
permalink: a-simple-nfdump-setup
tags: [ linux, netflow, network, nfdump ]
---

This post will outline my simple Netflow collection setup running with some containers with nfdump tooling I setup for this purpose.

## Assumptions:

I'm going to make the following assumptions: 
- You're in a Unix-like environment
- Docker is the targeted container engine
- Netflow binaries will be stored in `/flows` on your system
- You already have another system that supports sending Netflow data to a remote host, such as a switch or router (I will not cover how to setup sflow on a Linux machine)

Modify the content to your needs if any of these assumptions don't line up with your setup.

## Why nfdump?

At a previous role I was introduced to `nfdump` and really liked it. It's like `tcpdump` in the fact that it's a command line tool and provides a user with the ability to inspect the netflow data based on filters such as time or source or destination hosts/ports -- but unlike `tcpdump`, `nfdump` is used against Netflow binary files that have the captured data on your filesystem. 

The repository for nfdump is here: [phaag/nfdump](https://github.com/phaag/nfdump)

## Setup nfcapd 

Nfcapd is a daemon included with nfdump that receives Netflow data and writes it to disk for inspection with `nfdump`. 

First, let's create the `/flows` directory and make sure that UID 1000 owns it (that UID/GID is used in the container):

```
sudo mkdir -p /flows
sudo chown -R 1000 /flows
```

We can spin up an nfcapd receiver with the following `docker` command:

```
docker run -d --restart=unless-stopped --name=nfcapd -p 9995:9995/udp -v /flows:/flows heywoodlh/nfcapd:latest
```

Now that nfcapd is setup, you can send Netflow to UDP port 9995 on your Docker host and it should start writing the received data to binary files in the `/flows` directory. My container image by default will organize flows into the `/flows` directory by `year/month/day/hour`. For example, flows captured between 4:00 p.m. to 5:00 p.m. July 20th, 2022 would be in the following folder `/flows/2022/07/20/16`.

If you do not like the defaults I have set in my [heywoodlh/nfcapd](https://hub.docker.com/r/heywoodlh/nfcapd) image, you can check out `nfcapd`'s arguments by running this command:

```
docker run -it --rm heywoodlh/nfcapd --help
```

You can then provide your desired `nfcapd` arguments to the `docker run` command. If you are going this route I can assume you are technical enough to figure out what you need so I will not cover any thing more of going outside the defaults I have set.

## Accessing the Captured Netflow Data:

For actually accessing the data you need to use the `nfdump` tool. You can either install `nfdump` on your machine -- or just run a Docker container I have setup for this purpose. I will cover how to use the container as that will be a bit more predictable.

Use the following `docker` command to recursively access ALL of the Netflow data in the `/flows/2022` directory:

```
docker run -it --rm -v /flows:/flows heywoodlh/nfdump -R /flows/2022
```

As I stated earlier in this post, you can use filters with `nfdump` to parse out the data you actually want to see. For example, if I want to see all traffic related to destination port 80 from an IP address at `192.168.1.143`, I could run this command:

```
docker run -it --rm -v /flows:/flows heywoodlh/nfdump -R /flows/2022 "dst port 80 and src host 192.168.1.143"
```

You can access `nfdump`'s help section with the following command:

```
docker run -it --rm heywoodlh/nfdump --help
```

If you install `nfdump` on your machine directly, all of the above arguments to `nfdump` should work the same. 

The filters provided with `nfdump` can provide really cool pieces of information about what's going on with your network. Using `nfdump` also allows you to have flexibility to build simple but effective monitoring tools around Netflow.

## Additional Reading:

Github repo: [phaag/nfdump](https://github.com/phaag/nfdump)

Man pages: [nfcapd](https://manpages.ubuntu.com/manpages/jammy/man1/nfcapd.1.html), [nfdump](https://manpages.ubuntu.com/manpages/jammy/man1/nfdump.1.html)

Dockerfiles: [heywoodlh/nfcapd](https://github.com/heywoodlh/dockerfiles/blob/master/nfcapd/Dockerfile), [heywoodlh/nfdump](https://github.com/heywoodlh/dockerfiles/blob/master/nfdump/Dockerfile)

Github Actions used to build the images: [nfcapd-buildx](https://github.com/heywoodlh/actions/blob/master/.github/workflows/nfcapd-buildx.yml), [nfdump-buildx](https://github.com/heywoodlh/actions/blob/master/.github/workflows/nfdump-buildx.yml)

