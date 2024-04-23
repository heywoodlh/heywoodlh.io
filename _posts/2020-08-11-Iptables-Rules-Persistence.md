---
title: 'Linux IPTables Rules Persistence'
layout: post
permalink: linux-iptables-persistence
tags: [ linux, security, firewall, iptables ]
---

Use this systemd service to have `/etc/iptables.rules` reloaded on each reboot:

In `/etc/systemd/system/iptables-restore.service`:

```
[Unit]
Description=Iptables service

[Service]
User=root
ExecStart=/sbin/iptables-restore -n /etc/iptables.rules

[Install]
WantedBy=multi-user.target
```

Run the following enable the service to run on boot:

```bash
sudo systemctl enable iptables-restore.service.
```

Saving IPTables Changes:

Run the following command to save your iptables rules to /etc/iptables.rules to be restored on each boot:

```
sudo iptables-save | sudo tee /etc/iptables.rules
```
