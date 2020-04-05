---
title: 'Install LetsEncrypt Certificate on AWS Bitnami Instance'
date: 2018-08-14 
layout: post.html
collection: linux, server, all 
--- 
1. Install Certbot: https://certbot.eff.org/ 
2. Download LetsEncrypt Certificate for your domains: `sudo certbot certonly --webroot -w /opt/bitnami/apps/wordpress/htdocs/ -d **domain.com** -d **www.domain.com** --post-hook="/opt/bitnami/ctlscript.sh restart apache"` 
3. Edit `/opt/bitnami/apache2/conf/bitnami/bitnami.conf`: `sudo nano /opt/bitnami/apache2/conf/bitnami/bitnami.conf` 
   - Edit `SSLCertificateFile` to point to `/etc/letsencrypt/live/**domain.com**/fullchain.pem` 
   - Edit `SSLCertificateKeyFile` to point to `/etc/letsencrypt/live/**domain.com**/privkey.pem` 
4. Restart apache: `/opt/bitnami/ctlscript.sh restart apache`
