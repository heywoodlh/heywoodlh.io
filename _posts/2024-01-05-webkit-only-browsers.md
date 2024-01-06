---
title: "Using WebKit only Browsers (Apple, Linux)"
layout: post
published: true
permalink: webkit-only-browsers
tags: all, macos, ios, linux, webkit, safari, epiphany, gnome, web, vimb
---

I had the idea to see how far I can go with WebKit only browsers a few weeks ago when I saw a post about the [Orion Browser by Kagi](https://kagi.com/orion) pop up on HackerNews (I think it was this post: [https://news.ycombinator.com/item?id=38441139](https://news.ycombinator.com/item?id=38441139)). If Orion was available on Linux, I'd totally use it on Linux (assuming it wasn't Chromium-based and had support for extensions).

My phone is an iPhone, and since every browser on iOS is basically Safari, I have been using Safari exclusively on my phone and iPad for almost 3 years now (especially since Firefox and Chrome don't support extensions on i[Pad]OS). On MacOS and Linux, I've been a pretty loyal Firefox user for the past decade.

Despite being a happy Firefox user, I can't help but feel like Mozilla is going to keep making decisions that I don't care about and that those decisions will impact Firefox. Sometimes it feels like I'm a happy Firefox user _in spite_ of Mozilla. WebKit seems like the only alternative to the billions of Chromium-based browsers out there. And I have no interest in using a Chromium browser as Google seems even more ready to destroy the internet with ads lately: [ars technica: Chrome’s “Manifest V3” plan to limit ad-blocking extensions is delayed](https://arstechnica.com/gadgets/2022/12/chrome-delays-plan-to-limit-ad-blockers-new-timeline-coming-in-march/)

I likely won't completely get rid of Firefox, but it's been fun to distance myself from it for a bit on desktop in this experiment.

## Some background on WebKit

WebKit is an open source browser engine which powers Safari on Apple products. There are some other Apple-exclusive browsers (like Orion) out there powered by WebKit, but on Apple products I'm not super interested in anything outside of Safari when it comes to WebKit.

One interesting thing that I learned on this journey is that [Blink](https://en.wikipedia.org/wiki/Blink_(browser_engine)) -- Chromium/Chrome's browser engine -- is a fork of WebKit. It diverged in 2013 and is mostly unrelated to WebKit at this point. But that shared heritage is interesting (to me, at least).

On Linux, there are a small handful of WebKit-based browsers. The most notable is the default web browser that comes with GNOME: [GNOME Web a.k.a. Epiphany](https://apps.gnome.org/Epiphany/). I'll get into the ones I found interesting and what I've landed on using for now.

I'm somewhat minimal in my constraints for browsers, but I have the following preferences:
- Dark mode
- Vim keybindings
- Ad-blocking
- Ability to rewrite/redirect links to open source alternatives (i.e. YouTube links to my CloudTube instance)

## Using Safari on Apple products

On my Macs, iPhone and iPad, I'm just using Safari with the following extensions:
- [Vimlike](https://apps.apple.com/us/app/vimlike/id1584519802)
- [Dark Reader for Safari](https://darkreader.org/safari/)
- [AdGuard for Safari](https://adguard.com/en/adguard-safari/overview.html)
- [Redirect Web for Safari](https://mshibanami.github.io/redirect-web/#/)
- [1Password for Safari](https://apps.apple.com/us/app/1password-for-safari/id1569813296?mt=12)

There isn't much to dig into there, it's pretty straightforward as-is.

## Linux

The choices for WebKit browsers is extremely limited, and their features are even more limited. But there are two clear choices for me that I landed on. They are [GNOME Web a.k.a. Epiphany](https://apps.gnome.org/Epiphany/) and [Vimb](https://github.com/fanglingsu/vimb)

I basically use Vimb when I want Vim keybindings and GNOME Web when I want a stable experience. And Firefox when neither fit the bill fully.

### GNOME Web (Epiphany)

GNOME Web is a great default. It also recently-ish [got support for Web Extensions](https://blog.tingping.se/2022/06/29/WebExtensions-Epiphany.html). Web Extensions are extremely limited in their functionality, the only one on my list that worked for me was Firefox's Dark Reader extension -- and I was unable to configure it with a menu. Despite this, GNOME Web is fast and has a lot of nice features like easily installed web apps. For example, I "installed" the iCloud web app by hitting settings > Install as Web App.

I'm disappointed that more work hasn't gone into making extensions work. I think if extensions worked, GNOME Web would be _the_ perfect browser for me on Linux.

### Vimb

Vimb checks a lot of boxes for me as it has the following:
- built-in Vim keybindings
- dark mode
- ad blocking
- easy to create a Nix flake: https://github.com/heywoodlh/flakes/tree/main/vimb

However, I have found the following drawbacks that I've observed:
- Can be slow on pages with lots of links
- Hint mode can be pretty unreliable (i.e. click the wrong link)
- No tabs (not a huge drawback I found myself using two windows at a time and was pretty productive)

I likely will spend more time to address these drawbacks, but I haven't spent much time trying to fix these issues directly. Despite these issues, it seems like a fantastic browser for me.

## Things I like and dislike about WebKit browsers

Likes about WebKit browsers on MacOS and Linux:
- GNOME Web and Safari are defaults in their environments
- As defaults, they seem to be optimized
- Visually minimal

Dislikes compared to Firefox:
- Not very much control (check out all the tweaks I make to Firefox with Nix + Home Manager on MacOS and Linux here: [nixos-configs: roles/home-manager/firefox](https://github.com/heywoodlh/nixos-configs/tree/11016413a11d7d4142ad68f483a8e381684678b9/roles/home-manager/firefox))
- Ad-blocking is limited
- Linux features are even more limited

As I said earlier, I likely won't ever completely abandon Firefox, but it's still been fun to explore alternatives.

## BONUS: Anonymous browsing with Tailscale + Mullvad

On Apple devices, Apple provides a nice integration called Private Relay that routes your traffic through Cloudflare nodes. In essence, Private Relay is like a less anonymous but far faster Apple-ified Tor alternative. I used that on my iPhone almost exclusively since they announced that feature until around a few months ago. A gigantic downside to Private Relay is that it _only_ works with Safari. Which is pretty lame.

On Linux, my alternative to Private Relay for the last few years has been to forward traffic in my Tailnet to a server that points to [Mullvad's SOCKS proxy](https://mullvad.net/en/help/socks5-proxy). I do this with iptables on a NixOS server that's already logged into Mullvad -- you can see the NixOS configuration here: [heywoodlh/nixos-configs: nixos/hosts/nix-ext-net/configuration.nix (lines 34-71)](https://github.com/heywoodlh/nixos-configs/blob/11016413a11d7d4142ad68f483a8e381684678b9/nixos/hosts/nix-ext-net/configuration.nix#L34-L71)

Private relay and forwarding to Mullvad's SOCKS proxy has been solid for me, but I have since switched to a much easier solution: [using Mullvad via Tailscale](https://tailscale.com/mullvad) that allows me to tunnel all of my traffic on my machines through a Mullvad server. I like this solution better than Private Relay because it's cross-platform, so easy, and more private. Mullvad has a proven track record with privacy, and I can't help but feel skeptical about Apple's claims that privacy "is a human right".

I wanted to plug this because Tailscale's Mullvad integration has been transformative for me as an easy, portable solution for obfuscating all network traffic -- and it works on any operating system!
