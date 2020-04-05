---
title: 'Raspberry Pi GSM Phone Modem Setup'
layout: post.html
date: 2018-09-12
draft: false
---


Recently, I bought a GSM module for my Raspberry Pi to tinker around with GSM and learn more about how phones work on a lower level: [https://www.amazon.com/Raspberry-Bluetooth-Expansion-Compatible-DataTransfer/dp/B076CPX4NN](https://www.amazon.com/Raspberry-Bluetooth-Expansion-Compatible-DataTransfer/dp/B076CPX4NN)



Here are some notes to help fellow tinkerers as I found very little helpful information out there regarding how to interact with GSM modem using a Raspberry Pi.


### Helpful Resources:

[GSM/GPRS/GNSS Hat WaveShare Wiki](https://www.waveshare.com/wiki/GSM/GPRS/GNSS_HAT)




### Installation: 


<img src="/images/raspberry-pi-gsm.jpg" width="700" height="400">

Prior to installation, make sure your SIM card is activated and installed on the bottom side of the module.

Place the module on top of the Pi using the corresponding connector that goes with the pins similar to what is shown in the above photo.

That will be sufficient to supply a serial connection and power to the module from the Raspberry Pi. 

If you'd like to connect another host to the module, use the USB TO UART connection using the USB cable that was included with the module (the USB cable only has one possible connection it can plug into on the module).



### Connect the Modem to the Network and Connect Directly to the Modem:

I used a Ting GSM SIM card. In order to prep the SIM card, I merely needed to make sure it was activated prior to installing the module.

Per the wiki article, the CP2102 driver must be installed on the host that will connect to the SIM. Fortunately, this driver has been included in the Linux kernel since 2.6 and can be enabled with `sudo modprobe cp210x`. Check that the module has been enabled with `lsmod | grep 'cp210x'`.


After this, press the PWRKEY button on the module for one second (it hangs off the side and literally says "PWRKEY" on the module's board so it should be relatively easy to find). The NET indicator should start blinking about 1 time per second meaning that the module has not logged in to the GSM network. After it logs in successfully, the NET indicator should start blinking once every 3 seconds.


The modem on my external host connected via the USB to UART cable (running Arch Linux) was assigned the file `/dev/ttyUSB1` which I found by running `dmesg | grep tty`. I verified it was using the correct driver because the output stated `usb 1-11: cp210x converter now attached to ttyUSB1`. 

Again, the device file that came using the USB cable was `/dev/ttyUSB1`.

On the Pi that the SIM is connected to, the device file was `/dev/ttyAMA0` but I could not figure out how to serial into it or if I could. If you'd like to connect via Serial to the SIM, I would recommend just plugging in the USB cable from the Pi into the USB to UART connection on the module.



Retrieve the serial settings of the device using `stty`: 

`sudo stty -F /dev/ttyUSB1`



According to the Waveshare wiki the baud rate is 115200. Connect to the device using `screen`:


`sudo screen /dev/ttyUSB1 115200`

*Note, the PWRKEY button must be pressed after each reboot of the pi or module in order to connect to it. Just make sure the PWR light is solid red, the STA light is solid and the NET light flashes every three seconds.\*

Once connected to the GSM modem, you can check the status of the SIM using the `AT` command which should return `OK` if it is connected to a network. My SIM connected once I pressed the PWRKEY for one second so I did not need to troubleshoot connection issues.

Assuming all went well, the GSM modem should be suitable to send/receive texts, calls and data.




### Send and receive texts/calls:


I wrote some Python utilities to make this much simpler: [https://github.com/heywoodlh/pygsm](https://github.com/heywoodlh/pygsm). 


#### Download pygsm:

`git clone https://github.com/heywoodlh/pygsm`


#### Install dependencies:

`cd pygsm`
`sudo pip3 install -r requirements.txt`


#### Usage of `text.py`:

`text.py` has two main modes, `send` or `read`. `send` is for sending texts and `read` is for reading texts. `send` requires that the `-i` flag be pointing to the serial device (in this case as stated above, it is `/dev/ttyUSB1`), that the `-r` flag be pointing to the recipient's phone number (+1xxxxxxxxxx), and that the `-m` flag supplies the message that will be received (preferably in single or double quotes)..


General help message:


```
❯ ./text.py --help
usage: text.py [-h] {send,read} ...

Utility for dealing with texts over GSM via serial connection

positional arguments:
  {send,read}  send or read messages
    send       send text messages
    read       read text messages

optional arguments:
  -h, --help   show this help message and exit
```    
<br>
<br> 
<br>
 
`send` help message:



```
❯ ./text.py send --help
usage: text.py send [-h] -i TTY -r NUM [-m MES]

optional arguments:
  -h, --help            show this help message and exit
  -i TTY, --interface TTY
                        serial interface
  -r NUM, --recipient NUM
                        phone number to send to
  -m MES, --message MES
                        message contents
```    
<br>
<br>
<br>


`send` example:

`sudo ./text.py send -i /dev/ttyUSB1 -r +1xxxxxxxxxx -m 'Hey, what is up?'`



`read` only takes a single parameter: `-i` flag for the serial interface (`/dev/ttyUSB1`). At this time `read` only reads all text messages, it does not do anything more.


`read` help message:

```
❯ ./text.py read --help
usage: text.py read [-h] -i TTY

optional arguments:
  -h, --help            show this help message and exit
  -i TTY, --interface TTY
                        serial interface
```    
<br>
<br>
<br>
 
 

`read` example command:

```
❯ sudo ./text.py read -i /dev/ttyUSB0
+CMGL: 1,"REC READ","+1xxxxxxxxxx","","18/09/12,10:50:11-24"

This is my awesome text message!
```    
<br>
<br>
<br>
 

#### Usage of `call.py`:

`call.py` is for making and receiving phone calls. A headphone should be plugged into the Raspberry Pi module in order to actually use this. `call.py` has two modes: `make` (for making calls) and `receive` (for answering calls).


`call.py` help message:

```
❯ ./call.py --help
usage: call.py [-h] {make,receive} ...

Utility for dealing with calls over GSM via serial connection

positional arguments:
  {make,receive}  make or receive calls
    make          make phone call
    receive       answer incoming phone calls

optional arguments:
  -h, --help      show this help message and exit
```    
<br>
<br>
<br>
 
 

`make` requires two arguments: `-i` for the serial interface (`/dev/ttyUSB1`), `-r` for the number that will be called (+1xxxxxxxxxx).


`make` help message:

```
❯ ./call.py make --help
usage: call.py make [-h] -i TTY -r NUM

optional arguments:
  -h, --help            show this help message and exit
  -i TTY, --interface TTY
                        serial interface
  -r NUM, --recipient NUM
                        phone number to call
```    
<br>
<br>
<br>
 
 

`make` example command:

`❯ sudo ./call.py make -i /dev/ttyUSB0 -r +1xxxxxxxxxx`



As prompted on the screen, type 'end' (without quotes) to hang up the call.



Before going into the `receive` mode of `call.py`, enable calls to come through by running `enableCall.py`:

`sudo ./enableCall.py -i /dev/ttyUSB1`



`receive` allows you to answer incoming phone calls. It takes a single argument: `-i` for the serial interface (`/dev/ttyUSB1`). Obviously, it requires a phone call to be incoming in order to answer.


`receive` help message:

```
❯ sudo ./call.py receive --help
usage: call.py receive [-h] -i TTY

optional arguments:
  -h, --help            show this help message and exit
  -i TTY, --interface TTY
                        serial interface
```    
<br>
<br>
<br>
 
 

`receive` example command:

`sudo ./call.py receive -i /dev/ttyUSB1`




### Conclusion:

This Raspberry Pi GSM module is really fun. I enjoyed learning more about how GSM works throughout this project. I would definitely recommend others do the same. You really could turn your Raspberry Pi into a full-featured phone if you worked on it hard enough!
