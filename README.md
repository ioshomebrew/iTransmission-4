transmission-os
==========
This is a set of scripts to make it easier to cross-compile transmission for iOS and package it (mainly to use in Apple TV 2nd gen, but also works on iPod/iPhone/iPad as well).

Usage
-----

If you want to compile transmission yourself, check sections _Compiling_ and _Installation_.  
If you just want transmission running, you have two faster options:  

- install it through Cydia/nikoTV/apt-get as the package is online in the [BigBoss](http://apt.thebigboss.org/onepackage.php?bundleid=cc.fopina.transmission) repository.  

	if you're nikoTV-less apple tv 2g, simply do:

		ssh root@YOUR_APPLETV_IP
		apt-get update
		apt-get install cc.fopina.transmission

- [Download](https://github.com/fopina/transmission-ios/downloads) the .deb file and check the _Installation_ section.  


Compiling
-----

Using the terminal (assuming you have a working installation of XCode and git):  
clone this repository

	git clone git@github.com:fopina/transmission-ios.git
compile transmission and dependencies

	cd transmission-ios
	./build.sh
create the deb file

	./create_deb.sh

Installation
-----

copy it to jailbroken AppleTV 2G (or any other iOS device)

	scp transmission-VERSION.deb root@YOUR_DEVICE_IP
install it in the device

	ssh root@YOUR_DEVICE_IP
	dpkg -i transmission-VERSION.deb
	
It's done. The post installation script has set up transmission to run on boot and started it as well, so you can go straight ahead and connect to http://YOUR_DEVICE_IP:9091/ for the transmission WebUI.  
Personally, regarding Apple TV usage, I like to install the XBMC Transmission plugin as well.

Links
-------
[Transmission](http://www.transmissionbt.com/) - A Fast, Easy and Free BitTorrent Client
