---
title: 'Simple Log Alerting with Systemd/Journald'
layout: post
published: true
permalink: systemd-alerting
tags: [ linux, security, logging, logs, log ]
---

This post provides a super simple example script for alerting using Systemd/Journald.

With this script using `journalctl`'s `--since` flag for `1 minutes ago`, I would recommend setting a cron job for every minute to run the script so as to not miss events: 

```bash
*/1 * * * * /path/to/sshd-alert.sh
```

Here's the script:

```
#!/usr/bin/env bash
### Super simple systemd alerting

### Service name
service="sshd.service"

### Journalctl time frame (look at `man systemd.time` and `man journalctl`)
timeframe="1 minutes ago"

### Pattern to match with `grep -E ...`
grep_regex_pattern='Failed password|Invalid verification code|Invalid user|Accepted publickey|Accepted password'

### Command to pipe logs to if match
notify_command='ntfy send "${logs}"'



logs=$(journalctl -u ${service} --since "${timeframe}" | grep -iE "${grep_regex_pattern}")

if [[ -n ${logs} ]]
then
        eval "${notify_command}"
fi
```


With the `grep_regex_pattern` in the script, there will be an alert generated for every failed login as well as every successful login. Change as needed.
