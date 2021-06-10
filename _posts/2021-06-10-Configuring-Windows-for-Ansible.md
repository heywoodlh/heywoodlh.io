---
title: 'Configuring Windows to Be Managed via Ansible'
layout: post
permalink: windows-ansible-setup
tags: all, ansible, windows, linux, macos, bash, automation, devops
---

This post will just quickly run through setting up a Windows host to be managed via Ansible.

## Windows Configuration:

First, you can configure remote Powershell on Windows for Ansible by using the Powershell script available at the official Ansible project Github repo:

```
Powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "iex ((new-object net.webclient).DownloadString('https://github.com/ansible/ansible/raw/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))"
```

Then use the following Powershell snippet to create the Ansible user:

```
## Modify these variables 
$username="ansible"
$password=""


$securePassword = ConvertTo-SecureString $password -AsPlainText -Force
$op = Get-LocalUser | Where-Object {$_.Name -eq $username}

if ( -not $op)
{
  New-LocalUser $username -Password $securePassword -FullName "Ansible Service Account" -Description "Account used by ansible." -UserMayNotChangePassword -PasswordNeverExpires
  Add-LocalGroupMember -Group "Administrators" -Member $username
  Remove-Variable username
  Remove-Variable password
  Remove-Variable securePassword
}
else
{
  echo "User $username already exists"
  Remove-Variable username
  Remove-Variable password
  Remove-Variable securePassword
  exit 0
}
```


## Ansible Host Configuration:

Install the `pywinrm` module on your Ansible host:

```bash
pip3 install --user pywinrm
```

If using INI for your Ansible inventory configuration, use something like the following in your config:

```bash
[windows]
mywindows-host.local

[windows:vars]
ansible_port=5986
ansible_connection=winrm
ansible_winrm_server_cert_validation=ignore
become_method=runas
become_user=ansible
```

If using YAML, use the following as an example:

```bash
windows:
  hosts:
    mywindows-host.local:
  vars:
    ansible_port: 5986
    ansible_connection: winrm
    ansible_winrm_server_cert_validation: ignore
    become_method: runas
    become_user: ansible
```

### MacOS Bug:

If your host is a MacOS machine, you'll run into a bug in `winrm` that outputs the following error: 

```bash
TASK [Gathering Facts] *********************************************************************************************************************************************************************
objc[27587]: +[__NSPlaceholderDate initialize] may have been in progress in another thread when fork() was called.
objc[27587]: +[__NSPlaceholderDate initialize] may have been in progress in another thread when fork() was called. We cannot safely call it or ignore it in the fork() child process. Crashing instead. Set a breakpoint on objc_initializeAfterForkError to debug.
```

Export the following variable in your shell to work around the issue:

```bash
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES
```

## Testing:

Run the following command to test your changes (assuming that your Ansible inventory is in a file named `inventory`):

```bash
ansible -i inventory windows -m win_ping --ask-pass
```

Which should return something like this:

```bash
SSH password:
mywindows-host.local | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```
