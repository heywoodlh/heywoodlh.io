---
title: 'Port Forward With IPTables'
slug: port-forward-iptables
date: 2020-02-16
autotoc: true
excerpt: true
layout: post.html
collection: all, linux, security, networking
---

This article will walk through setting up a simple port forward using `iptables`. 

I found very few resources for setting up a port forward with a device with a persistent Wireguard connection, so this is a simple way to set that up.

## Script:

This simple script can be used to initiate the port forward in `iptables`:

```bash
#!/usr/bin/env bash

tcpPorts=(32400)
udpPorts=(1900)
gatewayInternalAddress=192.168.0.1
clientAddress=192.168.0.50

externalInterface="eth0"
internalInterface="eth1"

iptables -P FORWARD DROP

for port in "${tcpPorts[@]}"
do
	iptables -A FORWARD -i ${externalInterface} -o ${internalInterface} -p tcp --syn --dport ${port} -m conntrack --ctstate NEW -j ACCEPT -w
	iptables -A FORWARD -i ${externalInterface} -o ${internalInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -w
	iptables -A FORWARD -i ${internalInterface} -o ${externalInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -w

	iptables -t nat -A PREROUTING -i ${externalInterface} -p tcp --dport ${port} -j DNAT --to-destination ${clientAddress} -w
	iptables -t nat -A POSTROUTING -o ${internalInterface} -p tcp --dport ${port} -d ${clientAddress} -j SNAT --to-source ${gatewayInternalAddress} -w
done

for port in "${udpPorts[@]}"
do
        iptables -A FORWARD -i ${externalInterface} -o ${internalInterface} -p udp --dport ${port} -m conntrack --ctstate NEW -j ACCEPT -w
        iptables -A FORWARD -i ${externalInterface} -o ${internalInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -w
        iptables -A FORWARD -i ${internalInterface} -o ${externalInterface} -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -w

        iptables -t nat -A PREROUTING -i ${externalInterface} -p udp --dport ${port} -j DNAT --to-destination ${clientAddress} -w
        iptables -t nat -A POSTROUTING -o ${internalInterface} -p udp --dport ${port} -d ${clientAddress} -j SNAT --to-source ${gatewayInternalAddress} -w
done
```

Modify the variables as needed. I won't explain each of the variables as they should be self-explanatory.

As an example, you could place the script in `/opt/scripts/expose-7070.sh` and make it executable:

```bash
sudo chmod +x /opt/scripts/expose-7070.sh
```


## Systemd Service:

To ensure the script runs on boot, a systemd service can be used to execute the script (assuming you placed the script in `/opt/scripts/expose-7070.sh`):


```bash
[Unit]
Description=Port forward port 7070

[Service]
ExecStart=/opt/scripts/expose-7070.sh
User=root

[Install]
WantedBy=multi-user.target
```

Place the above into `/etc/systemd/system/expose-7070.service` and run the following command to ensure the service runs on every boot and also runs now:

```bash
sudo systemctl enable --now expose-7070.service
```


That should run the script on each boot and should have loaded the rules now.
