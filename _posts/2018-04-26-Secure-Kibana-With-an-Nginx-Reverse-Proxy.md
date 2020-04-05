---
title: 'Secure Kibana With an Nginx Reverse Proxy' 
date: 2018-04-26
layout: post.html
collection: cybersecurity, linux, server, all 
---
### Securing Kibana: 
Upon installing Kibana, initially there is no password protection on the page and it's being served via HTTP rather than HTTPS. Elastic has security plugins and features that can be used to remedy this but I found that using Nginx as a proxy to secure the page was the easiest solution for my needs. 
1. Generate a self-signed OpenSSL certificate: 
```
sudo openssl req -x509 -nodes -days 365 - newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt```
 
2. Install nginx: `sudo apt-get install nginx` 

3. Create an htpasswd file for nginx. Add the user to the file (replace 'myusername' with what you want the username to be): 
```
sudo sh -c "echo -n 'myusername:' >> /etc/nginx/.htpasswd"
``` 
<br>
Then create the user's password and append the encrypted value to the username: 
```
sudo sh -c "openssl passwd -apr1 >> /etc/nginx/.htpasswd"
```
<br>
This process can be repeated for as many users as you would like. If you would like to remove the users, remove their usernames/password entries from `/etc/nginx/.htpasswd`. 

4. Create the nginx configuration file: Below is an example configuration file stored at `/etc/nginx/sites-available/kibana`. Modify the `server_name` directive to point to your IP or hostname instead of 'myhostname': 

```
server { 
    listen 443 ssl; 
    server_name **myhostname**; 
    ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;
    ssl_certificate_key /etc/ssl/private/nginx-selfsigned.key; 

    location /{ 
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
<br>

If you would like to have https running on a port different than 443, modify the `listen 443 ssl;` directive and change 443 to a different value. You will have to change the 'server.host' directive in `/etc/kibana/kibana.yml` to point to `localhost` and then restart Kibana. Enable the nginx configuration using a symlink:
```
sudo ln -s /etc/nginx/sites-available/kibana /etc/nginx/sites-enabled/kibana 
```
<br>

5. Enable and restart nginx: 
```
sudo systemctl enable nginx.service 
sudo systemctl restart nginx.service 
```
<br>
Now Kibana will be accessible on port 443 of your server. All you need to do is go into a web browser and go to https://your-ip-or-hostname.com and it should be running. 

Once you have verified this is running, I would recommend changing the `server.host` directive in `/etc/kibana/kibana.yml` to point to `localhost` and then restart Kibana.
