---
title: 'Gotify iOS Notifications'
layout: post
published: true
permalink: gotify-ios-notifications
tags: all, linux, golang, go, gotify, push, notifications, pushover, ntfy
---

This will be a super brief post on how I am getting notifications from Gotify pushed over to my iOS device. I was on Android for a few months, switched back to iOS and was very disappointed to find there is no iOS Gotify app. So here is my solution to that problem.

This article is not going to cover setting up Gotify, I will assume that is done.

As I'm lazy, I'm going to assume you will be doing this all as the `root` user on your Linux machine.

## Cron:

### Dependencies:

My script example relies on the following being installed (and configured) on your server:
- `bash`
- `websocat`
- `jq`
- [`ntfy`](https://github.com/dschep/ntfy)

Switch out the dependencies for software you prefer on your Linux machine and modify your script to match that configuration.

In my setup I have configured `ntfy` to work with [Pushover](https://pushover.net) (Pushover is a one-time $5 fee on iOS) in `/root/.config/ntfy/ntfy.yml`:

```
---
backends:
  - pushover
pushover:
  user_key: <key>
```

Change Pushover to [your preferred service that works with ntfy](https://github.com/dschep/ntfy#backends).

### Script:

Place the following in `/opt/gotify-sync.sh`:

```
#!/usr/bin/env bash

token='xxxxxxxxxxxx'
uri='ws://192.168.1.10:8000/stream'

while read line
do
        ntfy send $(echo ${line} | jq -r '.message')
done < <(websocat -H "X-Gotify-Key: ${token}" -t "${uri}")
```

Make sure to modify the `token` and `uri` variables in the script to match your Gotify application token and the URI of your Gotify websocket.

Make it executable:

```
chmod u+x /opt/gotify-sync.sh
```

Since there's an API token in the file, let's also restrict the permissions so only `root` can access it.

```
chown root /opt/gotify-sync.sh
chmod 700 /opt/gotify-sync.sh
```

### Cron job:

Place the following in `crontab -e`:

```
@reboot screen -dmS gotify-sync /opt/gotify-sync.sh
```

Then reboot:

```
shutdown -r now
```

Check if `websocat` is running:

```
ps aux | grep websocat
```

Test to see if your notifications are syncing by running the Gotify CLI client (or just create a new message yourself):

```
gotify push testing
```

Assuming you configured `ntfy` to work with a backend that works on iOS you should get a push notification any time a new message goes to your Gotify server.
