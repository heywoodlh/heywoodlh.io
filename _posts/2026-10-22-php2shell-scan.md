---
title: "Scanning for PHP2Shell with Nuclei"
published: true
permalink: /php2shell-nuclei/
tags: [ security, vulnerability, php, php2shell, nuclei ]
---

[Nuclei by ProjectDiscovery](https://github.com/projectdiscovery/nuclei) added support for detecting PHP2Shell vulnerabilities: [github:projectdiscovery/nuclei-templates !17478](https://github.com/projectdiscovery/nuclei-templates/pull/17478)

> If you have Nix with flakes enabled, run the following to temporarily load Nuclei into your shell's `$PATH`: `nix shell nixpkgs#nuclei`

First, deploy a vulnerable WordPress container to test against:

```bash
docker run -d -it --name=vulnerable-wordpress --rm -p 127.0.0.1:9080:80 docker.io/wordpress:6.9.4-php8.4
```

Then run Nuclei against the vulnerable WordPress instance (the first run can take a few minutes):

```bash
curl --silent -L "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/http/cves/2026/CVE-2026-109618.yaml" -o /tmp/php2shell.yaml
nuclei -silent -t /tmp/php2shell.yaml -target http://localhost:9080
```

Profit:

```bash
❯ nuclei -silent -t /tmp/php2shell.yaml -target http://localhost:9080
[CVE-2026-109618:version-vulnerable-no-crash] [http] [critical] http://localhost:9080 ["8.4.21"]
```

# Ensure Scan Is Not False-Positive

Run the latest version of WordPress to ensure you're not dealing with a false-positive:

```bash
docker run -d -it --name=wordpress --rm -p 127.0.0.1:9180:80 docker.io/wordpress:php8.5-apache
```
And then re-scan

```bash
curl --silent -L "https://raw.githubusercontent.com/projectdiscovery/nuclei-templates/main/http/cves/2026/CVE-2026-109618.yaml" -o /tmp/php2shell.yaml
nuclei -v -t /tmp/php2shell.yaml -target http://localhost:9180
```

Output when no vulnerability is detected:

```
❯ nuclei -v -t /tmp/php2shell.yaml -target http://localhost:9180

<snip>

[INF] Targets loaded for current scan: 1
[VER] [CVE-2026-109618] Sent HTTP request to http://localhost:9180
[VER] [CVE-2026-109618] Sent HTTP request to http://localhost:9180
[INF] Scan completed in 156.940542ms. 0 matches found.
[INF] HTTP connections: 2 total, 2 new, 0 reused (0.0%)
[INF] HTTP connections [localhost:9180]: 2 total, 2 new, 0 reused (0.0%)
```

# Cleanup

```bash
rm /tmp/php2shell.yaml
docker rm -f wordpress vulnerable-wordpress
```
