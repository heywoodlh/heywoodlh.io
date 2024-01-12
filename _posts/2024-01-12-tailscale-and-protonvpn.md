---
title: "Using Tailscale with ProtonVPN"
layout: post
published: false
permalink: tailscale-protonvpn
tags: all, linux, vpn, tailscale, protonvpn, mullvad
draft: true
---

I recommended Tailscale's Mullvad integration to a friend who posed this question: can I use Tailscale with ProtonVPN instead of Mullvad? They were already paying for ProtonVPN, so it is an extremely practical question (although, I would argue that Mullvad is superior/unrivaled as a privacy vendor).

I became curious enough that I wanted to answer this myself. Tailscale has become my Swiss Army Knife for networking, so I absolutely have a selfish interest to see if this would work.

The end-goal of this is to have an exit node in your Tailnet that tunnels all its traffic through ProtonVPN for anonymity:

```
Your device (phone, laptop, Apple TV) -> Tailscale -> Exit Node -> ProtonVPN
```

This would allow other devices in your Tailnet to take advantage of ProtonVPN for anonymous browsing.

## My recommendations

I strongly encourage using a VPS on a cloud provider so you _always_ have the option to troubleshoot the server remotely if issues arise. I've been a happy Vultr user but any cheap vendor like Hetzner, DigitalOcean, etc. should work and will likely outperform your home network.

Feel free to use my Vultr referral link for $100 in free credits on Vultr (or don't, I don't care): [https://www.vultr.com/?ref=7568710](https://www.vultr.com/?ref=7568710)

I'm going to use commands specific to Ubuntu (specifically, Ubuntu 22.04) for ease-of-use. I'm going to assume you already have SSH access setup to the machine.

## Setup

If desired, Tailscale and Wireguard can both be installed using this startup script on your server:

```
#!/bin/sh

## Install Wireguard and dependencies
apt update && apt install -y wireguard resolvconf

## Install Tailscale
curl https://tailscale.com/install.sh | bash

## Enable IP forwarding
echo 'net.ipv4.ip_forward = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | tee -a /etc/sysctl.d/99-tailscale.conf
sysctl -p /etc/sysctl.d/99-tailscale.conf
```

### Tailscale

I'd recommend installing Tailscale before ProtonVPN due to the fact that ProtonVPN's full-tunnel will make your VPS' public IP inaccessible.

On the server, install Tailscale (skip this command if the above startup script was used):

> Always verify shell scripts aren't malicious before downloading and piping to `sh` or `bash`

```
curl https://tailscale.com/install.sh | sudo bash
```

Enable IP forwarding with this command (skip this command if the above startup script was used):

```
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf
```

Then, bring Tailscale up, and disable Tailscale's DNS (so we can just use ProtonVPN's DNS):

```
sudo tailscale up --accept-dns=false --advertise-exit-node
```

In Tailscale's web interface, select your node's settings > Edit route settings... and then check the box to "Use as exit node".

I'd recommend for the remainder of this post, that you SSH into your server using its Tailscale provided IP address.

### WireGuard + ProtonVPN

First, let's setup WireGuard on the Ubuntu server to connect to ProtonVPN. ProtonVPN's documentation is very helpful on this: [https://protonvpn.com/support/wireguard-configurations/](https://protonvpn.com/support/wireguard-configurations/)

If you don't want to read ProtonVPN's docs, here's the steps:
1. Sign in to [account.protonvpn.com](https://account.protonvpn.com) and go to Downloads → WireGuard configuration.
2. Choose your desired configuration (I disabled Moderate NAT, NAT-PMP, and VPN Accelerator)
3. Press "Create" next to your desired exit node and download the file

Assuming you performed the above steps on your workstation, use SSH to copy the downloaded WireGuard configuration to your server. Here's how the command looked for me (using the Tailscale IP of the server):

```
scp ~/Downloads/protonvpn-US-FREE-874015.conf heywoodlh@100.107.253.121:/tmp/protonvpn.conf
```
Install WireGuard and dependencies on the server (skip these commands if you used the above startup script):

```
sudo apt update && sudo apt install -y wireguard resolvconf
sudo modprobe wireguard
```

Then, move the WireGuard config file for ProtonVPN that we copied earlier to the right location:

```
sudo mv /tmp/protonvpn.conf /etc/wireguard/protonvpn.conf
```

Now, enable the ProtonVPN WireGuard service on boot (don't start it yet):

```
sudo systemctl enable wg-quick@protonvpn.service
```

### Make Tailscale and WireGuard cooperate

> This Reddit post was extremely helpful: [How to change routing priority so that wireguard can coexist with tailscale](https://www.reddit.com/r/WireGuard/comments/n3nkk7/how_to_change_routing_priority_so_that_wireguard/)

Before we can bring Tailscale online, we have to edit the `tailscaled.service`. We can create an override with `sudo systemctl edit tailscaled.service`, and add the following content (after the first set of comments -- NOT after the line stating `Lines below this comment will be discarded`):

```
[Unit]
After = wg-quick@protonvpn.service

[Service]
ExecStartPost=/usr/bin/ip rule add pref 65 table 52
ExecStopPost=/usr/bin/ip rule del pref 65 table 52
```

Then reload systemd:

```
sudo systemctl daemon-reload
```

You HAVE to ensure that ProtonVPN comes online before Tailscale, as outlined in [this GitHub issue comment](https://github.com/tailscale/tailscale/issues/6772#issuecomment-1665642787), this one-liner should run all the commands needed to bring ProtonVPN up first (may be helpful to run this command in your VPS provider's console):

```
sudo wg-quick down protonvpn; sudo systemctl stop tailscaled.service; sudo wg-quick up protonvpn; sudo systemctl restart tailscaled.service
```

I would save the above command to ensure that you bring Tailscale + ProtonVPN in the right order when doing maintenance.

Now, ensure that your server is using ProtonVPN's public IP:

```
curl ipinfo.io
```

Before moving on, I would recommend rebooting your server and ensure that both Tailscale and WireGuard come up properly. I.E. you can SSH into your server using Tailscale, and that your server is using ProtonVPN's public IP.

## Profit

You now have a Tailscale exit node that's using ProtonVPN for accessing the public internet! Use the Tailscale app to select your server as an exit node.
