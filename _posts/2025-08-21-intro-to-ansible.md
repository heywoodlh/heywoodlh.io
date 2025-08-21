---
title: "Introduction to Ansible (using Docker)"
published: true
permalink: /ansible-intro-docker/
tags: [ linux, ansible, devops ]
---

> This is a reposting of a meeting from the [Unix User Group I help run](https://culug.group)

# Getting Started with Ansible

This tutorial will walk you through some basic Ansible principles. All resources used in this tutorial can be found here:

<https://github.com/central-utah-lug/meetings/tree/main/2023/May/25>

By the end of the tutorial, you will use Ansible to deploy a server on DigitalOcean, do some basic maintenance on the server, and destroy the server.

## Requirements

Use my Docker container:

```
docker run -it --rm docker.io/heywoodlh/ansible-demo
```

In the Docker container, all of the playbooks in this post are located in the `/ansible-demo/playbooks` directory.

Additionally, the following packages are available in the container:
- `ansible`
- `doctl`
- `edit` ([Microsoft Edit](https://github.com/microsoft/edit))
- `nano`
- `vim` 

A DigitalOcean account:
* Create an API token with Read and Write permission to use for this tutorial (save it somewhere like a password manager): https://cloud.digitalocean.com/account/api/tokens

## Deploy a server with DigitalOcean's Ansible module

First, let's create a new directory and move into it for all of our commands:

```
mkdir -p /tmp/ansible-demo
cd /tmp/ansible-demo
```

Install the Ansible DigitalOcean collection, using `ansible-galaxy`:

```
ansible-galaxy collection install community.digitalocean
```

Before we can run any Ansible things against DigitalOcean's API, we need to set an API token environment variable for Ansible to use:

```
export DO_API_TOKEN="contents-of-api-token"
```

### Deploy the server

Now, create a file at `playbooks/create-server.yml` with the following commands:

{% raw %}
```
mkdir -p playbooks

cat >playbooks/create-server.yml <<EOL
---
- hosts: localhost
  tasks:

  - name: gather information about digitalocean ssh keys
    community.digitalocean.digital_ocean_sshkey_info:
    register: ssh_keys

  - name: set sshkey_pub_id when ansible-demo key exists
    set_fact:
      sshkey_pub_id: "{{ ssh_keys.data | selectattr('name', 'equalto', 'ansible-demo') | map(attribute='id') | first }}"
    ignore_errors: true

  - name: create ssh key without passphrase at /tmp/ansible-demo-id_rsa
    ansible.builtin.command: ssh-keygen -b 2048 -t rsa -f /tmp/ansible-demo-id_rsa -N ""
    when: sshkey_pub_id is not defined

  - name: read contents of /tmp/ansible-demo-id_rsa.pub
    ansible.builtin.command: cat /tmp/ansible-demo-id_rsa.pub
    register: sshkey_pub
    when: sshkey_pub_id is not defined

  - name: upload ssh key to digitalocean
    community.digitalocean.digital_ocean_sshkey:
      name: "ansible-demo"
      ssh_pub_key: "{{ sshkey_pub.stdout }}"
      state: present
    register: result
    when: sshkey_pub_id is not defined

  - name: set sshkey_pub_id when ansible-demo key exists
    set_fact:
      sshkey_pub_id: "{{ result.data.ssh_key.id }}"
    when: sshkey_pub_id is not defined

  - name: create a new digitalocean server
    community.digitalocean.digital_ocean_droplet:
      state: present
      name: ansible-demo
      size: s-1vcpu-1gb
      region: sfo3
      image: ubuntu-22-04-x64
      wait_timeout: 500
      ssh_keys: 
      - "{{ sshkey_pub_id }}" 
      unique_name: true
    register: my_droplet
EOL
```
{% endraw %}

Now, run the playbook:

```
ansible-playbook playbooks/create-server.yml
```

## Add the server to inventory

Ansible uses something called "inventory" to track remote servers that you want to run tasks against. Now that the server is created, let's create an inventory file manually (you can use Ansible to programmatically do this, but for the sake of learning, let's do it manually).

Create an inventory file named `hosts` with the IP of the demo server with the following one-liner:

```
echo "ansible-demo ansible_host=$(doctl --access-token="${DO_API_TOKEN}" compute droplet list | grep ansible-demo | awk '{print $3}') ansible_user=root ansible_ssh_private_key_file=/tmp/ansible-demo-id_rsa" | tee hosts
```

Now, we can run Ansible playbooks against the `ansible-demo` server!

Test connectivity to the `ansible-demo` server defined in the inventory with Ansible's ping module:

```
ansible ansible-demo -i hosts -m ping
```

## Some simple playbook examples to run against your host

We will now create some example playbooks to run against the new `ansible-demo` server in our Ansible inventory.

### Create a user

A common system administration task on remote servers is to manage users. So let's create a new user named `tempuser` with Ansible.

Create a file at `playbooks/adduser-tempuser.yml` with the following commands:

```
cat >playbooks/adduser-tempuser.yml <<EOL
---
- hosts: ansible-demo
  tasks:
  - name: create tempuser 
    ansible.builtin.user:
      name: tempuser
      uid: 1050
      shell: /bin/bash
  - name: create /home/tempuser/.ssh
    ansible.builtin.file:
      state: directory
      path: /home/tempuser/.ssh
      owner: tempuser
      mode: 0700
  - name: use previously generated ssh key as ~/.ssh/authorized_keys file for tempuser
    ansible.builtin.copy:
      src: /tmp/ansible-demo-id_rsa.pub
      dest: /home/tempuser/.ssh/authorized_keys
      owner: tempuser
      mode: 0600
EOL
```

Now, let's run the playbook, using the newly created `hosts` file as inventory:

```
ansible-playbook -i hosts playbooks/adduser-tempuser.yml
```

To ensure that this worked, let's use Ansible's `ping` module, but let's supply a different user this time.

First, let's supply an invalid user so we can see how it looks when this fails:

```
ansible ansible-demo -e "ansible_user=invalid-user" -i hosts -m ping
```

Now, let's try with the new `tempuser` user that we created earlier:

```
ansible ansible-demo -e "ansible_user=tempuser" -i hosts -m ping
```

### Install some packages

Another common systems administration task is to install packages. So, let's use Ansible to ensure the latest version of a couple of packages is installed for anyone on the `ansible-demo` system to use.

Before we install the packages, run this command to see if the packages currently exist on the system (replace `server-ip` with the public IP address of your server):

```
ansible ansible-demo -i hosts -m ansible.builtin.command -a "dpkg -l" | grep -E 'emacs|neofetch|python3-pip'
```

The command should return nothing, meaning that none of the packages we are about to install are currently installed on the `ansible-demo` system.

Create `playbooks/install-packages.yml` with the following command:

```
cat >playbooks/install-packages.yml <<EOL
---
- hosts: ansible-demo
  tasks:
  - name: install latest version of various packages with apt
    ansible.builtin.apt:
      update_cache: yes
      pkg:
      - emacs
      - neofetch
      - python3-pip
EOL
```

Now, run the playbook:

```
ansible-playbook -i hosts playbooks/install-packages.yml
```

To be sure that the packages were actually installed, let's run a command on the server to verify each of those packages exist:

```
ansible ansible-demo -i hosts -m ansible.builtin.command -a "dpkg -l" | grep -E 'emacs|neofetch|python3-pip'
```

## Destroy the server:

Create `destroy-server.yml` with the following content to remove the SSH key and server created in `create-server.yml`:

{% raw %}
```
cat >playbooks/destroy-server.yml <<EOL
---
- hosts: localhost
  tasks:

  - name: gather information about digitalocean ssh keys
    community.digitalocean.digital_ocean_sshkey_info:
    register: ssh_keys

  - name: set sshkey_pub_id when ansible-demo key exists
    set_fact:
      sshkey_pub_id: "{{ ssh_keys.data | selectattr('name', 'equalto', 'ansible-demo') | map(attribute='id') | first }}"
    ignore_errors: true

  - name: remove ssh key from digitalocean
    community.digitalocean.digital_ocean_sshkey:
      name: "ansible-demo"
      id: "{{ sshkey_pub_id }}"
      state: absent
    when: sshkey_pub_id is defined

  - name: destroy ansible-demo digitalocean server
    community.digitalocean.digital_ocean_droplet:
      state: absent
      name: ansible-demo
      wait_timeout: 500
      unique_name: true
EOL
```
{% endraw %}

Now, run the playbook:

```
ansible-playbook -i hosts playbooks/destroy-server.yml
```

Alternatively, these commands could be used to clean everything up with `doctl`:

```
doctl compute --access-token="${DO_API_TOKEN}" droplet delete $(doctl compute --access-token="${DO_API_TOKEN}" droplet list | grep ansible-demo | awk '{print $1}')
doctl compute --access-token="${DO_API_TOKEN}" ssh-key delete $(doctl compute --access-token="${DO_API_TOKEN}" ssh-key list | grep ansible-demo | awk '{print $1}')
```
