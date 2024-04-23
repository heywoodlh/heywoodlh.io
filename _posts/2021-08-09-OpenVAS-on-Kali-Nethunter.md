---
title: 'Running OpenVAS on Kali Nethunter'
layout: post
published: true
permalink: openvas-nethunter
tags: [ linux, security, vulnerabilities, vulnerability, openvas ]
---

This post will document how I got OpenVAS running on Kali Nethunter running on my OnePlus One.

## Install Dependencies:

```
apt-get update &&\
	apt-get install -y openvas supervisor
```

Create necessary directories for the services we will need:

```bash
mkdir -p /var/run/redis-openvas/
mkdir -p /run/ospd/
```

## Setup Supervisord:

We're gonna use `supervisord` to run the services needed for OpenVAS. You could also use the Kali Nethunter Manager to manage the services but I like this approach better.

This is what my `/etc/supervisor/supervisord.conf` looks like:

```
[supervisord]
nodaemon=true

[include]
files = /etc/supervisor/conf.d/*.conf
```

Then I created a new file `/etc/supervisor/conf.d/openvas.conf` with the following content:

```
[program:redis]
command=/usr/bin/redis-server /etc/redis/redis-openvas.conf
priority=0
startsecs=0
user=root

[program:openvas]
command=/usr/bin/ospd-openvas --unix-socket /run/ospd/ospd.sock --pid-file /run/ospd/ospd-openvas.pid --log-file /var/log/gvm/ospd-openvas.log --lock-file-dir /var/lib/openvas
priority=10
startsecs=0
user=root

[program:gvmd]
command=/usr/sbin/gvmd --osp-vt-update=/run/ospd/ospd.sock
priority=20
startsecs=0
user=root
```



### A note on Postgres

Other important applications, such as Metasploit, in Kali rely on Postgres. OpenVAS can also use Postgres (or SQLite3) as its database back-end. Nethunter Manager has a predefined service for Postgres so I would recommend starting the service using the Nethunter Manager app -- especially since other applications like Metasploit use Postgres.


### Supervisord service in Nethunter Manager

Add a new service for `supervisord` in the Kali Nethunter Manager app with the following info:

Title:
`supervisord`

Command for starting the service:
`/usr/bin/supervisord -c /etc/supervisor/supervisord.conf`

Command for stopping the service:
`/usr/bin/killall supervisord`

String for checking the service:
`supervisord`

If you want supervisord and OpenVAS to run on the boot of Kali Nethunter then check the box for RunOnChrootStart.

Position to insert:
`Insert to Bottom`


Start the service

## Setup OpenVAS:

Run the following command to do some initial setup of the databases:

```bash
gvm-setup
```
