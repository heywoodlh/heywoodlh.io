---
title: 'An Ubuntu Hardening Guide'
date: 2018-04-25
layout: post.html 
collection: cybersecurity, linux, server, all
--- 

This is a hardening guide for Ubuntu Server and Desktop. The same concepts can be applied to other distributions of Linux, although the steps would be a little different. This article will go over various tasks and examples for desktop and server users of Ubuntu to make their systems a lot more secure.

### Set a BIOS/Firmware/System Password: 
For greater physical security, setting a password on the firmware of your machine will drastically reduce the impact a bad actor will have if they have physical access to your machine or if it were stolen. Obviously, greater security is provided based on how complex the password is (length is better than complicated symbols in a password). However, setting any password at all is a huge step in the right direction. 
Based on the vendor and model of your machine, the steps will vary so I will refrain from going into detail on how to do this. Refer to your computer's vendor for further instructions on how to do this.

### Enable Disk Encryption During the Installation:
Disclaimer: Don't enable disk encryption on a server unless you plan on interfacing with it every time it reboots. Enabling encryption will require a password each time the machine boots up in order for it to run. Since servers are often administered remotely, it is often not feasible to enable disk encryption as you would need to be on site each time it reboots. For servers, the best way to prevent users from stealing your data would be to keep it physically secure. 
Enabling full disk encryption provides another layer of physical security to your machine. Encryption, in essence, will encode all the data on your hard drive and render it utterly useless until it is decrypted using the security key. During an installation of Ubuntu you can opt into having your entire disk encrypted and set a security key. For laptops this is especially useful as they are much more likely to be stolen.  
You don't have to check the box for LVM, but LVM is awesome and if you don't have a preference it probably won't hurt you to set up LVM.   
Make sure that the security key you set is strong but is something you can remember because if you forget it you will be unable to access anything on the operating system. You don't have to check the box for "Overwrite empty disk space" but if you have the time to do it this will ensure that the encryption is secure (it really will make the installation take much longer).

### Use Strong Passwords: 
This is your general reminder to use strong user account passwords. Length is way more important than complexity, but some added complex characters to a long password is a great practice. Don't re-use passwords either.  

### Be Picky with Software and Update:
For the average user, I would recommend installing software from the Ubuntu Software Center and updating each time that you are prompted to do so. If you have to install software from somewhere outside of the Software Center, make sure that it has some sort of update mechanism or that you update it on a regular basis by downloading newer versions as they come out.
For server users, you should get a prompt each time you login via SSH to the server to update. 
In order to update, use the following commands: 
```
sudo apt-get update 
sudo apt-get upgrade -y 
```

This will update all the software on the machine that was installed via `apt`. For kernel level upgrades, you will also need to run this command:
```
sudo apt-get dist-upgrade -y 
```
Kernel level upgrades will typically also require a reboot.  

### Enable Unattended Upgrades: 
In certain situations, unattended upgrades may be a desirable solution. You can enable unattended upgrades by installing the unattended-upgrades package: 
```
sudo apt-get update 
sudo apt-get install unattended-upgrades 
```
Then edit the appropriate configuration file: 
```
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades 
```

Paste the following code into the file in order to enable ONLY security updates: 
```
Unattended-Upgrade::Allowed-Origins { "${distro_id}:${distro_codename}";
"${distro_id}:${distro_codename}-security";
// "${distro_id}:${distro_codename}-updates";
// "${distro_id}:${distro_codename}-proposed"; 
// "${distro_id}:${distro_codename}-backports"; };
```

Remove the leading `//` on the type of updates you would like to automatically install. The leading `//` serve as comments so those lines won't be evaluated. For more information regarding unattended/automatic upgrades go to this link: https://help.ubuntu.com/lts/serverguide/automatic-updates.html.  

### Enable the Canonical Livepatch Service:
Canonical's livepatch service will patch the Linux kernel directly while the system is running without requiring a reboot. This will allow all updates to be applied without needing to reboot the system. Canonical allows a user with an Ubuntu One account up to three machines to be subscribed to the livepatch service. For more information and instructions on how to get started with the livepatch service go to this link: https://auth.livepatch.canonical.com/. 
 
### Enable Ubuntu's Simple Firewall UFW: 
Ubuntu has a nice little wrapper for the uber-powerful Linux iptables firewall called UFW. UFW is installed by default on newer Ubuntu systems. UFW is extremely user friendly in contrast to the complex command syntax of `iptables`.
For laptop/desktop users, you can manage UFW using the `gufw` program (installable via `apt-get` or the Software Center). For server users, you will want to make sure you allow SSH and any other services needed before enabling UFW as it will kill all incoming connections not relating to the rules you set up. Here are some UFW commands to use as examples: 

- Check UFW status: `sudo ufw status` 
- Allow TCP traffic on port 22 (SSH): `sudo ufw allow 22/tcp` 
- Allow TCP traffic on port 22 from IP address 192.168.1.100: `sudo ufw allow from 192.168.1.100 to any port 22` 
- Delete the above rule: `sudo ufw delete allow from 192.168.1.100 to any port 22` 
- Enable UFW: `sudo ufw enable`

