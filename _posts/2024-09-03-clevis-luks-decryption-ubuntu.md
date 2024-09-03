---
title: "Automatically decrypt LUKS partitions with Clevis on Ubuntu 24.04"
published: true
permalink: /clevis-luks-decryption-ubuntu/
tags: [ linux, ubuntu, clevis, decryption, privacy, security ]
---

I am mostly putting it here for my own records, but here's the script I used to automatically decrypt LUKS partitions using TPM in Proxmox on an Ubuntu 24.04 VM:

{% gist b55eb33e248db2b8a7625c1fddc6b8d3 %}

Credit to [https://askubuntu.com/a/1475182](https://askubuntu.com/a/1475182) for the heavy lifting.
