---
title: "Tailscale ACL Gitops Policy Validation"
layout: post
published: true
permalink: tailscale-acl-gitops-validation
tags: [ tailscale, gitops, validation ]
---

As a happy Tailscale user, I've implemented a fairly robust ACL with role-based policies to secure my Tailnet. I've created a GitHub repository with a GitHub Action to automatically deploy my Tailscale config, as Tailscale's documentation describes: [GitOps for Tailscale ACLs](https://tailscale.com/blog/gitops-acls)
Using the GitOps approach for Tailscale ACL deployments allows me to edit my ACL with my preferred text editor Vim and the benefits of using Git for version control.

## The problem

A notable downside to using GitOps to deploy my Tailscale ACL is that the web-based ACL policy editor will give you real-time feedback if errors are introduced. The lack of feedback has resulted in multiple instances of me committing an ACL with syntax errors.

As a result, I filed this GitHub issue: [FR: Local Tailscale ACL policy linting/error detection](https://github.com/tailscale/tailscale/issues/10098)

## The solution

The Tailscale API has an endpoint for validating ACLs: [Validate and test policy file](https://github.com/tailscale/tailscale/blob/main/api.md#validate-and-test-policy-file)

I wrote a shell script named check.sh to implement this (and am using lefthook to prevent me from committing syntax errors to my ACL repo):

```
#!/usr/bin/env bash
root_dir="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
policy_file="$root_dir/policy.hujson"
token="SOMETOKEN"
tailnet="SOMETAILNET"

output=$(curl --silent https://api.tailscale.com/api/v2/tailnet/${tailnet}/acl/validate -u "${token}:" --data-binary "@${policy_file}")

if [[ ${output} == "{}" ]]
then
    echo "No issue detected in policy file"
else
    echo "Error detected"
    echo "${output}"
    exit 1
fi
```

This is my lefthook.yaml, which will check my policy file for syntax errors and prevent me from committing them:

```
pre-commit:
  commands:
    policy-check:
      run: |
        ./check.sh
```

And here's what the output looks like when I try to commit with an error in my ACL:

```
╭──────────────────────────────────────╮
│ 🥊 lefthook v1.5.5  hook: pre-commit │
╰──────────────────────────────────────╯
┃  policy-check ❯

Error detected
{"message":"line 719, column 5: invalid literal: invalidtext"}


  ────────────────────────────────────
summary: (done in 1.53 seconds)
🥊  policy-check
```

## Next steps

I'd like to implement some sort of integration with Vim to do checking of the ACL file whilst editing the policy.
