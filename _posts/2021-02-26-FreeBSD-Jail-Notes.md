---
title: 'FreeBSD Jail Deployment Notes'
layout: post
permalink: freebsd-jail-notes
tags: all, freebsd
---


References:

[Starting with FreeBSD jails](https://rubenerd.com/starting-with-freebsd-jails/)
[How to set up FreeBSD 12 VNET jail with ZFS](https://www.cyberciti.biz/faq/configuring-freebsd-12-vnet-jail-using-bridgeepair-zfs)
[Virtualize Your Network on FreeBSD with VNET](https://klarasystems.com/articles/virtualize-your-network-on-freebsd-with-vnet/)
[Building a WireGuard Jail with the FreeBSD's Standard Tools](https://genneko.github.io/playing-with-bsd/networking/freebsd-wireguard-jail/)


## Jail Template Installation:

We're gonna setup a base template for our jail to use.

### Set up ZFS volume: 

```bash
zfs create -o mountpoint=/jail zroot/jail
zfs create zroot/jail/base
```

### Install FreeBSD to the ZFS volume:

```bash
bsdinstall jail /jail/base
```

### Update the FreeBSD instance:

```bash
freebsd-update -b /jail/base fetch install
```

### Create a snapshot for other jails to use:

```bash
zfs snapshot zroot/jail/base@12.2-RELEASE-p3
```

### Enable jails:

```bash
sysrc jail_enable=YES
```

## Create a New Jail:

I'm going to be creating a Jail just for security functions, so I'll be referring to it as `security`.

### Create a new jail filesystem from the snapshot:

```bash
zfs send -R zroot/jail/base@12.2-RELEASE-p2 | zfs receive zroot/jail/security
```

### Configure network and services for jail:

```bash
echo 'nameserver 1.1.1.1' > /jail/security/etc/resolv.conf
```

```bash
cat > /jail/security/etc/rc.conf << EOF
hostname="security"
ifconfig_epair0b="10.60.0.5/24"
defaultrouter="10.60.0.1"
sendmail_enable="NO"
sendmail_submit_enable="NO"
sendmail_outbound_enable="NO"
sendmail_msp_queue_enable="NO"
ipv6_activate_all_interfaces="NO"
sshd_enable="NO"
ntpd_enable="YES"
EOF
```

### Create VNET for Jail to Use:

```bash
sysrc cloned_interfaces="bridge0 epair0"
sysrc ifconfig_bridge0="inet 10.60.0.1/24 addm epair0a up"
sysrc ifconfig_epair0a="up"
```

### Define DEVFS rules:

```bash
cat > /etc/devfs.rules << EOF
[devfsrules_jail_security=5] add include \$devfsrules_hide_all
add include \$devfsrules_unhide_basic
add include \$devfsrules_unhide_login
add path 'tun*' unhide
add path 'bpf*' unhide
add path zfs unhide
EOF
```

### /etc/jail.conf:

```bash
mount.devfs;
exec.clean;
exec.start="sh /etc/rc";
exec.stop="sh /etc/rc.shutdown";    

path="/jail/${name}";
host.hostname="${name}.freebsd.lan";    
    
security {
    $vif = "epair0b";
    $route = "10.60.0.0/24 10.60.0.5";
    allow.chflags;
    devfs_ruleset = 5;
}
```

### Configure the jail to run on boot:

```bash
sysrc jail_enable="YES"
sysrc jail_list="security"
```

### Configure pf to allow traffic for the jail:

Allow the FreeBSD host to pass traffic between interfaces:

```bash
sysrc gateway_enable="yes"
```

Add the following to `/etc/pf.conf`:

```bash
jail_net="10.60.0.0/24"
jail_host_ipv4="10.60.0.1"
jail_security_ipv4="10.60.0.5"
```

Add NAT rules in the translation section of `/etc/pf.conf`:

```bash
nat on $ext_if inet from $lan_net to any -> ($ext_if)
nat on $ext_if inet from { $lan_net $jail_net } to any -> ($ext_if)
```

Allow incoming traffic to jail:
```bash
pass in proto tcp from $jail_host_ipv4 to $jail_security_ipv4 port 22
```

If you need to port forward an external port to a service running in the jail add the following to `/etc/pf.conf` (using port 32400 as an example):

```bash
rdr pass log on { $ext_if $int_if } inet proto udp to ($ext_if) port 32400 -> $security_jail_ipv4
```

Add the following rule in `/etc/pf.conf` to allow incoming traffic:

```bash
pass in from $jail_net
```


## Apply Config and Start Jail:

### Restart services:

```bash
sudo service netif cloneup
sudo service pf reload
sudo service jail start security
```
