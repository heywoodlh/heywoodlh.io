---
title: "Aerc, Protonmail Bridge and Catch-all Addresses"
published: true
permalink: /aerc-protonmail-catch-all/
tags: [ email, imap, smtp, protonmail, proton ]
---

This is how I configured [Aerc](https://aerc-mail.org/), my email client, to work with Protonmail Bridge after I setup my custom domain with a catch-all address:

In `accounts.conf`

```
[protonmail]
from = Spencer Heywood <spencer@heywoodlh.io>
aliases = Spencer Heywood <*@protonmail.com>,Spencer Heywood <*@pm.me>
<snip>
```

This configuration will assume I want to use `spencer@heywoodlh.io` as my reply address (the default address for this custom domain) _unless_ the recipient of the email is my `protonmail.com` email address or my additional `pm.me` address. Alternatively, you could provide the full address of your Protonmail addresses in the `aliases` section.

This is required because Protonmail has an irritating limitation on sending addresses.

## BONUS

Aerc configuration at the time of writing: [home/base.nix#programs.aerc](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/home/base.nix#L464-L490)

My Protonmail Bridge Kubernetes deployment at the time of writing: [protonmail-bridge.yaml](https://github.com/heywoodlh/nixos-configs/blob/744934cdfdfa5d9b033a4f5092a5d263548f4b2a/flakes/kube/manifests/protonmail-bridge.yaml)
