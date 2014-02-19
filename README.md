Program: fw.sh- basic personal firewall for linux
	Created by Ian Lee and Luke Tao

Description: 
	These scripts were designed and created for Comp 8006 Assignment 2.
	It uses iptables to configure Netfilter as it's firewall implementation.

Listings:
	fw.sh		- run this to start the firewall
	rfw.sh		- run this to stop the firewall
	setupfw.sh	- run this to setup networking on stand-alone firewall computer
	setupint.sh	- run this to setup networking on internal computer
	testint.sh	- run this to test firewall from internal computer
	testext.sh	- run this to test firewall from external computer
	README.md	- this file


HOW-TO
Before starting the firewall, run the network configuration files on the relevant computers:
	On the stand-alone firewall computer, run:
		. setupfw.sh
	On the internal computer, run:
		. setupint.sh
	Note: the user defines may need to be changed depending on where you are running this firewall implementation

To start up the firewall, enter:
	. fw.sh

To configure the firewall:
	edit user defines section of fw.sh to your needs then run:
	. fw.sh
	
To view the statistics of the firewall:
	General:
		iptables -L -n -v -x
	NAT:
		iptables -L -n -v -x -t nat
	Mangled traffic
		iptables -L -n -v -x -mangle

To zero out the statistics of the firewall, enter:
	iptables -Z

To turn off the firewall, enter:
	. rfw.sh
	Note that this removes the SNAT rules as well so the internal computer will not have internet connection after this is run.



