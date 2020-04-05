---
title: 'Setup OSQuery Packs on Kolide Fleet'
date: 2019-01-12
autotoc: true
excerpt: true
layout: post.html
collection: all, cybersecurity
---

Login to your Kolide Fleet instance using fleetctl:

```
fleetctl config set --address https://localhost:8080
fleetctl login
```




Download the osquery repository:

```
git clone https://github.com/facebook/osquery
```




Then use fleetctl to convert the packs and upload them to the server one at a time:

```
mkdir new-packs
fleetctl convert -f osquery/packs/osx-attacks.conf >> new-packs/osx-attacks.yaml
fleetctl apply -f ./new-packs/osx-attacks.yaml
```





Additional link: https://gist.github.com/marpaia/9e061f81fa60b2825f4b6bb8e0cd2c77
