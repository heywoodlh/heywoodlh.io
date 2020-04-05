---
title: 'Android Development Environment Setup'
slug: android-dev
date: 2020-01-02
autotoc: true
excerpt: true
layout: post.html
collection: all, android, linux, mobile, security
---

This article will walk through how I set up a development Android environment for testing Android exploits. In my setup I created two virtual Android devices and they are using a simulated GSM network which makes it possible for them to call and text one another.



### Download and Install Android Studio:

Android Studio is a development IDE provided by Google for developing on Android. It comes with an Android emulator which allows you to create fully functional, emulated Android devices. 

[Download Android Studio here.](https://developer.android.com/studio/)


I am on Fedora 31 at the time of this writing so I will walk through the installation process on Linux (these commands assume your user can run `sudo` commands):


1. Download the Linux 64 bit Android Studio tar.gz file: [https://developer.android.com/studio/#downloads](https://developer.android.com/studio/#downloads)

2. Extract the downloaded tar.gz file (and remove it once extracted):

```bash
tar xzvf ~/Downloads/android-studio-ide-*-linux.tar.gz && \ 
	rm ~/Downloads/android-studio-ide-*-linux.tar.gz
```
<br>

3. Move the extracted `android-studio` folder to `/opt/android-studio/` and change ownership to your user:

```bash
sudo mv ~/Downloads/android-studio /opt/android-studio/
sudo chown -R "$USER":"$USER" /opt/android-studio
```
<br>

4. Create a desktop entry for Android Studio:

```bash
printf "[Desktop Entry]\n\
Name=Android Studio\n\
Exec=/opt/android-studio/bin/studio.sh\n\
Icon=/opt/android-studio/bin/studio.png\n\
Type=Application\n\
StartupWMClass=jetbrains-studio\n" | sudo tee /usr/share/applications/android-studio.desktop
```
<br>



### Create Android Virtual Devices:

[https://developer.android.com/studio/run/managing-avds](https://developer.android.com/studio/run/managing-avds)

After opening Android Studio, open AVD Manager by going to Tools > AVD Manager.

Select the "Create Virtual Device +" button and go through the device creation Wizard. 

Select your desired emulated hardware. 
If this is your first time running through the Wizard, you will have to download a System Image. At the time of this writing, Android 10 (Q) is the newest major Android release, so I downloaded that image. Once the image is downloaded, hit Next and change any additional settings that are desired (such as the name of the device, etc.).

Once the device is created, start it up by hitting the play icon in the Actions setting of your virtual device to start it up.

Repeat the above process as often as desired for additional devices.




### Configure GSM Networking:

In order to configure telephony networking you have to issue emulator commands via the CLI. This article goes deeper into the process of connecting to the emulator CLI: 

[Start or stop a console session](https://developer.android.com/studio/run/emulator-console.html#console-session)

According to the article the window title on your desktop of the emulated Android device should contain the corresponding port for that device. I'm using GNOME as my desktop environment and I did not see any ports on the windows of my emulated Android devices.

The method I used for finding the console port of my Android devices was port scanning my local machine using Nmap.

The console ports are in the range of 5554 to 5585:
```
sudo  nmap -sS -p5554-5585 localhost
```
<br>

The output of my scan looked something like this:

```bash
$ sudo nmap -sS -p5554-5585 localhost
Starting Nmap 7.80 ( https://nmap.org ) at 2020-01-02 18:16 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.0000040s latency).
Other addresses for localhost (not scanned): ::1
Not shown: 28 closed ports
PORT     STATE SERVICE
5554/tcp open  sgi-esphttp
5555/tcp open  freeciv
5556/tcp open  freeciv
5557/tcp open  farenet
```
<br>

After connecting to the services, I figured out the ports were 5556 and 5554 for my Android devices.




#### Connect to the Emulator Console:

```bash
$ /usr/bin/telnet localhost 5556
Trying 127.0.0.1...
Connected to localhost.
Escape character is '^]'.
Android Console: Authentication required
Android Console: type 'auth <auth_token>' to authenticate
Android Console: you can find your <auth_token> in 
'/home/heywoodlh/.emulator_console_auth_token'
OK
```
<br>

As stated in the banner, you have to authenticate to the Android console. The path to the auth token is stated in the message. If using the default path, grab the auth token using this command in a separate terminal window:

```bash
cat ~/.emulator_console_auth_token
```
<br>

Then, going back to the telnet session, run the auth command:

```bash
auth [auth token]
Android Console: type 'help' for a list of commands
OK
```
<br>



#### Enable GSM Networking:

For more information on the telephony capabilities check out this link:

[Telephony emulation](https://developer.android.com/studio/run/emulator-console.html#telephony)

From the emulator console telnet session, you can now connect the Android device to a simulated GSM network using the following commands:

```bash
gsm data on
OK
gsm voice on
OK
```
<br>

Repeat that for each emulated Android device you'd like to connect to the GSM network.

The GSM network is _emulated_ so it's not actually connected to a real GSM network that you can make phone calls and texts to the outside world or real devices. However, you can make phone calls and text between other emulated Android devices on your computer.




### Calling and Texting Between Emulated Devices:

Now that the emulated GSM network is set up on multiple emulated Android devices, you can make phone calls or send text messages between them.

The console port for the device from earlier that you used to telnet into the emulator console with can be used as the phone number to start a text from.
For example, if the port was 5556 like it was for me I could submit that as my phone number when I initiate a text/phone call from another emulated Android device on my machine.

![alt text][console-number]

[console-number]: https://raw.githubusercontent.com/heywoodlh/the-empire.systems/master/resources/pictures/android-phone-number-console-port.png "Use the console port number as phone number"



Once you do that, a text will come from the full 9 digit phone number the devices can recognize and use. Save that number in contacts so you don't have to remember it. Repeat the process per device.


![alt text][android-text]

[android-text]: https://raw.githubusercontent.com/heywoodlh/the-empire.systems/master/resources/pictures/android-texts.jpg "Text between emulated Android devices"


![alt text][android-calls]

[android-calls]: https://raw.githubusercontent.com/heywoodlh/the-empire.systems/master/resources/pictures/android-calls.jpg "Make phone calls between emulated Android devices"
