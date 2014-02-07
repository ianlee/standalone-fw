##################################################################################
#  Basic Linux Firewall
#  fw.sh
#  
#  Author: Ian Lee    Luke Tao
#  Date: February 20, 2014
#
#  Basic firewall using iptables program to configure Netfilter.
#  
#
##################################################################################


# USER DEFINES SECTION

#interface name
EXTERNAL="em1"
EXTERNAL_NETWORK="192.168.0.0/24"
INTERNAL="p3p1"
INTERNAL_NETWORK="192.168.10.0/24"
#Allowing ports(protocols)
TCP_ALLOW_PORTS_IN="22,80,443" #from these ports (acting as a client)
TCP_ALLOW_PORTS_OUT="22,80,443"
UDP_ALLOW_PORTS_IN="0"
UDP_ALLOW_PORTS_OUT="0"
TCP_ALLOW_PORTS_IN_SERVER="80,22" #acting as server (allow connections to these ports)
TCP_ALLOW_PORTS_OUT_SERVER="80,22"
UDP_ALLOW_PORTS_IN_SERVER="0"
UDP_ALLOW_PORTS_OUT_SERVER="0"

ICMP_ALLOW_TYPES=""


#block traffic to and from these IP addresses
IP_BLOCK=""
#block these ports regardless of IP or protocol.  
BLOCK_PORTS_IN="0"
BLOCK_PORTS_OUT="0"


# END OF USER DEFINES SECTION#####################################################

# DO NOT TOUCH BELOW unless you know what you are doing!!! #######################
#Allowing dns and dhcp ports.  you shouldn't touch these if you want your computer to work.
DNS_PORT_IN="53"
DNS_PORT_OUT="53"
DHCP_PORT_IN="67"
DHCP_PORT_OUT="68"

#empty all existing chains
iptables -F
#set policies to drop
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -P INPUT DROP

#Accounting rules for ssh, www, rest of traffic
iptables -N accounting
iptables -N wwwaccounting
iptables -N sshaccounting
iptables -N restaccounting
#not using interface so can be used for input and output 
iptables -A accounting -p tcp --sport 80 -j wwwaccounting
iptables -A accounting -p tcp --dport 80 -j wwwaccounting
iptables -A accounting -p tcp --sport 443 -j wwwaccounting
iptables -A accounting -p tcp --dport 443 -j wwwaccounting
iptables -A accounting -p tcp --sport 22 -j sshaccounting
iptables -A accounting -p tcp --dport 22 -j sshaccounting
#if part of expected traffic, exit from this chain so that only  the rest of traffic goes into the restaccounting chain
iptables -A accounting -p tcp --sport 80 -j RETURN
iptables -A accounting -p tcp --dport 80 -j RETURN
iptables -A accounting -p tcp --sport 443 -j RETURN
iptables -A accounting -p tcp --dport 443 -j RETURN
iptables -A accounting -p tcp --sport 22 -j RETURN
iptables -A accounting -p tcp --dport 22 -j RETURN
#only rest traffic should still be in this chain. send this to rest of traffic chain
iptables -A accounting -j restaccounting
#add accounting chain to default filter chains
iptables -A INPUT -j accounting
iptables -A FORWARD -j accounting
iptables -A OUTPUT -j accounting


#DNS AND DHCP TRAFFIC for firewall
iptables -N necessitiesin
iptables -A INPUT -j necessitiesin
iptables -N necessitiesout
iptables -A OUTPUT -j necessitiesout
iptables -A necessitiesin
#allow inbound dns and udp traffic
iptables -A necessitiesin -i $EXTERNAL -p udp -m multiport --sports $DNS_PORT_IN,$DHCP_PORT_IN -j ACCEPT
#iptables -A udpin -i $EXTERNAL -o $INTERNAL -p udp -m multiport --sports $DNS_PORT_IN,$DHCP_PORT_IN -j ACCEPT
#allow inbound dns and dhcp traffic
iptables -A necessitiesin -i $EXTERNAL -p tcp -m multiport --sports $DNS_PORT_IN,$DHCP_PORT_IN -j ACCEPT
#iptables -A tcpin -i $EXTERNAL -o $INTERNAL -p tcp -m multiport --sports $DNS_PORT_IN,$DHCP_PORT_IN -j ACCEPT
iptables -A necessitiesout
#allow outbound udp dns and dhcp traffic
iptables -A necessitiesout -o $EXTERNAL -p udp -m multiport --dports $DNS_PORT_OUT,$DHCP_PORT_OUT -j ACCEPT
#iptables -A udpout -o $EXTERNAL -i $INTERNAL -p udp -m multiport --dports $DNS_PORT_OUT,$DHCP_PORT_OUT -j ACCEPT
#allow outbound tcp dns and dhcp traffic
iptables -A necessitiesout -o $EXTERNAL -p tcp -m multiport --dports $DNS_PORT_OUT,$DHCP_PORT_OUT -j ACCEPT
#iptables -A tcpout -o $EXTERNAL -i $INTERNAL -p tcp -m multiport --dports $DNS_PORT_OUT,$DHCP_PORT_OUT -j ACCEPT


