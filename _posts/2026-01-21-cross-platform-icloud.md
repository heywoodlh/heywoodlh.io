---
title: "iCloud as a Cross-Platform Source of Truth (CalDav, CardDav)"
published: true
permalink: /cross-platform-icloud/
tags: [ carddav, caldav, apple, linux, ios, icloud, macos, email, imap, smtp, protonmail, proton ]
---

This is a summary of how to use iCloud for syncing contacts, calendars and reminders on non-Apple clients/platforms.

## TL;DR use these settings for CalDav/CardDav on iCloud

Remember to set up an [App-specific Password](https://support.apple.com/en-us/102654) for authentication.

- https://contacts.apple.com: Contacts
- https://caldav.icloud.com*: Calendar, Reminders

\* In order to use the same calendars/reminders on iOS and other platforms, you must configure an external CardDav/CalDav account for iCloud on iOS. The built-in iCloud Reminders/Calendar that is setup after logging into doesn't use traditional CalDav.

## Why use iCloud?

I recently switched away from an iPhone as my daily driver to GrapheneOS on a Pixel 8. However, I still have an iPad and switch regularly between Linux and MacOS when I'm on a workstation. So, I wanted to use iCloud due to Apple's (often overhyped) adherence to privacy but relying on endpoints that will work with clients that support CalDav and CardDav.

### As a long-time Proton user, why not use Proton?

\* Traditional CalDav and CardDav clients don't work with Proton.

Proton offers a variety of end-to-end encrypted cloud services rivaling iCloud. However, Proton isn't as portable since they break the protocols to ensure end-to-end encryption. While I think Proton is the superior suite of products from a privacy perspective, they are less functional for traditional protocols like CardDav and CalDav.

\* Check out [Ferroxide](https://github.com/acheong08/ferroxide) for a third-party, open source solution that exposes CalDav and CardDav endpoints that integrate with Proton.

## Platforms and clients I'm using

### Reminders, calendars

- Linux, MacOS: `vdirsyncer`, `todoman`
- Android: <tasks.org>, [DAVx⁵](https://www.davx5.com)
- iOS*: Native clients/settings

\* As stated in the first TL;DR in order for iOS to show the same reminders and calendars as the other platforms, you need to add an "external" CalDav account for iCloud since the built-in iCloud integration for Reminders and Calendars doesn't use the same CalDav endpoint.
### Contacts

- Linux, MacOS: `vdirsyncer`, `khard`
- Android: [DAVx⁵](https://www.davx5.com)
- iOS: Native clients/settings

## Android setup with DAVx⁵

I won't be going in-depth on Android setup, use the settings in the TL;DR at the beginning and use DAVx⁵'s wizard to set them up.

### Tasks.org integration

Use the following article to setup tasks.org with DAVx⁵: [tasks.org: DAVx⁵](https://tasks.org/docs/davx5.html)

## Linux/MacOS configuration

### Vdirsyncer configuration

Vdirsyncer is a tool for downloading CalDav and CardDav data locally.

Here is my configuration -- using 1Password's CLI for retrieving credentials -- at the time of writing:

```
[general]
status_path = "/home/heywoodlh/.config/vdirsyncer/status/"

## Calendar/Reminders

[pair icloud_calendar]
a = "apple_local"
b = "apple_remote"
collections = ["from b", "from a"]

[storage apple_local]
type = "filesystem"
path = "~/.todo/apple"
fileext = ".ics"

# Reminder, this is not the iOS-provided iCloud integration
# All devices (i.e. Apple devices) who want to see this should be using caldav
[storage apple_remote]
type = "caldav"
item_types = ["VTODO"]
url = "https://caldav.icloud.com"
username.fetch = ["shell", "op item get '<some-item>' --fields label=username --reveal"]
password.fetch = ["shell", "op item get '<some-item>' --fields label=app-password --reveal"]

## Contacts

[pair icloud_contacts]
a = "apple_remote_contacts"
b = "apple_local_contacts"
collections = [["icloud_contacts", "card", "main"]]
conflict_resolution = "a wins"
metadata = ["displayname"]

[storage apple_local_contacts]
type = "filesystem"
path = "~/.contacts/apple"
fileext = ".vcf"

[storage apple_remote_contacts]
type = "carddav"
url = "https://contacts.icloud.com"
username.fetch = ["shell", "op item get '<some-item>' --fields label=username --reveal"]
password.fetch = ["shell", "op item get '<some-item>' --fields label=app-password --reveal"]
```

Once Vdirsyncer is configured, run the following to download data:

```
vdirsyncer discover
vdirsyncer sync
```

### Khard configuration

Here is my khard configuration at the time of writing:

```
[addressbooks]
[[personal]]
path = ~/.contacts/apple/main
```

List all contacts with this command:

```
khard list
```

### Aerc configuration

```
[protonmail]
address-book-cmd = khard email -a personal --parsable --remove-first-line %s
aliases = Spencer Heywood <*@protonmail.com>,Spencer Heywood <*@pm.me>, Spencer Heywood <heywoodlh@heywoodlh.io>
copy-to = Sent
default = INBOX
from = Spencer Heywood <spencer@heywoodlh.io>
outgoing = smtp+insecure://<some-user>%40protonmail.com@protonmail-bridge:25
outgoing-cred-cmd = op read '<some-item>'
source = imap+insecure://<some-user>%40protonmail.com@protonmail-bridge:143
source-cred-cmd = op read '<some-item>'
```

I use Protonmail Bridge over Tailscale for SMTP+IMAP.

Here is my Kubernetes deployment for Protonmail Bridge at the time of writing: [protonmail-bridge.yaml](https://github.com/heywoodlh/nixos-configs/blob/38d871e19245b054d6812ed90ab53200d6be2916/flakes/kube/manifests/protonmail-bridge.yaml)
