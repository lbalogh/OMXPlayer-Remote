# OMXPlayer-Remote
Control OMXPlayer from iPhone and Apple Watch

## Prerequisites ##

* XCode 7.0 Beta 5
* This project uses https://github.com/willprice/python-omxplayer-wrapper to control OMXPlayer.

## Install ##

### On the Raspberry Pi ###

Install *python-omxplayer-wrapper* :

```
sudo apt-get install python-setuptools
git clone https://github.com/willprice/python-omxplayer-wrapper.git
cd python-omxplayer-wrapper
sudo python setup.py install
```

Get the server script :

```
wget https://raw.githubusercontent.com/lbalogh/OMXPlayer-Remote/master/OMXPlayerServer.py
```

And start it :

```
python OMXPlayerServer.py -a 192.168.10.109 -p 10026 -d /mnt/Downloads

-a : ip address of the Raspberry PI
-p : listening port
-d : home path when browsing from the phone
```

To make the server start automatically on boot, add this to *~/.config/autostart/omxplayer-remote.desktop* :

```
[Desktop Entry]
Encoding=UTF-8
Name=OMXPlayer Remote autostart
Exec=/usr/bin/lxterminal -e 'python /home/pi/OMXPlayerServer.py -a 192.168.10.109 -p 10026 -d /mnt/Downloads'
```

### On MacOS X ###

Open the *OMXPlayer Remote* project in XCode. On the toolbar, select *OMXPlayer Remote*, a destination device (eg. *iPhone 6*), then click *Play*. The app should start in the simulator.

Enter the ip/port specified in the server (*OMXPlayerServer.py*) and click *Browse* to browse the content of the Pi. Click on a movie to start playing.
