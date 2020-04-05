---
title: 'Install Ansible Awx on Ubuntu'
date: 2019-02-01
autotoc: true
excerpt: true
layout: post.html
collection: all, linux
---


## Prerequisites:

1. Install Python and Python pip: 
    
    ```
    sudo apt-get install python python-pip
    ```




2. Docker (latest version) installed:

    ```
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add - 
    sudo add-apt-repository \
      "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) \
      stable"
    sudo apt-get update
    sudo apt-get install docker-ce docker-ce-cli containerd.io -y
    ```




3. Docker python module installed: 
    
    ```
    sudo pip install docker
    ```




4. Ansible (latest version) installed: 
    
    ```
    sudo apt-get update
    sudo apt-get install software-properties-common -y
    sudo apt-add-repository --yes --update ppa:ansible/ansible
    sudo apt-get install ansible -y
    ```






## Installation:

1. Download Ansible Awx
    
    ```
    cd /opt
    git clone https://github.com/ansible/awx
    cd awx/installer
    ```




2. Edit the following values in the "inventory" file and set them with any values desired – not the default -- especially the postgres_data_dir (I typically set postgres_data_dir to /opt/pgdocker/):

    ```
    host_port=80
    ...
    pg_username=awx
    pg_password=awxpass
    pg_database=awx
    pg_port=5432
    postgres_data_dir=/tmp/pgdocker
    ...
    rabbitmq_password=awxpass
    rabbitmq_erlang_cookie=cookiemonster
    ...
    admin_user=admin
    admin_password=password
    ...
    secret_key=awxsecret
    ```




3. Run the installer:

    ```
    ansible-playbook -i inventory install.yml
    ```



Once the `ansible-playbook` command completes, the install should be complete and the web interface should be accessible on the remote server on whatever port was specified in the inventory file in Step 2.
