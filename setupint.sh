##################################################################################
#  Basic Linux Firewall - Setting up network.
#
#  setupfw.sh
#  
#  Author: Ian Lee    Luke Tao
#  Date: February 20, 2014
#
#  setting up network on internal machine
#  
#  Note: disable networking applet for p3p1 and em1 as it will overwrite 
#  any settings made with this script
#
##################################################################################

EXTERNAL_INTERFACE="em1"
INTERNAL_GATEWAY_BINDING="1"
INTERNAL_INTERFACE="p3p1"
INTERNAL_SUBNET="192.168.10"
INTERNAL_BINDING="2"

DOMAIN="ad.bcit.ca"
DNS_IP1=".39"
DNS_IP2=".38"

ifconfig $EXTERNAL_INTERFACE down 
ifconfig $INTERNAL_INTERFACE $INTERNAL_SUBNET.$INTERNAL_BINDING up 
route add default gw $INTERNAL_SUBNET.$INTERNAL_GATEWAY_BINDING

echo "domain $DOMAIN\nsearch $DOMAIN\nnameserver $DNS_IP1\nnameserver $DNS_IP2\n" >/etc/resolv.conf