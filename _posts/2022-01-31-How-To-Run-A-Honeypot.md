---
title: 'How to Run a Honeypot'
layout: post
published: true
permalink: how-to-run-honeypot 
tags: all, linux, security, honeypot, heralding 
---

I decided to run a honeypot for fun, to see what interesting things I would see. Maybe at some point I'll share the details in a list and perhaps build some automation fun around the data gathered.

## Recommendations:

I would recommend setting up a dedicated VPS for something like this -- one that is not connected to any sensitive networks and does not store _any_ sensitive data on it. 

I'm going with a $5/month server with Vultr running Arch Linux and then I'll be using Docker to run [heralding](https://github.com/johnnykv/heralding). Heralding is a simple honeypot written in Python that spoofs a [range of common services](https://github.com/johnnykv/heralding) and logs the credentials used when an attacker attempts to brute-force a service.

I'd recommend changing the port for SSH to a different port than 22 and then restricting access to that port to only be available to trusted IP addresses.


## Installation:

First, [install Docker](https://docs.docker.com/engine/install/) on your Honeypot host.

Let's create a directory for logs to go:

```
mkdir -p /opt/honeypot/logs
```

And let's create empty files to mount in the container as log files:

```
touch /opt/honeypot/logs/{log_session.json,log_session.csv,log_auth.csv}
```

Once Docker is running, run the following command to deploy the heralding container on all the ports it has services for:

```
docker run -d --restart=unless-stopped \ 
	--name=heralding \
	-v /opt/honeypot/logs/log_session.json:/log_session.json \
	-v /opt/honeypot/logs/log_session.csv:/log_session.csv \
	-v /opt/honeypot/logs/log_auth.csv:/log_auth.csv \
	-p 21:21 \
	-p 22:22 \
	-p 23:23 \
	-p 25:25 \
	-p 80:80 \
	-p 110:110 \
	-p 143:143 \
	-p 443:443 \
	-p 465:465 \
	-p 993:993 \
	-p 995:995 \
	-p 1080:1080 \
	-p 2222:2222 \
	-p 3306:3306 \
	-p 3389:3389 \
	-p 5432:5432 \
	-p 5900:5900 \ 
	heywoodlh/heralding:latest
```

Now when any brute force attempts are made on your server they will be stored in the logs in `/opt/honeypots/logs` on your server!