#chain for blocking Inbound traffic
iptables -N blockin
#block inbound traffic from specific IPs 
if [[ -n $IP_BLOCK ]]; then
iptables -A blockin -i $EXTERNAL -o $INTERNAL -s $IP_BLOCK -j DROP
fi
#block inbound traffic to and from specified ports
iptables -A blockin -i $EXTERNAL -o $INTERNAL -p udp -m multiport --sports $BLOCK_PORTS_IN -j DROP
iptables -A blockin -i $EXTERNAL -o $INTERNAL -p udp -m multiport --dports $BLOCK_PORTS_IN -j DROP
iptables -A blockin -i $EXTERNAL -o $INTERNAL -p tcp -m multiport --sports $BLOCK_PORTS_IN -j DROP
iptables -A blockin -i $EXTERNAL -o $INTERNAL -p tcp -m multiport --dports $BLOCK_PORTS_IN -j DROP
#drop SYN packets from ports less than 1024
iptables -A blockin -i $EXTERNAL -o $INTERNAL -p tcp -m multiport --sports 0:1023 -m state --state NEW -j DROP
iptables -A blockin -i $EXTERNAL -o $INTERNAL -p udp -m multiport --sports 0:1023 -m state --state NEW -j DROP

#add inbound blocking chain to input chain
iptables -A FORWARD -j blockin


#block outbound traffic from specific IPs
iptables -N blockout
if [[ -n $IP_BLOCK ]]; then
iptables -A blockout -o $EXTERNAL -i $INTERNAL -d $IP_BLOCK -j DROP
fi
#block out bound to and from specified ports
iptables -A blockout -o $EXTERNAL -i $INTERNAL -p udp --sport $BLOCK_PORTS_OUT -j DROP
iptables -A blockout -o $EXTERNAL -i $INTERNAL -p udp --dport $BLOCK_PORTS_OUT -j DROP
iptables -A blockout -o $EXTERNAL -i $INTERNAL -p tcp --sport $BLOCK_PORTS_OUT -j DROP
iptables -A blockout -o $EXTERNAL -i $INTERNAL -p tcp --dport $BLOCK_PORTS_OUT -j DROP
#drop SYN packets from ports less than 1024
iptables -A blockout -o $EXTERNAL -i $INTERNAL -p tcp -m multiport --sports 0:1023 -m state --state NEW -j DROP
iptables -A blockout -o $EXTERNAL -i $INTERNAL -p udp -m multiport --sports 0:1023 -m state --state NEW -j DROP
#add outbound blocking chain to output chain
iptables -A FORWARD -j blockout

#create udpin chain
iptables -N udpin

#allow inbound udp user defined traffic
iptables -A udpin -i $EXTERNAL -o $INTERNAL -p udp -m multiport --sports $UDP_ALLOW_PORTS_IN -m state --state ESTABLISHED -j ACCEPT # acting as a client
iptables -A udpin -i $EXTERNAL -o $INTERNAL -p udp -m multiport --dports $UDP_ALLOW_PORTS_IN_SERVER -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a server
#add inbound udp chain to default input chain
iptables -A FORWARD -p udp -j udpin


#create tcpin chain
iptables -N tcpin

#allow inbound user defined traffic
iptables -A tcpin -i $EXTERNAL -o $INTERNAL -p tcp -m multiport --sports $TCP_ALLOW_PORTS_IN -m state --state ESTABLISHED -j ACCEPT # acting as a client
iptables -A tcpin -i $EXTERNAL -o $INTERNAL -p tcp -m multiport --dports $TCP_ALLOW_PORTS_IN_SERVER -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a server
#add inbound tcp chain to default input chain
iptables -A FORWARD -p tcp -j tcpin


#create udpout chain
iptables -N udpout

#allow outbound udp user defined traffic
iptables -A udpout -o $EXTERNAL -i $INTERNAL -p udp -m multiport --dports $UDP_ALLOW_PORTS_OUT -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a client
iptables -A udpout -o $EXTERNAL -i $INTERNAL -p udp -m multiport --sports $UDP_ALLOW_PORTS_OUT_SERVER -m state --state ESTABLISHED -j ACCEPT # acting as a server
#add outbound udp chain to default output chain
iptables -A FORWARD -p udp -j udpout


#create tcpout chain
iptables -N tcpout
#allow outbound tcp user defined traffic
iptables -A tcpout -o $EXTERNAL -i $INTERNAL -p tcp -m multiport --dports $TCP_ALLOW_PORTS_OUT -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a client
iptables -A tcpout -o $EXTERNAL -i $INTERNAL -p tcp -m multiport --sports $TCP_ALLOW_PORTS_OUT_SERVER -m state --state ESTABLISHED -j ACCEPT # acting as a server
#add outbound tcp chain to default output chain
iptables -A FORWARD -p tcp -j tcpout



