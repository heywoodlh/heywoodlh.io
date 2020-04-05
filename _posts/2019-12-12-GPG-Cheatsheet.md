---
title: 'GPG Cheatsheet'
slug: gpg-cheatsheet
date: 2019-12-12
autotoc: true
excerpt: true
layout: post.html
collection: all, security, privacy
---

```bash
## Generate keypair:
gpg --full-generate-key

## Export public key for email@domain.com to public_key.gpg file:
gpg --output public_key.gpg --armor --export email@domain.com

## Export private key for email@domain.com to private_key.gpg file:
gpg --output private_key.pgp --armor --export-secret-key email@domain.com

## List current keys in GPG keychain:
gpg --list-keys

## Upload public key:
gpg --keyserver pgp.mit.edu --send-key [key id]

## Search (and import, if desired) email@domain.com's public key on pgp.mit.edu:
gpg --keyserver pgp.mit.edu --search-keys email@domain.com

## Encrypt file.txt for email@domain.com (after their key has been imported to your GPG keychain):
gpg --recipient email@domain.com --encrypt file.txt

## Decrypt file.gpg to file.txt:
gpg --decrypt file.gpg > file.txt

```
