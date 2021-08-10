---
title: 'Simple Log Alerting with Systemd/Journald'
layout: post
published: true
permalink: systemd-alerting
tags: all, linux, security, logging, logs, log
---

This post provides a super simple example script for alerting using Systemd/Journald.

With this script using `journalctl`'s `--since` flag for `1 minutes ago`, I would recommend setting a cron job for every minute to run the script so as to not miss events: 

```bash
*/1 * * * * /path/to/sshd-alert.sh
```

Here's the script:

<script src="https://gist.github.com/heywoodlh/c8a53a6ce6527c8371cb29a6f2b56f58.js"></script>


With the `grep_regex_pattern` in the script, there will be an alert generated for every failed login as well as every successful login. Change as needed.
