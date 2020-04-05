---
title: 'Easily Install Filebeat on OS X' 
date: 2018-02-20
layout: post.html
collection: all, cybersecurity 
---

This is a quick snippet on how to install and configure Filebeat on OS X using Homebrew.


### Install Homebrew:

Brew's home page is located here: https://brew.sh/. The command to install brew is this: `/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"`


### Install and Configure Filebeat: 

Use this command to install Filebeat using Brew: brew install filebeat The filebeat configuration file is located at `/usr/local/etc/filebeat/filebeat.yml`.

Edit that file and make the necessary changes.

### Start Filebeat:
Once the desired changes to the configuration file have been made start the Filebeat service using brew services: `brew services start filebeat`
