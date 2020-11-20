---
title: 'Install Cloudtube (Open Source Youtube Front-End)'
layout: post
permalink: install-cloudtube
tags: all, linux, youtube, x86, arm
---

This article will outline the installation of the open-source Youtube front-end [Cloudtube](https://sr.ht/~cadence/tube/) by [Cadence](https://cadence.moe/) -- who also is the author of the open-source Instagram front-end called [Bibliogram](https://bibliogram.art/).

This allows you to watch Youtube with no ads and quite a bit more privacy.

Cloudtube is an alternative to [Invidious](https://invidious.site/), if you've heard of it.

Cloudtube consists of two different pieces of software:
- [Second](https://git.sr.ht/~cadence/Second)
- [Cloudtube](https://git.sr.ht/~cadence/cloudtube)

# Docker Installation:

## Second Installation:

Pull and run the [Second Docker image](https://hub.docker.com/r/heywoodlh/second):

```bash
docker pull heywoodlh/second:latest
docker run -d --name=second \
	--restart=unless-stopped --network=host \
	-e WEBSITE_ORIGIN="http://localhost:3000" \
	heywoodlh/second
```

Second should now be running on port 3000 of your host.

## Cloudtube Installaion

Create the directories where the database and config will live for Cloudtube:

```bash
mkdir -p /opt/cloudtube/db
mkdir -p /opt/cloudtube/config
```

Now create a config file in `/opt/cloudtube/config/config.js` with the following content:

```
module.exports = {
        user_settings: {
                instance: {
                        default: "http://localhost:3000"
                }
        }
}
```

Make sure the Cloudtube files are owned by the UID/GID of the user in the container image:

```
chown -R 1000:1000 /opt/cloudtube/
```

Pull and run the [Cloudtube Docker image](https://hub.docker.com/r/heywoodlh/cloudtube):
```
docker pull heywoodlh/cloudtube:latest
docker run -d --name=cloudtube \
	--user=1000 \
	--restart=unless-stopped --network=host \
	-v /opt/cloudtube/db:/opt/cloudtube/db \
	-v /opt/cloudtube/config:/opt/cloudtube/config \
	heywoodlh/cloudtube
```

Access the web interface for Cloudtube on port 10412 of your host, I.E. `http://server-name:10412`.


# Manual Installation (Debian-Based Instructions):

This installation should be performed as the root user and these commands assume you are on Debian, Ubuntu or one of their derivative distributions.

## Install Second:

### Install Python:

```bash
apt-get update
apt-get install -y python3 python3-pip
```

### Download Second and Install Dependencies:

```bash
git clone https://git.sr.ht/~cadence/Second /opt/Second
pip3 install -r /opt/Second/requirements.txt
```

### Configure Second:


```bash
cp /opt/Second/configuration.sample.py /opt/Second/configuration.py
```

Edit `configuration.py`, reading the comments for each configuration setting:

```
nano /opt/Second/configuration.py
```

### Install Second Systemd Service:

Create system user for systemd service to use:
```bash
useradd --system --no-create-home --shell=/sbin/nologin cloudtube
chown -R cloudtube /opt/Second
```

```bash
cat >> /etc/systemd/system/second.service<< EOF

[Unit]
Description=Second
 
[Service]
User=cloudtube
ExecStart=/usr/bin/python3 /opt/Second/index.py
WorkingDirectory=/opt/Second
 
[Install]
WantedBy=multi-user.target

EOF
```

Now start and enable the service to run on boot:

```bash
systemctl enable --now second.service
```


## Install Cloudtube:

### Install npm:

```bash
apt-get update
apt-get install -y npm
```

### Download Cloudtube:

```bash
git clone https://git.sr.ht/~cadence/cloudtube /opt/cloudtube
```

### Install Cloudtube Dependencies:

```bash
cd /opt/cloudtube
npm install
```

### Configure Cloudtube:

Create a config file in `/opt/cloudtube/config/config.js` with the following content:

```
module.exports = {
        user_settings: {
                instance: {
                        default: "http://localhost:3000"
                }
        }
}
```

Make sure the cloudtube user created earlier owns the files:

```
chown -R cloudtube /opt/cloudtube
```

### Install Cloudtube Systemd Service:

```bash
cat >> /etc/systemd/system/cloudtube.service<< EOF

[Unit]
Description=Cloudtube
 
[Service]
User=cloudtube
ExecStart=/usr/bin/npm start
WorkingDirectory=/opt/cloudtube
 
[Install]
WantedBy=multi-user.target

EOF
```

Now start and enable the service to run on boot:

```bash
systemctl enable --now cloudtube.service
```


Login to the web interface for Cloudtube on port 10412 on your server.
