Program: fw.sh- basic personal firewall for linux
	Created by Ian Lee

Description: 
	These scripts were designed and created for Comp 8006 Assignment 1.
	It uses iptables to configure Netfilter as it's firewall implementation.

Listings:
	fw.sh		- run this to start the firewall
	rfw.sh		- run this to stop the firewall
	README.md	- this file


HOW-TO

To start up the firewall, enter:
	. fw.sh

To view the statistics of the firewall, enter:
	iptables -L -n -v -x

To zero out the statistices of the firewall, enter:
	iptables -Z

To turn off the firewall, enter:
	. rfw.sh