### Install ClamAV: 
A common misconception is that Linux never gets viruses. Every system should have antivirus if possible. ClamAV is open source antivirus software for Unix systems.  

#### Desktop User Installation:
Desktop users can install ClamAV and ClamTK (a GUI for ClamAV) from the
Software Center. Once those are finished, ClamAV will immediately run the `freshclam` command to start updating ClamAV's virus signature database. It will need quite a bit of time the first time. So when you open ClamTK it will probably say that it has no virus signatures in its database. Once the `freshclam` command completes you can use ClamTK to manage scheduled scans.

#### Server User Installation:
For server users, you will have to install and manage ClamAV manually. Install ClamAV with these commands: 
```
sudo apt-get update 
sudo apt-get install clamav
```

Update the signature database using the `freshclam` command: 
```
sudo freshclam
```
Immediately after installing ClamAV the 'freshclam' command will automatically run so running the 'freshclam' command immediately after installing shouldn't work as the two processes would conflict. You can check if the process is running with this command: `sudo pgrep 'freshclam'`.
 
Once the process completes you should have a database with updated virus signatures that ClamAV will use. You can set up cronjobs for running the `freshclam` command at a certain time and for scanning specific directories with ClamAV. You will want to set up cronjobs using the 'crontab' command: `sudo crontab -e`.

Here are some example jobs that you could run:
```
#run freshclam every day at 1:00 a.m. 0 1 * * * freshclam
```
```
#scan the home directory of 'myuser' every day at 2:00 a.m. and save the paths to any found viruses to /var/log/clamav/myuser 

0 2 * * * clamscan -v -r /home/myuser/ | grep FOUND >> /var/log/clamav/myuser.log
```
```
#scan the Downloads directory of 'myuser' every day at 2:30 a.m. and remove any viruses found 
30 2 * * * clamscan -r --remove /home/myuser/Downloads 
```

These cronjobs will be a good starting point. However, the directories and users that should be scanned will vary.  


### Install OpenSnitch (Desktop Users):
As is the nature of a desktop environment, a lot more applications will be installed and running in the background than on a GUI-less environment like a server. On any laptop/desktop a good practice is to install an application firewall to monitor outgoing and incoming connections that are occuring due to applications running in the background. There are typically a lot more than you know about going on in the background. 

The application firewall I would recommend is OpenSnitch which is a fork of Little Snitch on OS X. This article outlines all the steps to install OpenSnitch: https://www.linuxuprising.com/2018/04/how-to-install-opensnitch-application.html 

I will include the steps as well from that article: 
1. Make sure you have the backports repository enabled if you're not using the latest Ubuntu version (18.04), by going to Software & Updates and checking the Unsupported updates (backports) option on the Updates tab.
2. Setup Go environment - Set up the GOPATH environment variable: 
```echo "export GOPATH=\$HOME/.go" >> ~/.bashrc; 
echo "export PATH=\$PATH:\$GOROOT/bin:\$GOPATH/bin:\$HOME/.local/bin:\$HOME/.bin" >> ~/.bashrc; source ~/.bashrc 
```
3. Install all OpenSnitch dependencies: `sudo apt-get install golang-go python3-pip python3-setuptools protobuf-compiler libpcap-dev libnetfilter-queue-dev python-pyqt5 git-core` 

4. Build OpenSnitch: 
```
go get github.com/golang/protobuf/protoc-gen-go 
go get -u github.com/golang/dep/cmd/dep 
go get github.com/evilsocket/opensnitch 
cd $GOPATH/src/github.com/evilsocket/opensnitch/daemon 
make 
sudo make install 
cd .. 
cd ui 
pip3 install --user -r requirements.txt 
sudo -H pip3 install . 
```

5. Add OpenSnitch to startup and start its services: 
```
mkdir -p ~/.config/autostart 
cp opensnitch_ui.desktop ~/.config/autostart/ 
sudo systemctl enable opensnitchd.service 
sudo systemctl start opensnitchd.service 
```

If for some reason, you would like to uninstall OpenSnitch refer to the uninstall steps in this article: https://www.linuxuprising.com/2018/04/how-to-install-opensnitch-application.html.  

### Securing SSH:
There are certain simple steps to mitigate a lot of potential attacks on SSH for instances of Ubuntu with SSH enabled. Remember to restart SSH after editing the `/etc/ssh/sshd_config` file: `sudo systemctl restart ssh.service` 

For laptop/desktop users, don't have the OpenSSH server running if you don't need it: There are very few reasons to have the SSH server enabled and running all the time on a laptop/desktop. So if you don't need it running disable it. At the very least, only turn the SSH server on when you need it and turn it off when it isn't being used. People can't attack the service if it isn't running in the first place. 

