---
title: "Running a Tiny SOCKS5 Proxy (in a container)"
layout: post
published: true
permalink: tiny-socks-proxy 
tags: [ linux, docker, socks, http ]
---

This is a super quick snippet on how to run a SOCKS 5 proxy in a container. 

The container image is [heywoodlh/microsocks](https://hub.docker.com/r/heywoodlh/microsocks) on Docker Hub. Dockerfile is here: https://github.com/heywoodlh/dockerfiles/blob/master/microsocks/Dockerfile

Here's how to run an unauthenticated SOCKS proxy on port 1080 with Docker: 

```
docker run -d --restart=unless-stopped --name=microsocks -p 1080:1080 heywoodlh/microsocks
```

More options are available and can be seen with MicroSocks' help page:

```
docker run -it --rm heywoodlh/microsocks --help
```

Another example using a username and password to restrict access:

```
docker run -d --restart=unless-stopped --name=microsocks -p 1080:1080 heywoodlh/microsocks -u user -P password
```


### Further Reading:

[MicroSocks' Repo](https://github.com/rofl0r/microsocks)

[MicroSocks' Repo README](https://github.com/rofl0r/microsocks/blob/master/README.md)
