---
title: "Kubernetes Resources"
layout: post
published: true
permalink: kubernetes
tags: [ kubernetes, learning ]
---

An not-comprehensive and biased list of Kubernetes resources that I have found useful

## Kubernetes distributions
- [k3s](https://k3s.io/)
- [RKE2](https://docs.rke2.io/)
- [k0s](https://k0sproject.io/)
- [Talos Linux](https://www.talos.dev/)

## Development clusters
- [Minikube](https://minikube.sigs.k8s.io/docs/): official tool for easily deploying test clusters 
- [kind](https://github.com/kubernetes-sigs/kind): Kubernetes in Docker
- [k3d](https://k3d.io): k3s in Docker
- [microk8s](https://microk8s.io/): Canonical's Kubernetes distribution packaged via Snap

## Tools/applications

### Command line
Note: most Kubernetes client tools on a machine reference the same config file at `$HOME/.kube/config`

- [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl): official Kubernetes command line client
- [k9s](https://k9scli.io/): terminal-based Kubernetes UI -- makes it much easier to quickly visualize what's in your cluster
- [helm](https://helm.sh/): ecosystem for easily distributing/consuming applications via Kubernetes
- [OpenTofu](https://opentofu.org/): open source fork of Terraform for deploying clusters (lots of tooling around deploying Kubernetes in various cloud providers with Terraform/OpenTofu)

### Management
- [Rancher](https://ranchermanager.docs.rancher.com/): suite of tools for easily managing Kubernetes deployments:
  - [Longhorn](https://www.rancher.com/index.php/products/longhorn): Kubernetes storage made easy

### Continuous Deployment tools for codifying K8s deployments:
- [ArgoCD](https://argo-cd.readthedocs.io/en/stable/)
- [FluxCD](https://fluxcd.io/)

### Development helpers
- [Microsoft's Kubernetes tools for VSCode](https://code.visualstudio.com/docs/azure/kubernetes)
- [VSCode YAML extension](https://marketplace.visualstudio.com/items?itemName=redhat.vscode-yaml)
- [ALE for Vim](https://github.com/dense-analysis/ale):
  - Specifically, YAML support: https://github.com/dense-analysis/ale/blob/master/supported-tools.md

### Misc
- [1Password Operator](https://github.com/1Password/onepassword-operator): manage secrets with 1Password 
- [Tailscale Operator](https://tailscale.com/kubernetes-operator): manage Kubernetes networking with Tailscale

## Learning resources/references
- [Kubernetes docs](https://kubernetes.io/docs/home/)
- [Learn Kubernetes Basics tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/)
- [Rancher Academy](https://www.rancher.academy/)

## Misc

My homelab Kubernetes deployments are templated with Nix here: https://github.com/heywoodlh/flakes/tree/main/kube

My GitHub Star Containers list: https://github.com/stars/heywoodlh/lists/containers
