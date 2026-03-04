---
title: "Tremendously Stupid: Age-Verification Laws for Operating Systems in the United States"
published: true
permalink: /us-age-verification-laws/
tags: [ linux, privacy, macos ]
---

As a US citizen, self-identifying Linux and privacy enthusiast, and a human being I am very against all the proposed legislation in California and Colorado to enforce age verification on the operating system level. I wanted to share my perspective on the legislation as a contributor to NixOS.

## The legislation

Colorado legislation: [SB26-051 Age Attestation on Computing Devices](https://leg.colorado.gov/bills/SB26-051)

California legislation: [AB-1043 Age verification signals: software applications and online services](https://leginfo.legislature.ca.gov/faces/billTextClient.xhtml?bill_id=202520260AB1043)

The Colorado legislation is mostly the same as CA from what I’ve read so I’m just going to highlight the points for CA.

## "Operating system providers"

> "Operating system provider" means a person or entity that develops, licenses, or controls the operating system software on a computer, mobile device, or any other general purpose computing device.

With this definition, anyone who forks [nixpkgs](https://github.com/nixos/nixpkgs) could potentially fall under the category of "operating system developer" because that fork could be used as a source of truth to build NixOS. Clearly this bill did not have open source operating systems/development pipelines in mind. As implied by other users in this thread, I suspect the only real point of enforcement will be hardware vendors and their out-of-the-box operating systems.

### MacOS

While MacOS doesn't have anything rolled out yet, Apple will surely comply with this and bake it into MacOS. Perhaps this will enable Apple to go the route of Windows and force users on threat of death to login with an Apple account.

As a nixpkgs Darwin contributor, I'm sad about this, but am not surprised and will be exiting the Apple ecosystem even further.

## "Covered application stores"

> "Covered application store" means a publicly available internet website, software application, online service, or platform that distributes and facilitates the download of applications

So, in my view, nixpkgs probably falls into this “covered application store” category – but again, anyone can fork it, modify it, etc. – there’s no reasonable way to enforce this as literally anybody could fork nixpkgs, redistribute, modify, etc.

## Constraints/requirements

Ages they care about:

> (1) Whether a user is under 13 years of age.
>
> (2) Whether the user is at least 13 years of age and under 16 years of age.
>
> (3) Whether the user is at least 16 years of age and under 18 years of age.
>
> (4) Whether the user is at least 18 years of age.

Thee assertions they make for operating system providers:
1. Provide a way for a user to indicate their age bracket in the operating system
2. Provide a way for a developer to consume the age of bracket of the user
3. The operating system/app store must enforce restrictions around apps and age limits (I’m assuming not allowing users to install apps that are not appropriate relative to their age)

## Penalties

People – I’m guessing operating system developers – in violation of the title shall be subject to a fine:

> not more than two thousand five hundred dollars ($2,500) per affected child for each negligent violation or not more than seven thousand five hundred dollars ($7,500) per affected child for each intentional violation

## Due date in CA

> This title shall become operative on January 1, 2027.

## Specific Linux distributions discourse

Ubuntu: [On the unfortunate need for an "age verification" API for legal compliance reasons in some U.S. states](https://lists.ubuntu.com/archives/ubuntu-devel/2026-March/043510.html)

Pop! OS: [System76 Principal Engineer response](https://www.reddit.com/r/pop_os/comments/1rfqyf8/comment/o7q34wu/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button)

> Note: Pop! OS is made by System76, which is based out of Denver, Colorado -- therefore, they are uniquely impacted.

Arch Linux: [California Age verification craziness](https://bbs.archlinux.org/viewtopic.php?id=312459)

NixOS: [Compliance with U.S. age verification laws](https://discourse.nixos.org/t/compliance-with-u-s-age-verification-laws/75791)

Even if your preferred Linux distribution isn't based in the United States, this will surely have ripple effects with large corporations like Red Hat and Canonical contributing and maintaining much of the modern Linux applications and services that enable its widespread use.

## Why this is stupid

First, it violates privacy, and doesn't offer any meaningful protections for children. Applications greedy for user data will surely abuse the data about the verified ages of users (children and adults) on computers.

Second, open source operating systems can be forked by anybody and re-distributed. The legislation clearly isn't designed to scale with something like NixOS.

Third, there's no meaningful way to scale enough to actually enforce this for open source operating systems.

## What this means

In theory, this means that anybody distributing an operating system could be liable for this (i.e. [any one of the 18,000+ forks of nixpkgs on GitHub](github.com/NixOS/nixpkgs/forks)). In practice, I think this will be enforced against hardware vendors and the operating systems they bundle with brand new hardware.

But, as a US Citizen I consider this a big downgrade for my privacy.

## Misc

> I posted a less opinionated version of this on the NixOS Discourse post regarding this topic: [Compliance with U.S. age verification laws](https://discourse.nixos.org/t/compliance-with-u-s-age-verification-laws/75791/16?u=heywoodlh)

Obligatory note: none of my perspective represents my employer.
