---
layout: post.html
date: 2018-10-03
title: 'Running Wordpress in RancherOS'
collections: all, server, linux, docker
---


Rancher is an awesome service/operating system for managing Docker containers. In this post I will be using DigitalOcean as my infrastructure for running Rancher. This will be written shorthand mainly so I remember how to do this in the future.



### Deploying Rancher:

1. Create Droplet:

⋅⋅* Droplets > Create > Container Distributions > Rancher

⋅⋅* Size: 4G RAM, 2 vCPUs, 80GB SSD, 4 TB Transfer

⋅⋅* Additional Config

CREATE


2. Deploy Rancher Server (Web Dashboard):

⋅⋅* `sudo docker run -d --restart=unless-stopped -p 8080:8080 rancher/server`


3. Access Web Dashboard: http://<ip>:8080



### Add DigitalOcean Hosts: 


1. Obtain DigitalOcean API key:

⋅⋅* API > Tokens/Keys > Generate New Token

⋅⋅* Save the key somewhere secure


2. Add DO Hosts via Rancher:

⋅⋅* Infrastructure > Hosts > Add Hosts > Select the DigitalOcean Icon

⋅⋅* Enter your access token

⋅⋅* Enter all the configuration desired (do the defaults if unsure)



### Deploy Wordpress:

1. Deploy Wordpress stack:

⋅⋅* Stacks > All > Add from Catalog > Wordpress > View Details

⋅⋅* Enter all the configuration desired

LAUNCH


2. Configure Wordpress to use your domain name (skip this section and go to LetsEncrypt if planning to use LE for certificates):

⋅⋅* Stacks > Select your Wordpress stack > Select more options (the dots) corresponding with your wordpress-lb (load balancer) service

⋅⋅* Add a service rule for your domain name with the following configuration:

	Access: Public
	Protocol: HTTP
	Request Host: <your domain name>
	Port: 80
	Path: /
	Target: wordpress/wordpress
	Port: 80


### Install LetsEncrypt:

1. Deploy LetsEncrypt stack:

(Prior to configuring this, point a domain name to the public IP of the server you are running Wordpress on)

⋅⋅* Stacks > All > Add from Catalog > LetsEncrypt > View Details

⋅⋅* Enter the config desired

⋅⋅* Choose HTTP for the domain validation method if you cannot validate with the other methods

LAUNCH


2. Configure Wordpress to use the LetsEncrypt Stack:

⋅⋅* Stacks > Select your Wordpress stack > Select more options (the dots) corresponding with your wordpress-lb (load balancer) service 

⋅⋅* Add a service rule for your domain name with the following configuration:

	Access: Public
	Protocol: HTTP
	Request Host: <your domain name>
	Port: 80
	Path: /
	Target: wordpress/wordpress
	Port: 80
<br>


⋅⋅* Add a service rule for LE to verify if using HTTP for domain name verification with the following configuration:

	Access: Public
	Protocol: HTTP
	Request Host: <your domain name>
	Port: 80
	Path: /.well-known/acme-challenge
	Target: letsencrypt/letsencrypt
	Port: 80
<br>

⋅⋅* Add a service rule for your domain name with the following configuration:

	Access: Public
	Protocol: HTTPS
	Request Host: <your domain name>
	Port: 443
	Path: /
	Target: wordpress/wordpress
	Port: 80
<br>

	*At the bottom of the page, an SSL Termination Tab should have come up. Select the SSL certificate you created in Step 1 of this section.
