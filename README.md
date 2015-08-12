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

Then, edit the server python script (*OMXPlayerServer.py*) and adapt the following variables :

```
HOME_PATH               = '/mnt/Download/Temp'  # home path when browsing from iPhone
HOST_NAME               = '192.168.10.116'      # ip adress of the raspberry pi
PORT                    = 10023                 # listening port
```

Finally, start the server :

```
python OMXPlayerServer.py
```

To make the server start automatically on boot, add this to *~/.config/autostart/omxplayer-remote.desktop* :

```
[Desktop Entry]
Encoding=UTF-8
Name=OMXPlayer Remote autostart
Exec=/usr/bin/lxterminal -e 'python /home/pi/OMXPlayerServer.py'
```

### On MacOS X ###

Open the *OMXPlayer Remote* project in XCode. On the toolbar, select *OMXPlayer Remote*, a destination device (eg. *iPhone 6*), then click *Play*. The app should start in the simulator.

Enter the ip/port specified in the server (*OMXPlayerServer.py*) and click *Browse* to browse the content of the Pi. Click on a movie to start playing.
