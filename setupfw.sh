##################################################################################
#  Basic Linux Firewall - Setting up network.
#
#  setupfw.sh
#  
#  Author: Ian Lee    Luke Tao
#  Date: February 20, 2014
#
#  setting up network on standalone firewall machine.
#  Note: disable networking applet for p3p1 as it will overwrite 
#  any settings made with this script
#
##################################################################################

FIREWALL_IP="192.168.0.24"
EXTERNAL_SUBNET="192.168.0.0"
INTERNAL_INTERFACE="p3p1"
INTERNAL_SUBNET="192.168.10"
INTERNAL_BINDING="1"

ifconfig $INTERNAL_INTERFACE $INTERNAL_SUBNET.$INTERNAL_BINDING up
route add -net $INTERNAL_SUBNET.0 netmask 255.255.255.0 gw $INTERNAL_SUBNET.$INTERNAL_BINDING
echo "1" >/proc/sys/net/ipv4/ip_forward
route add -net $EXTERNAL_SUBNET netmask 255.255.255.0 gw $FIREWALL_IP


#
# after this run fw.sh to start the firewall
#
# if you want to have forwarding without the firewall running, you need to add prerouting rules to iptables
# 
# #add prerouting rule
# iptables -t nat -A POSTROUTING -o p3p1 -j MASQUERADE
#
# #allow forwarding packets through
# iptables -P FORWARD ACCEPT
