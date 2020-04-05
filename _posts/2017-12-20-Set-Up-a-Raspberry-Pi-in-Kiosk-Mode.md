---
title: 'Set Up a Raspberry Pi in Kiosk Mode' 
date: 2017-12-20
collections: all
layout: post.html
---

Raspberry Pi's make super useful TV kiosks. Where I work, we prefer not to connect Smart-TVs to the network, instead we prefer managed Raspberry Pis. Typically, the staff just need the TV to display a single website. This article will walk through setting up a current version of Raspbian to run Chromium in Kiosk mode (current at the time of this writing).

#### Prerequisites: 

1. Raspbian must be installed on the RPI. 

2. The RPI must be configured to automatically connect to wifi or connect via ethernet. 

3. The RPI should be set to autologin to the pi user. 


 
### Install Dependencies:

Run this command to install unclutter: 

`sudo apt-get update; sudo apt-get install unclutter` 


Unclutter is a program that will prevent the cursor from displaying when it is idle.  



### Setting Up the Script:
 
Run this command to download the script: `wget 'https://gist.githubusercontent.com/heywoodlh/1997862f8948015d5d814f046f75271f/raw/f1c2a9de32df4845434c90ea546815293ede7039/kiosk.sh'` 


Make the script executable: `chmod +x kiosk.sh` 


Open the script and edit the `WEBSITE` variable: `nano kiosk.sh` 


Change this line of code: `WEBSITE='google.com'` to equal whatever website you would like Chromium to display when it boots.  



### Configure LXDE to Run the Script on Login:

LXDE is the desktop environment for Raspbian at the time of this writing. In order to configure it to run a script on login we need to edit the LXDE autostart file for the pi user: `nano /home/pi/.config/lxsession/LXDE-pi/autostart`. Assuming the kiosk.sh script is in `/home/pi/kiosk.sh`, this is the line you would add to the end of that autostart file: `@/home/pi/kiosk.sh`   

Now, if the pi user is set to autologin, Chromium will open fullscreen in kiosk mode and will display whatever website was configured in kiosk.sh.  



### Disable Sleep Mode: 

Edit this file: `sudo nano /boot/config.txt` 

Add this line to the end of the file: `hdmi_blanking=1` 

Edit the LXDE autostart file once again: `nano ~/.config/lxsession/LXDE-pi/autostart` 

Add these lines to the end of the file: 

```
@xset s 0 0 
@xset s noblank 
@xset s noexpose 
@xset dpms 0 0 0  
```



### Reboot: 

Reboot your machine: `sudo reboot` 


Assuming all was configured correctly the Pi will display the website of your choice using Chromium's kiosk mode and will not sleep.
