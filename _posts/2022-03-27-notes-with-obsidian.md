---
title: "My Notes Setup using Obsidian"
layout: post
published: true
permalink: notes-with-obsidian 
tags: all, linux, obsidian, notes
---

## Why Obsidian:

A friend recommended [Obsidian Notes](https://obsidian.md) to me. It has a really nice design, a huge community plugin ecosystem and works with your local filesystem. Those last two points sold it for me as I can customize Obsidian the way I want with things like Vim keybindings AND I'm not locked into using Obsidian for my notes setup. I typically just stick to using `vim` but having something that can provide a nice front-end for me on mobile and let me sync while still having the flexibility to switch between `vim` or Obsidian itself is super nice.

I typically don't use closed-source applications for my workflows but after exploring a lot of the features and finding [Obsidian Livesync](https://github.com/vrtmrz/obsidian-livesync/) I knew I'd be good to go. Running Obsidian Livesync allows me to sync notes between devices (laptops, iPhone, iPad, etc.) using my own self-hosted server. So I get the benefits of an awesome application while keeping all my note data to myself and not having to spend $10/month on the [Obsidian Sync service](https://obsidian.md/sync).

Since I love the application I spent $25 on the [Catalyst plan](https://obsidian.md/pricing) to make sure I support development and keep the app around.

One of the main reasons I'm writing this post is to point people to resources if they want to self-host their own Livesync server. I personally found the Obsidian Livesync documentation to be a bit difficult and didn't find many blog posts on how to run it yourself.

### My Gripe:

I just wish the application was open source. That is the only gripe I have. Even if it was open source and I could build it myself I would absolutely pay for the application -- I try to donate to a lot of open source tooling I rely on.

## My Setup:

I have setup the [self-hostable Obsidian Livesync](https://github.com/vrtmrz/obsidian-livesync/) on a server that I access through Wireguard. Each of my devices with Obsidian installed have the Obsidian Livesync community plugin installed and are able to sync to each other. It's pretty cool to be able to watch my notes get synced live while I have the same note open on two different devices.

### Self-Hosted Obsidian Livesync:

Obsidian Livesync is just a CouchDB instance with some [required settings](https://github.com/vrtmrz/self-hosted-livesync-server/blob/main/conf/local.ini#L7-L20) to mitigate brute-force attempts against a public instance. I initially tried to just setup a CouchDB instance without those settings and _it does not work_ -- you have to have those settings in order for the plugin to connect to the CouchDB instance.

I won't go into super deep detail as the following repository has a nice `docker-compose.yml` that makes deployment of the Self-Hosted relatively painless if you are going to set it up on a publicly accessible VPS (for me, I don't feel comfortable exposing CouchDB to the world):

[Self-Hosted Livesync Server repo](https://github.com/vrtmrz/self-hosted-livesync-server).

I will, however, cover the differences in my deployment vs the expected setup for the above repository:
- I'm not running my configuration on a public-facing VPS -- I'm using plain HTTP over Wireguard to connect
- I'm running Obsidian Livesync within my Kubernetes cluster -- [here's the Helm chart](https://git.sr.ht/~heywoodlh/gitops/tree/a26371c54f177883b7723950d3cad8db9fcc6281/item/charts/obsidian-livesync)

Note: I set the [required CouchDB configuration in my Helm chart](https://git.sr.ht/~heywoodlh/gitops/tree/master/item/charts/obsidian-livesync/values.yaml#L18-36)

Using Wireguard allows me to access my Obsidian Livesync server remotely without exposing the service to the world and allows me to not have to deploy an HTTPS endpoint for the service as the Wireguard tunnel will be encrypting traffic between my Livesync server and my clients. 

## Conclusion:

Aside from some Vim keybindings plugins and the ability to self-host my livesync service I don't have very much that is custom for my Obsidian setup. I typically use `vim` while on my laptops to write notes within my Obsidian Vaults, use Obsidian Livesync to sync between devices and then I just use the Obsidian mobile app while on my iPad or iPhone.

It works great! I've been very pleased with the application and my syncing setup.

Feel free to reach out to me if you need advice on self-hosting your own Obsidian Livesync instance. I like emails (check out the mail icon in the footer of my website if you want to reach out). 