#### Change the port SSH runs on: 
In the SSH daemon configuration file `/etc/ssh/sshd_config` you can change the port that SSH runs on to not be the default port 22. Edit the `Port 22` directive in the SSH daemon config file to be another port. This one liner could be used to change the port quickly to port 53245 (change 53245 to whatever port you'd like): `sudo sed -i 's/Port 22/Port 53245/g' /etc/ssh/sshd_config`. Then restart the SSH service to save the change.

#### Disallow login to SSH using the 'root' user:
Every Unix system has a 'root' user. If that user is allowed to login via SSH, attackers have to guess one less credential to guess (a username). 
Disallowing the root user to login mitigates another attack vector. In `/etc/ssh/sshd_config` change the `PermitRootLogin` directive to `PermitRootLogin no`. By default it is normally `PermitRootLogin prohibit-password`, which is pretty secure because you would need to login with an SSH key (which normally hasn't been generated for the root user -- making it impossible to login). However, I would recommend just setting the directive to not allow root login at all anyway. Then restart the SSH service to save the change. 

#### Generate an SSH key and disable password-based login: 
In layman's terms, an SSH key is a randomly generated file that can be used to login to a system in substitution of or in conjunction with a password.
The possibility of somebody being able to guess a private SSH key is pretty close to impossible (at least right now), whereas a password will be much weaker and easier to guess. The way it works is that a private and public key need to be generated and authorized to login with. The contents of the public key is stored in the `~/.ssh/authorized_keys` file in the home directory of the user on the server.
If you want to SSH into that server as that user using an authorized key, the private key on the client logging in must correspond with the public key stored in '~/.ssh/authorized_keys' for that user you are logging in as on the server. My recommended workflow would be to generate the key on the client that will be connecting to the server and then upload the key to the server (that way the private key is not stored on the server at any point). On a Unix based system (Linux, MacOS X or BSD), an SSH key can be generated and uploaded using the following steps: 
```
ssh-keygen 
ssh-copy-id /path/to/id_rsa username@server
```
(If this is your first key generated and you used the default keygen path, the path will be ~/.ssh/id_rsa) I would recommend setting a passphrase on the key so that way a passphrase is required every time you want to use the SSH key on a client.
Linux and OS X have keychains in which the passphrase can be stored if you're too lazy to type in the passphrase each time you want to SSH in to a server.
Once the key has been copied over, try SSH-ing back into the server. If you weren't required to put in your password to login then it worked (if you set a passphrase on your SSH key you will have to enter that unless you store it in your keychain). Once key-based login is verified as working, disable password-based login in the `/etc/ssh/sshd_config` file. Edit the `#PasswordAuthentication yes` directive to equal `PasswordAuthentication no`. Then restart the SSH service to save the change. I would recommend that you keep the active SSH session running and then opening another terminal window on your client and trying to SSH in once again from that other window. If everything is working properly you should be able to login. If you are unable to login, something is incorrect and you'll want to undo the changes you made using the already existing SSH connection that you have open still. 

#### Make idle SSH connections timeout: 
Append the following two lines to `/etc/ssh/sshd_config` to make idle SSH connections after 5 minutes of inactivity:
```
ClientAliveInterval 300 
ClientAliveCountMax 0
``` 
Then restart the SSH service to save the change. 

#### Only allow users in a specific group to SSH in: 
I would recommend creating a separate group for SSH users that are permitted to login (or use the sudo group to only allow admins to login). 

To create a group called 'ssh_users' use this command: `sudo addgroup ssh_users`
To add a user to the group use this command: `sudo usermod -aG ssh_users username` 

Verify the user has been added to the group: `id username` 
Add the following line to `/etc/ssh/sshd_config` to only allow users in the newly created ssh_group to login:
`AllowGroups ssh_users` 
Then restart the SSH service to save the change. 

#### Set SSH up with two factor authentication: 
In certain cases this may not be desirable. But for the truly paranoid this will make SSH even more difficult to break into. I won't go into all the details on setting it up, but here is a great article to set up TOTP two factor authentication on SSH: https://www.digitalocean.com/community/tutorials/how-to-set-up-multi-factor-authentication-for-ssh-on-ubuntu-16-04.

#### Install fail2ban (Servers): 
Fail2ban is an intrusion detection tool that will mitigate brute force attacks. The installation is fairly simple: 
```
sudo apt-get update 
sudo apt-get install fail2ban 
```
If you need to configure fail2ban further, it's config files are stored in `/etc/fail2ban/`. T

his article has further reading on configuring fail2ban: https://www.digitalocean.com/community/tutorials/how-to-protect-ssh-with-fail2ban-on-ubuntu-14-04  

### Install OSSec (Servers): 
For any public facing server, OSSec would be a good idea to install. OSSec is another open source intrusion detection tool that is full of a lot of features. Here are the install steps: 
```
sudo su - 
git clone https://github.com/ossec/ossec-hids 
cd ossec-hids 
bash install.sh 
```
The install script is fairly user friendly so just walk through the steps and opt into which features you would like. I would recommend making the OSSec a "hybrid", meaning that it is an OSSec Server and has the agent installed as well. I would recommend going with the recommended responses to the questions asked by the installer script.


**** Additional Reading: ****
For one of the most comprehensive guides on securing Linux check https://www.stuartellis.name/articles/securing-linux/. For a guide specific to hardening an SSH server check https://devops.profitbricks.com/tutorials/secure-the-ssh-server-on-ubuntu/
