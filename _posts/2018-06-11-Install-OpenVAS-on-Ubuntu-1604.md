---
title: 'Install OpenVAS on Ubuntu 16.04' 
date: 2018-06-11 
layout: post.html
collection: cybersecurity, linux, server, all
--- 

### What is OpenVAS? Why is Vulnerability Scanning Important? 
OpenVAS is an open source vulnerability scanner. Vulnerability scanning is important for any internet-connected company or entity so they can identify what devices on their network may be externally vulnerable. This article will provide a tutorial on how to install OpenVAS on Ubuntu 16.04 through the repository or through Docker. It will also provide a brief primer on basic usage of OpenVAS and also a brief explanation on how to manage it from Metasploit. 

Disclaimer: The content in this article should be used for legal purposes only. Written permission should be obtained prior to scanning anyone else's IP space.   

### Installing/Configuring OpenVAS on Ubuntu: 

#### Traditional Installation Install the PPA repository: 
```
sudo add-apt-repository ppa:mrazavi/openvas 
sudo apt-get update 
sudo apt-get install openvas
```
<br>
Now, enable each of the services to start on boot and then start the services: 
```
sudo systemctl enable openvas-scanner.service
sudo systemctl start openvas-scanner.service 
sudo systemctl enable openvas-manager.service 
sudo systemctl start openvas-manager.service 
sudo systemctl enable openvas-gsa.service
sudo systemctl start openvas-gsa.service 
```
<br>
Update the vulnerability database: 
`sudo openvas-nvt-sync`
<br>
#### Docker Installation: 

This will assume Docker has already been installed on the server. If you are planning on just using the web interface of OpenVAS, use this command to install OpenVAS after Docker has been installed (make sure to change the value of the PUBLIC_HOSTNAME and OV_PASSWORD environment variables): 

```
docker run -d -e PUBLIC_HOSTNAME=ip-or-hostname -e OV_PASSWORD=securepassword41 -p 443:443 --name openvas mikesplain/openvas
```
<br>
If you are planning on using Metasploit to interface with the server, use this command instead (make sure to change the value of the PUBLIC_HOSTNAME and OV_PASSWORD environment variables): 

```
docker run -d -e PUBLIC_HOSTNAME=ip-or-hostname -e OV_PASSWORD=securepassword41 -p 443:443 -p 9390:9390 --name openvas mikesplain/openvas 
```
<br>

For more information on the Docker installation, see the Dockerhub page for more details and options on deploying OpenVAS via Docker: https://hub.docker.com/r/mikesplain/openvas/. If you get an error "Login failed. Waiting for OMP service to become available" wait a little longer for the Docker instance to finish starting the OMP service. The NVT database should be up-to-date on the Docker instance, but if you'd like to update it manually, run these commands: 

```
docker exec -it openvas bash 
greenbone-nvt-sync openvasmd --rebuild --progress
greenbone-certdata-sync 
greenbone-scapdata-sync 
openvasmd --update --verbose --progress 
/etc/init.d/openvas-manager restart 
/etc/init.d/openvas-scanner restart
```
<br>


### Accessing OpenVAS from the web interface: 
Make sure that HTTPS traffic is allowed to your server. Go to https://ip-or-hostname. 
Default username: `admin` 
Default password: `admin` 
Change the password of the admin user at Administration > Users > Edit User.   

### Initiating a Vulnerability Scan: 
Go to Scans > Tasks and press the New Task button (the small star icon at the top left hand corner). Fill out the information as necessary. If you need to add targets to scan, make sure to add them into your assets.   

### Further Documentation: 

Visit http://www.openvas.net for more information regarding the OpenVAS project.
