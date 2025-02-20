---
title: "Hacks for dealing with open source burnout"
published: true
permalink: /open-source-burnout/
tags: [ linux, open-source, open, burnout, mental, health ]
---

I've been blessed with a career enabled by my enthusiasm for contributing to open source. While I've never held a job dedicated to contributing to open source professionally, my open source contributions have been a significant factor in obtaining _all_ of my senior technical roles -- specifically, [my GitHub account](https://github.com/heywoodlh) and [this blog](https://heywoodlh.io) have been talking points in most of my successful job interviews.

I've been thinking about strategies that have helped me maintain momentum in my open source contributions and think they may help any new or existing person in the realm of open source. This isn't as much a mental health post on how to avoid burnout, more of an unstructured list of hacks that have helped me over the years.

## Disclaimers

Some disclaimers feel necessary before proceeding to temper expectations.

I am not claiming to be a model of mental health or a significant figure in the open source space. As a married person, my career has taken a toll on myself and my marriage. At points I struggle with managing healthy boundaries around my career and I think it will always be something to calibrate. My strategies may not work for everyone. Maybe I'll publish this post and burnout the next day.

As with everyone on the internet, take my opinions and advice with a grain of salt and be confident that I know nothing. :)

## You should be your target audience

If you write anything open source, do it for yourself before anyone else. Do not expect that anyone will actually care about your contributions. Write for yourself in the moment, yourself in the past, or yourself in the future. Write code and documentation for yourself to reference. For example, I'm writing this post with myself as the target audience. If nobody reads this, it's an interesting thing _for me_ to process for myself and by itself that is a win. Additionally, reading a post like this when I first started working toward my career would have been really entertaining to me.

Another example: contribute to projects that _you_ use and implement features that _you_ need. Chances are, if you need it, someone else needs it! And if nobody else needs it, it can be a reference for yourself and a potential brag to a future employer.

As I have gotten older, I have noticed that people doing things for a long period of time -- no matter what it is -- is impressive by itself. If you write for yourself consistently, it will be a self-contained achievement and will likely be interesting to others on its own!

## Small contributions

It can be easy to get overwhelmed with all the grand contributions you anticipate making. Keep your scope small first and understand your own limits before you try to conquer the world.

Here are some examples of small contributions to start:
- Improve documentation on a tool you're using (even if it's only for you to read)
- Publish "Hello, world" projects as a reference for a language you're learning
- For larger projects, break it down into tons of tiny tasks and accomplish one task at a time

If your tasks remain small, you can be done with that task when you eventually run out of dopamine/excitement for the larger project and revisit after a break.

## Discoverability

I've found GitHub to be an incredible place for enabling the discovery of my own code for others as well as my own discovery of other projects. Most of my senior roles have used GitHub in some capacity, so it has been extra convenient to use.

An example demonstrating discoverability is my GitHub Stars list: [heywoodlh GitHub Stars](https://github.com/heywoodlh?tab=stars)

Many people don't like GitHub being "social media" -- which I can understand. For me, though, I've been able to find community with strangers interested in similar projects and it has helped employers easily parse how active I am with coding when they can look at my GitHub profile.

> Note: I think that GitHub alternatives like GitLab, SourceHut, Codeberg, etc. are absolutely incredible -- don't use GitHub if you prefer something else!

## Reducing tech debt

For someone hoping to contribute to open source, reducing tech debt drastically reduces excessive mental load.

### Tools

Many of the tools I use and my mentality around them are captured in this post:

[heywoodlh tech stack](https://heywoodlh.io/stack/)

Specifically around mitigating burnout, I implement the following which really helps:
- Avoid visual overstimulation
- Live in the command line -- a single pane of glass really helps me!
- Try to use keybindings to reduce mental overload and increase speed

### Offload technical overhead

One of the most impactful changes for reducing my open source load has been using external platforms for mission critical tooling. Nothing is more stressful than a self-induced outage that you have to fix that blocks you from getting meaningful work done.

Here are some things I've offloaded to an external service that's drastically reduced my stress:
1. Switching to [Tailscale](https://tailscale.com) away from self-hosted Wireguard
2. Using GitHub Actions for regularly scheduled actions I always need to run
3. Using _fly.io_ for network services that I need highly available
4. Publishing container images to Docker Hub instead of a private registry

I'm proud to report that with the above items, my homelab can go down with minimal impact to my immediate family (spouse and kids). But, I still (mostly) have as much control as I need.

### Self-documenting as a lifestyle

As a person with a DevOps career, I definitely have more passion than a normal person about utilizing self-documenting tools such as Nix, Terraform, etc. I won't belabor the point outside of saying: it helps to write projects you can read the code for to quickly understand what's happening.

For tools or projects that aren't inherently self-documenting by design, I try to write documentation for myself to read later when I'm working on a project because _I forget everything_. Documenting stuff sucks, but saves so much time when revisiting a project. At worst, too much documentation is not referenced -- but I've found it's usually difficult to ever come close to _too much_ documentation.

## Conclusion

I hope these tips help!
