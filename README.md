iTransmission 4
==========
iTransmission, basically, is a torrent client, which uses libtransmission as it's backend.

So, what is iTransmission 4? iTransmission , originally, was developed by [ccp0101](https://github.com/ccp0101). It is no longer kept active. I plan on keeping iTransmision 4 active.~~, as well as building it for older devices (currently as old as iOS 4/iPT 2).~~

This is an extension to [ioshomebrew's](https://github.com/ioshomebrew) iTransmission 3, which is basically a torrent client for iOS, which I plan on keeping active and adding new features to as per my requirements and requests from you i.e. the user.
I've already added lots of stuff.

Compiling libraries
-----
~~You may wish to compile iTransmission libraries yourself~~

There is no longer a need to compile iTransmission libraries yourself. I've already done that for you. The libraries include armv7, armv7s and arm64. They are in Project/Libraries folder, in zip format.

Yet, if you still want to be adventurous, I have added the required files in a folder named 'Compilation'.

How to compile libraries
_____
Open terminal
cd to Compilation directory
./build.sh
If you need to change options, edit the configuration & build.sh file in Compilation directory. 

Compiling app
-----
Compiling may be a bit hard, and depends upon your target. I will cover the basics below. I assume that you are using Mac OS X and have XCode.
You can't compile the app without either of those. But, I've included a pre-compiled app. Use that with Installation Option I or II.

1. The app will never be accepted in the app store. Therefore, we do not need codesigning. But XCode requires us to codesign each and every app. Assuming I use the iOS 5.1 SDK, I can disable this check by opening /Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS5.1.sdk/SDKSettings.plist with a text editor (not XCode) and change the following values 

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

2. You may also want to change the minimum deployment target to your choice and the base SDK to your choice also.

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

Mail me if I missed somebody.