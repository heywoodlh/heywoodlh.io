---
title: 'Use Arch Linux as a Router'
slug: arch-linux-router
date: 2020-03-06
autotoc: true
excerpt: true
layout: post.html
collection: all, linux, security, networking
---

This article will walk through setting up Arch Linux as a simple router. Throughout the article we will refer to the following interfaces:

`eth0`: WAN interface

`eth1`: LAN interface

We will assume the following subnet is desired for the LAN:

`10.10.10.0/24`


Replace the interface names and subnet in the article as desired/needed.

## LAN Networking Setup:

### Assign a Static Internal IP Address For The LAN Interface:

This process will vary based on if a different network manager is installed on the system. These steps will assume no additional network manager is installed and will use `systemd-networkd`.

Create the file `/etc/systemd/network/21-dhcpd-wired.network` with the following contents:

```bash
[Match]
Name=eth1

[Network]
Address=10.10.10.1
```


Then start and enable `systemd-networkd`:

`sudo systemctl enable --now systemd-networkd.service`


### Set Up a DHCP Server For The LAN: 

Most of the DHCP server setup is [derived from the awesome Arch Wiki](https://wiki.archlinux.org/index.php/dhcpd#Configuration) so feel free to check out the documentation there for more information.

Install the `dhcp` package using `pacman`:

`sudo pacman -Sy dhcp --noconfirm`

Rename the default dhcpd file (which contains a bunch of examples):

`sudo mv /etc/dhcpd.conf{,.bak}`


Create a new `/etc/dhcpd.conf` with the following content:

```bash
option domain-name-servers 1.1.1.1, 1.0.0.1;
option subnet-mask 255.255.255.0;
option routers 10.10.10.1;
subnet 10.10.10.0 netmask 255.255.255.0 {
  range 10.10.10.10 10.10.10.250;
}
```

Create a new service file called `/etc/systemd/system/dhcpd4@.service` with the following content:

```bash
[Unit]
Description=IPv4 DHCP server on %I
Wants=network-online.target
After=network-online.target

[Service]
Type=forking
PIDFile=/run/dhcpd4.pid
ExecStart=/usr/bin/dhcpd -4 -q -pf /run/dhcpd4.pid %I
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
```

Enable the `network-online` systemd service:

`sudo systemctl enable systemd-networkd-wait-online.service`

Now, start and enable the DHCP service on the LAN interface:

`sudo systemctl enable --now dhcpd4@eth1.service`


With that done, any device that connects to that LAN port on your Arch device should get an IP via DHCP in the range of 10.10.10.10-10.10.10.250.

However, none of those devices will have internet access until you set up masquerading through `iptables`.


## Masquerading:

Masquerading is needed in order for the new LAN interface to have internet access using the WAN interface's connection.

Before that will work IP forwarding needs to be enabled:

`echo 'net.ipv4.ip_forward=1' | sudo tee -a /etc/sysctl.d/10-ip_forward.conf && sudo sysctl -p`

This simple script can be used to load the necessary `iptables` rules to set up Arch to masquerade the two interfaces.

Create `/opt/scripts/router.sh` with the following content:

```bash
#!/usr/bin/env bash
wanInterface="eth0"
lanInterface="eth1"

iptables -t nat -A POSTROUTING -o ${wanInterface} -j MASQUERADE -w
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT -w
iptables -A FORWARD -i ${lanInterface} -o ${wanInterface} -j ACCEPT -w
```

Make `/opt/scripts/router.sh` executable:

```bash
sudo chmod +x /opt/scripts/router.sh
```


## Systemd Service:

To ensure the iptables rules are loaded at boot, a systemd service can be used to execute the script.


Create `/etc/systemd/system/router.service` with the following content:

```bash
[Unit]
Description=Run router masquerading script

[Service]
ExecStart=/opt/scripts/router.sh
User=root

[Install]
WantedBy=multi-user.target
```

Start and enable the newly created service:

```bash
sudo systemctl enable --now router.service
```

