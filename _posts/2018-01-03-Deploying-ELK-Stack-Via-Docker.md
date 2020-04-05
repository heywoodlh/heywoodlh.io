---
title: 'Deploying ELK Stack Via Docker'
date: 2018-01-03
autotoc: true
excerpt: true
layout: post.html
collection: all, cybersecurity
---


ELK is a stack combining ElasticSearch,
Logstash and Kibana in order to provide greater visibility via logging. ELK
allows a user to quickly and effectively sort through logs. This article will
briefly outline the commands used to deploy ELK via Docker in order to simplify
the installation process.  

### Prerequisites: 
1. Docker must be installed on the machine that will be running the ELK Stack
2. The user that you will be using must be allowed to run the docker command
without sudo  

### Run ElasticSearch:
```
docker run -d -p 9200:9200 -p 9300:9300 -it -h elasticsearch --name elasticsearch elasticsearch
``` 
This will cause ElasticSearch to run on port 9200.
This can be tested by running this command on the server: `curl http://localhost:9200/` And the similar output will show that ElasticSearch is running:
```
{ "name" : "fCM5BQb", "cluster_name" : "elasticsearch", "cluster_uuid" :
"Hs9tY4RWQ9GTxoDlPAsq0g", "version" : { "number" : "5.6.5", "build_hash" :
"6a37571", "build_date" : "2017-12-04T07:50:10.466Z", "build_snapshot" : false,
"lucene_version" : "6.6.1" }, "tagline" : "You Know, for Search" }  
```

### Run Kibana: 
```
docker run -d -p 5601:5601 -h kibana --name kibana --link elasticsearch:elasticsearch kibana
``` 
This will run Kibana on port 5601 on the server, link it to the elasticsearch container and should be available at http://ip-address:5601/. You can make sure everything so far is working properly by visiting http://ip-address:5601/status.

### Securing Kibana:
Upon installing Kibana through Docker initially there is no password protection
on the page and it's being served via HTTP rather than HTTPS. Elastic has
security plugins and features that can be used to remedy this but I found that
using Nginx as a proxy to secure the page was the best solution for my needs.

1. Generate a self-signed OpenSSL certificate: `sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt` 
2. Install nginx: `sudo apt-get install nginx` 
3. Create a htpasswd file for nginx. 
4. Create the nginx configuration file: Below is a copy of my configuration file stored at `/etc/nginx/sites-enabled/kibana`: 
```
server { 
    listen 443 ssl; 
    server_name hostname; 
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt; 
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;

    location / { 
      proxy_pass http://localhost:5601; 
      proxy_set_header X-Real-IP $remote_addr; 
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; 
      proxy_set_header Host $http_host; 
      proxy_set_header X-NginX-Proxy true; 
      
      auth_basic "Restricted Content"; 
      auth_basic_user_file /etc/nginx/.htpasswd; 
      # Enables WS support 
      proxy_http_version 1.1; 
      proxy_set_header Upgrade $http_upgrade; 
      proxy_set_header Connection "upgrade"; 
      proxy_redirect off; 
    } 
}
``` 

5. Restart nginx: `sudo systemctl restart nginx.service` 

### Configure and Run Logstash:
In my configuration, I prefer to have a directory named 'logstash' in my user's home directory: `mkdir ~/logstash`. 
Then you would need to create a logstash.conf file within that folder: `nano ~/logstash/logstash.conf` 

Logstash configuration examples are available here: https://www.elastic.co/guide/en/logstash/current/config-examples.html. 

In my file I will use the following code for testing:
```
input { stdin {} } output { elasticsearch { hosts => ["elasticsearch:9200"] } }
```

You can now run Logstash and test it using this command: `docker run -h logstash --name logstash --link elasticsearch:elasticsearch -it --rm -v "$HOME"/logstash/:/config-dir logstash -f /config-dir/logstash.conf` 

Once the command is finished it should say this at the very end: 
```
[Api Webserver] INFO logstash.agent -
Successfully started Logstash API endpoint {:port=>9600}
```

And now you can type in a few test messages to see if they are being sent to ElasticSearch and are rendering in Kibana. Once you have verified Logstash is working properly you can kill it by hitting CTRL+C twice. Now in order to have other machines send their logs to the ELK stash we need to use a different configuration file in order to receive input over the network: 
```
rm ~/logstash/logstash.conf 
nano ~/logstash/logstash.conf 
```

Now you can paste this code into the new config file:
`input { tcp { port => 9500 } } output { elasticsearch { hosts => ["elasticsearch:9200"] } }` 

This will cause Logstash to listen on TCP port 9500, which will require you to have logs be sent over the network to the host via TCP port 9500. You can now run it in the background using this command: `docker run -d -p 9500:9500 -h logstash2 --name logstash2 --link elasticsearch:elasticsearch --rm -v "$HOME"/logstash/:/config-dir logstash -f /config-dir/logstash.conf` 


### Configuring a Linux Server to Send Logs via Filebeat to ELK:
In order to send logs from a Linux Server via Filebeat, we have to change the configuration for Logstash again: 
`nano ~/logstash/logstash.conf` 

Use this code:
`input { tcp { port => 9500 } beats { port => 5044 } } output { elasticsearch { hosts => ["elasticsearch:9200"] } }` 

Filebeat and any other beat configured will be listening on port 5044. Stop the Logstash docker container and then restart it with this command (note that this command has the additional port flag with 5044 being declared as the port): 
`docker run -d -p 9500:9500 -p 5044:5044 -h logstash --name logstash --link elasticsearch:elasticsearch --rm -v "$HOME"/logstash/:/config-dir logstash -f /config-dir/logstash.conf` 

The install process for Filebeat is here: https://www.elastic.co/guide/en/beats/filebeat/current/filebeat-installation.html. On the servers that will be forwarding logs install Filebeat. Once it is installed on the servers, edit `/etc/filebeat/filebeat.yml` on those servers: 
`sudo nano /etc/filebeat/filebeat.yml` 
Filebeat uses 'prospectors' in order to know what logs to send. Under prospectors, first change the `enabled: false` line to `enabled:true` and then configure the path to point to the logs you would like to save. By default Filebeat will send everything in `/var/log`. Change this line in the 'filebeat.prospectors' section to reflect the path or paths to logs you would like to send: 
`paths: - /var/log/*.log` 

For our purposes we will send auth logs and syslogs: 
```
paths: 
     - /var/log/auth.log 
     - /var/log/syslog
``` 

In the same file we will need to configure Filebeat to point to the logstash server. Under the section entitled 'Logstash output', we will make our changes. First, remove the comment before `output.logstash`. Then find the line specifying hosts, remove the comment and change it to the IP address followed by the port we will use (5044 for beats): 
```
hosts: ["ipaddress:5044"] 
```

For a better overview of what it should look like this is what should be changed in the 'Logstash output': 
```
#----------------------------- Logstash output -------------------------------
- output.logstash: 
  # The Logstash hosts 
  hosts: ["ipaddress:5044"] 
```

Save the file and then restart the service: 
`sudo systemctl restart filebeat.service` 

Filebeats shoud be attempting to send all of its logs to the logstash server now. This can be tested on the servers using this command: 
`filebeat -e -c /etc/filebeat/filebeat.yml -d "publish"` 

Assuming everything is configured properly it should publish to the Logstash server and the output should be available to search in the Kibana interface.
