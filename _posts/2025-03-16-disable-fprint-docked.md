---
title: "Disabling laptop fingerprint reader when clamshell on Linux"
published: true
permalink: /disable-fprint-clamshell-laptop/
tags: [ linux, nixos, fprint, fprintd, clamshell, laptop ]
---

This post will briefly outline my fix for Fprint trying to use the built-in fingerprint reader when the laptop lid is closed.

# Fprint + laptop fingerprint reader + clamshell on Linux's problem

I have multiple Linux laptops with built-in fingerprint readers that I use with Fprint to login via my fingerprint on Linux. Clamshell mode (having the laptop closed but still usable with an external display, keyboard, and trackpad) with Fprint presents a very annoying default behavior: if you use Fprint for `sudo` (i.e. in a terminal), it will prompt you for a fingerprint when the laptop is closed and will not time out for about 20 seconds. This is very annoying! Additionally, I use 1Password's system authentication option to be able to use my fingerprint to login to 1Password and it suffers from the same issue.

# Brief NixOS plug:

At the time of writing, I have a pull request opened in nixpkgs to fix this: [nixos/pam: option to disable fprint if laptop lid is closed](https://github.com/NixOS/nixpkgs/pull/342676)

This is what the implementation looks like for my X13: [nixos/hosts/x13/configuration.nix](https://github.com/heywoodlh/nixos-configs/blob/92b3c5357c98cb9427753fd0d72385aefe099dcf/nixos/hosts/x13/configuration.nix#L85-L91)

I won't cover in this post how to consume my branch in NixOS.

# Script to detect laptop lid state: lid.sh

One could use something like this script to detect the state of the laptop lid:

```
#!/usr/bin/env bash

lid_state="/proc/acpi/button/lid/LID/state"

# Exit with failure if lid is closed, else true
grep -q closed ${lid_state} && exit 1; true
```

# PAM configuration

Assuming `lid.sh` was placed at `/opt/scripts/lid.sh`, your PAM configuration `/etc/pam.d/sudo` might look like:

```
auth [success=ignore default=1] /usr/lib/aarch64-linux-gnu/security/pam_exec.so quiet /opt/scripts/lid.sh # fprintd-lid (order 11400)
```

This should be populated to each PAM configuration you'd like this to work.

For context/reference, here's the realized configuration of `/etc/pam.d/sudo` on my NixOS machine -- ignore the Nix store paths if you're unfamiliar with NixOS:

```
# Account management.
account required /nix/store/g928dngdfy30jyi1cs2m2a5wfimxgnkr-linux-pam-1.6.1/lib/security/pam_unix.so # unix (order 10900)

# Authentication management.
auth [success=ignore default=1] /nix/store/g928dngdfy30jyi1cs2m2a5wfimxgnkr-linux-pam-1.6.1/lib/security/pam_exec.so quiet /opt/scripts/lid.sh # fprintd-lid (order 11400)
auth sufficient /nix/store/7kjh2p1pzbibr9cj08kbczr4vzh3dyxv-fprintd-tod-1.90.9/lib/security/pam_fprintd.so # fprintd (order 11500)
auth sufficient /nix/store/g928dngdfy30jyi1cs2m2a5wfimxgnkr-linux-pam-1.6.1/lib/security/pam_unix.so likeauth try_first_pass # unix (order 11700)
auth required /nix/store/g928dngdfy30jyi1cs2m2a5wfimxgnkr-linux-pam-1.6.1/lib/security/pam_deny.so # deny (order 12500)

# Password management.
password sufficient /nix/store/g928dngdfy30jyi1cs2m2a5wfimxgnkr-linux-pam-1.6.1/lib/security/pam_unix.so nullok yescrypt # unix (order 10200)

# Session management.
session required /nix/store/g928dngdfy30jyi1cs2m2a5wfimxgnkr-linux-pam-1.6.1/lib/security/pam_env.so conffile=/etc/pam/environment readenv=0 # env (order 10100)
session required /nix/store/g928dngdfy30jyi1cs2m2a5wfimxgnkr-linux-pam-1.6.1/lib/security/pam_unix.so # unix (order 10200)
session required /nix/store/g928dngdfy30jyi1cs2m2a5wfimxgnkr-linux-pam-1.6.1/lib/security/pam_limits.so conf=/nix/store/wn252azs7hgq9q1m6k4jlwclclswgwrh-limits.conf # limits (order 12200)
```

# Conclusion

Using my `lid.sh` script in PAM to detect if your laptop lid is open should bypass your built-in fingerprint reader when your laptop lid is closed but will allow it when your lid is open.
