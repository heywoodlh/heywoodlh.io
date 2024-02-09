---
title: "Simple Uptime Monitoring in Kubernetes"
layout: post
published: true
permalink: simple-k8s-uptime-monitoring
tags: all, linux, kubernetes, monitoring, alert, uptime
---

I will keep this brief: I have implemented uptime monitoring in Kubernetes and I don't know of any solution that's simpler.

There are two ingredients for this system:
1. [NTFY](https://ntfy.sh) for push notifications
2. My [bash-uptime](https://github.com/heywoodlh/bash-uptime) script/container

I will share my specs for them and assume both will run in the same cluster.

## NTFY

```
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: ntfy
  name: ntfy
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ntfy
  template:
    metadata:
      labels:
        app: ntfy
    spec:
      nodeSelector:
        kubernetes.io/hostname: nix-nvidia
      containers:
      - image: docker.io/binwiederhier/ntfy:v2.8.0
        name: ntfy
        command: ["ntfy"]
        args: ["serve", "--cache-file", "/var/cache/ntfy/cache.db"]
        ports:
        - name: ntfy
          containerPort: 80
        volumeMounts:
        - name: ntfy-cache
          mountPath: /var/cache/ntfy
        - name: ntfy-etc
          mountPath: /etc/ntfy
        env:
          - name: NTFY_BASE_URL
            value: "http://ntfy.barn-banana.ts.net"
          - name: NTFY_UPSTREAM_BASE_URL
            value: "https://ntfy.sh"
          - name: TZ
            value: "America/Denver"
      volumes:
      - name: ntfy-cache
        hostPath:
          path: /opt/ntfy/cache
          type: Directory
      - name: ntfy-etc
        hostPath:
          path: /opt/ntfy/etc
          type: Directory
---
apiVersion: v1
kind: Service
metadata:
  labels:
    app: ntfy
  name: ntfy
  namespace: default
  annotations:
    tailscale.com/expose: "true"
    tailscale.com/hostname: "ntfy"
    tailscale.com/tags: "tag:http"
spec:
  ports:
  - name: ntfy
    port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: ntfy
  type: ClusterIP
```

## bash-uptime

```
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: uptime-config
  namespace: monitoring
data:
  uptime.yaml: |
    global:
      track_status: true
      status_dir: "test"
    ping:
      hosts:
        - nix-backups
        - nix-drive
        - nix-m1-mac-mini
        - nix-precision
        - nixos-matrix
      options: "-c 1 -W 1"
      silent: "true"
    curl:
      urls:
        - "http://syncthing.syncthing"
        - "http://redlib.default"
        - "http://cloudtube.default"
        - "http://second.default"
        - "http://home-assistant.default"
      options: "-LI --silent"
      silent: "true"
---
apiVersion: batch/v1
kind: CronJob
metadata:
  name: uptime
  namespace: monitoring
spec:
  schedule: "*/5 * * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - image: docker.io/heywoodlh/bash-uptime:0.0.3
            name: uptime
            command:
            - "/bin/bash"
            - "-c"
            args:
            - "/app/uptime.sh | tee /tmp/uptime.log; grep DOWN /tmp/uptime.log | xargs -I {} curl -d \"{}\" http://ntfy.default/uptime-notifications"
            volumeMounts:
            - name: uptime-config
              mountPath: /app/uptime.yaml
              subPath: uptime.yaml
          restartPolicy: OnFailure
          volumes:
          - name: uptime-config
            configMap:
              name: uptime-config
              items:
              - key: uptime.yaml
                path: uptime.yaml
```

## Conclusion/more info

That's it!

If you want any additional information/reference on my cluster, feel free to check out my Nix-managed cluster configuration here: [heywoodlh/flakes](https://github.com/heywoodlh/flakes/tree/main/kube)
