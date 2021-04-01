---
title: 'FreeBSD Jail Deployment Notes'
layout: post
permalink: freebsd-jail-notes
tags: all, freebsd
---


References:

[FreeBSD Handbook: Chapter 15. Jails](https://docs.freebsd.org/en/books/handbook/jails/)

[FreeBSD jails with a single public IP address](https://www.davd.io/posts-freebsd-jails-with-a-single-public-ip-address/)


### Install ezjail:

```bash
pkg install ezjail
```

### Jail Template Installation:

We're gonna setup a base template for our jail to use.

```bash
ezjail-admin install
```

### Enable ezjail on boot:

```bash
sysrc ezjail_enable="YES"
```

Let's start the ezjail service:

```bash
service ezjail start
```

### Create an interface for jails to use:

```bash
sysrc cloned_interfaces="lo1"
sysrc ipv4_addrs_lo1="10.60.0.1-9/29"
```

Bring the interface up:

```bash
service netif cloneup
```

## Create a New Jail:

I'm going to be creating a Jail just for security functions, so I'll be referring to it as `security`.

```bash
ezjail-admin create security 10.60.0.2
```

### Configure pf to allow traffic for the jail:

Add the following to `/etc/pf.conf`:

```bash
jail_if="lo1"
jail_host_ipv4="10.60.0.1"
jail_security_ipv4="10.60.0.2"
```

To allow outbound network connections from the jails:

```bash
nat on $ext_if from $jail_if:network to any -> ($ext_if)
```

If you need to port forward an external port to a service running in the jail add the following to `/etc/pf.conf`:

```bash
rdr on $ext_if proto tcp from any to $ext_if port $tcp_port -> $jail_security_ipv4
```

Apply your changes to pf:

```bash
service pf restart
```

### Setup /etc/resolv.conf:

```bash
cp /etc/resolv.conf /usr/jails/security/etc/resolv.conf
```

### Start the jail:

```bash
ezjail-admin start security
```

## Access the Jail:

Run the following command to get a shell in the jail:

```
ezjail-admin console security
```
