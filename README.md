iTransmission 4
==========
iTransmission is a torrent client, which uses libtransmission as it's backend.

So, what is iTransmission 4? iTransmission , originally, was developed by [ccp0101](https://github.com/ccp0101). It is no longer kept active. I plan on keeping iTransmision 4 active.

How to compile libraries
-----
Open terminal
cd to Compilation directory
./build.sh
If you need to change options, edit the configuration & build.sh file in Compilation directory. 

Compiling app
-----
1. The app will never be accepted in the app store. Therefore, we do not need codesigning. But XCode requires us to codesign each and every app. Assuming you use the iOS 9.3 SDK, I can disable this check by opening /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS9.3.sdk/SDKSettings.plist with a text editor and change the following values 

```
<key>CODE_SIGNING_REQUIRED</key>
<string>YES</string>
```
to 
```
<key>CODE_SIGNING_REQUIRED</key>
<string>NO</string>
```


```
<key>ENTITLEMENTS_REQUIRED</key>
<string>YES</string>
```
to 
```
<key>ENTITLEMENTS_REQUIRED</key>
<string>NO</string>
```

Build Script
-----
**Cydia Package**

1. First you need to install macports
https://www.macports.org/install.php

2. Then you need to install dpkg
sudo port install dpkg

3. Then build the deb

Installation
-----
Installation is the easiest part.
You will need a jailbroken iDevice.

**OPTION I**

1. Put the compiled .app in the /Applications folder of your iDevice.
2. SSH into your device and execute the following command(without double-quotes):"cd /Applica*/iTransm*;chmod 777 ./iTransmission; cd ~/;"

**OPTION II**

1. Make a folder. Name doesn't matter, but using "iTransmission" here.
2. Open the folder.
3. Make a folder named "Payload". Name matters here.
4. Copy the compiled .app into the Payload folder.
5. Compress(Zip only) the iTransmission folder to iTransmission.zip
6. Rename iTransmission.zip to iTransmission.ipa

Credits
-------
- [Transmission](http://www.transmissionbt.com/)
- [ccp0101](https://github.com/ccp0101)
- [ioshomebrew](https://github.com/ioshomebrew)
- [fopino](https://github.com/fopino)
- [heavenly-awker](https://github.com/heavenly-awker)
- [Bilibili](https://github.com/Bilibili/ijkplayer)
- [Friend-LGA](https://github.com/Friend-LGA/LGSideMenuController)

Mail me if I missed somebody.
