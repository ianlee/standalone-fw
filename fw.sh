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
UDP_ALLOW_PORTS_IN="80"
UDP_ALLOW_PORTS_OUT="80"

#internal server ip
INTERNAL_SERVER_IP="192.168.10.2"
TCP_ALLOW_PORTS_IN_SERVER="80,22,443" #acting as server (allow connections to these ports)
TCP_ALLOW_PORTS_OUT_SERVER="80,22,443"
UDP_ALLOW_PORTS_IN_SERVER="80"
UDP_ALLOW_PORTS_OUT_SERVER="80"

ICMP_ALLOW_TYPES="0,8"


#block traffic to and from these IP addresses
IP_BLOCK=""
#block these ports regardless of IP or protocol.  
BLOCK_PORTS_IN="0,23"
BLOCK_PORTS_OUT="0,23"

MAXIMIZE_THROUGHPUT="20"
MINIMIZE_DELAY="21,22"


# END OF USER DEFINES SECTION#####################################################

# DO NOT TOUCH BELOW unless you know what you are doing!!! #######################
#################################################################################
#Allowing dns and dhcp ports.  you shouldn't touch these if you want your computer to work.
DNS_PORT_IN="53"
DNS_PORT_OUT="53"
DHCP_PORT_IN="67"
DHCP_PORT_OUT="68"

#empty all existing chains
iptables -t filter -F
iptables -t mangle -F
iptables -t nat -F

#set policies to drop
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -P INPUT DROP

#Accounting rules for ssh, www, rest of traffic
#iptables -N accounting
#iptables -N accountingwww
#iptables -N accountingssh
#iptables -N accountingrest
#not using interface so can be used for input and output 
#iptables -A accounting -p tcp --sport 80 -j accountingwww
#iptables -A accounting -p tcp --dport 80 -j accountingwww
#iptables -A accounting -p tcp --sport 443 -j accountingwww
#iptables -A accounting -p tcp --dport 443 -j accountingwww
#iptables -A accounting -p tcp --sport 22 -j accountingssh
#iptables -A accounting -p tcp --dport 22 -j accountingssh
#if part of expected traffic, exit from this chain so that only  the rest of traffic goes into the accountingrest chain
#iptables -A accounting -p tcp --sport 80 -j RETURN
#iptables -A accounting -p tcp --dport 80 -j RETURN
#iptables -A accounting -p tcp --sport 443 -j RETURN
#iptables -A accounting -p tcp --dport 443 -j RETURN
#iptables -A accounting -p tcp --sport 22 -j RETURN
#iptables -A accounting -p tcp --dport 22 -j RETURN
#only rest traffic should still be in this chain. send this to rest of traffic chain
#iptables -A accounting -j accountingrest
#add accounting chain to default filter chains
#iptables -A INPUT -j accounting
#iptables -A FORWARD -j accounting
#iptables -A OUTPUT -j accounting

#SNAT
iptables -t nat -A POSTROUTING -o $EXTERNAL -j MASQUERADE
#DNAT
iptables -t nat -A PREROUTING -i $EXTERNAL -p tcp -m multiport --dports $TCP_ALLOW_PORTS_IN_SERVER -j DNAT --to $INTERNAL_SERVER_IP
iptables -t nat -A PREROUTING -i $EXTERNAL -p udp -m multiport --dports $UDP_ALLOW_PORTS_IN_SERVER -j DNAT --to $INTERNAL_SERVER_IP

arr=$(echo $ICMP_ALLOW_TYPES | tr "," "\n")
for x in $arr
do
    iptables -t nat -A PREROUTING -i $EXTERNAL -p icmp --icmp-type $x -m state --state NEW,ESTABLISHED -j DNAT --to $INTERNAL_SERVER_IP
done
#MANGLE
iptables -t mangle -A PREROUTING -p tcp -m multiport --sports $MINIMIZE_DELAY -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p tcp -m multiport --sports $MAXIMIZE_THROUGHPUT -j TOS --set-tos Maximize-Throughput
iptables -t mangle -A PREROUTING -p tcp -m multiport --dports $MINIMIZE_DELAY -j TOS --set-tos Minimize-Delay
iptables -t mangle -A PREROUTING -p tcp -m multiport --dports $MAXIMIZE_THROUGHPUT -j TOS --set-tos Maximize-Throughput



#chain for blocking Inbound traffic
iptables -N blockin
#block inbound traffic from specific IPs 
if [[ -n $IP_BLOCK ]]; then
iptables -A blockin -i $EXTERNAL  -s $IP_BLOCK -j DROP
fi
#block inbound traffic from a source address from the outside matching your internal network.
iptables -A blockin -i $EXTERNAL  -s $INTERNAL_NETWORK -j DROP
#OR??????????????????
#iptables -A blockin -i $EXTERNAL -o $INTERNAL ! -s $EXTERNAL_NETWORK -j DROP


#block syn and fin bits.  Refer to http://www.smythies.com/~doug/network/iptables_syn/index.html
iptables -A blockin -i $EXTERNAL  -p tcp ! --syn -m state --state NEW -j DROP
iptables -A blockin -i $EXTERNAL  -p tcp --tcp-flags SYN,FIN SYN,FIN -j DROP

#block inbound traffic to and from specified ports
iptables -A blockin -i $EXTERNAL  -p udp -m multiport --sports $BLOCK_PORTS_IN -j DROP
iptables -A blockin -i $EXTERNAL  -p udp -m multiport --dports $BLOCK_PORTS_IN -j DROP
iptables -A blockin -i $EXTERNAL  -p tcp -m multiport --sports $BLOCK_PORTS_IN -j DROP
iptables -A blockin -i $EXTERNAL  -p tcp -m multiport --dports $BLOCK_PORTS_IN -j DROP
#drop SYN packets from ports less than 1024
iptables -A blockin -i $EXTERNAL  -p tcp -m multiport --sports 0:1023 -m state --state NEW -j DROP
iptables -A blockin -i $EXTERNAL  -p udp -m multiport --sports 0:1023 -m state --state NEW -j DROP
#drop SYN packets to high ports
iptables -A blockin -i $EXTERNAL  -p tcp -m multiport ! --dports 0:1023 -m state --state NEW -j DROP
iptables -A blockin -i $EXTERNAL  -p udp -m multiport ! --dports 0:1023 -m state --state NEW -j DROP
#Block all external traffic directed to ports 32768 – 32775, 137 – 139, TCP ports 111 and 515. 
iptables -A blockin -i $EXTERNAL  -p tcp -m multiport --dports 32768:32775,137:139,111,515 -j DROP
iptables -A blockin -i $EXTERNAL  -p udp -m multiport --dports 32768:32775,137:139 -j DROP

#add inbound blocking chain to input chain
iptables -A FORWARD -j blockin
iptables -A INPUT -j blockin


#block outbound traffic from specific IPs
iptables -N blockout
if [[ -n $IP_BLOCK ]]; then
iptables -A blockout  -i $INTERNAL -d $IP_BLOCK -j DROP
fi
iptables -A blockout  -i $INTERNAL ! -s $INTERNAL_NETWORK -j DROP
#block syn and fin bits. refer to  http://www.smythies.com/~doug/network/iptables_syn/index.html
iptables -A blockout  -i $INTERNAL -p tcp ! --syn -m state --state NEW -j DROP
iptables -A blockout  -i $INTERNAL -p tcp --tcp-flags SYN,FIN SYN,FIN  -j DROP

#block out bound to and from specified ports
iptables -A blockout  -i $INTERNAL -p udp -m multiport --sports $BLOCK_PORTS_OUT -j DROP
iptables -A blockout  -i $INTERNAL -p udp -m multiport --dports $BLOCK_PORTS_OUT -j DROP
iptables -A blockout  -i $INTERNAL -p tcp -m multiport --sports $BLOCK_PORTS_OUT -j DROP
iptables -A blockout  -i $INTERNAL -p tcp -m multiport --dports $BLOCK_PORTS_OUT -j DROP
#drop SYN packets from ports less than 1024
iptables -A blockout  -i $INTERNAL -p tcp -m multiport --sports 0:1023 -m state --state NEW -j DROP
iptables -A blockout  -i $INTERNAL -p udp -m multiport --sports 0:1023 -m state --state NEW -j DROP
#drop SYN packets to high ports
iptables -A blockout  -i $INTERNAL -p tcp -m multiport ! --dports 0:1023 -m state --state NEW -j DROP
iptables -A blockout  -i $INTERNAL -p udp -m multiport ! --dports 0:1023 -m state --state NEW -j DROP
#Block all external traffic directed to ports 32768 – 32775, 137 – 139, TCP ports 111 and 515. 
iptables -A blockout  -i $INTERNAL -p tcp -m multiport --dports 32768:32775,137:139,111,515 -j DROP
iptables -A blockout  -i $INTERNAL -p udp -m multiport --dports 32768:32775,137:139 -j DROP
#add outbound blocking chain to output chain
iptables -A FORWARD -j blockout
iptables -A INPUT -j blockout


#DNS AND DHCP TRAFFIC for firewall
iptables -N necessitiesin
iptables -A INPUT -j necessitiesin
iptables -N necessitiesout
iptables -A OUTPUT -j necessitiesout
iptables -N necessitiesforward
iptables -A FORWARD -j necessitiesforward
#allow inbound dns and udp traffic
iptables -A necessitiesin -i $EXTERNAL -p udp -m multiport --sports $DNS_PORT_IN,$DHCP_PORT_IN -j ACCEPT
iptables -A necessitiesforward -i $EXTERNAL -o $INTERNAL -p udp -m multiport --sports $DNS_PORT_IN,$DHCP_PORT_IN -j ACCEPT
#allow inbound dns and dhcp traffic
iptables -A necessitiesin -i $EXTERNAL -p tcp -m multiport --sports $DNS_PORT_IN,$DHCP_PORT_IN -j ACCEPT
iptables -A necessitiesforward -i $EXTERNAL -o $INTERNAL -p tcp -m multiport --sports $DNS_PORT_IN,$DHCP_PORT_IN -j ACCEPT
#allow outbound udp dns and dhcp traffic
iptables -A necessitiesout -o $EXTERNAL -p udp -m multiport --dports $DNS_PORT_OUT,$DHCP_PORT_OUT -j ACCEPT
iptables -A  necessitiesforward -o $EXTERNAL -i $INTERNAL -p udp -m multiport --dports $DNS_PORT_OUT,$DHCP_PORT_OUT -j ACCEPT
#allow outbound tcp dns and dhcp traffic
iptables -A necessitiesout -o $EXTERNAL -p tcp -m multiport --dports $DNS_PORT_OUT,$DHCP_PORT_OUT -j ACCEPT
iptables -A  necessitiesforward -o $EXTERNAL -i $INTERNAL -p tcp -m multiport --dports $DNS_PORT_OUT,$DHCP_PORT_OUT -j ACCEPT


#ICMP Chain
iptables -N icmpin
arr=$(echo $ICMP_ALLOW_TYPES | tr "," "\n")
for x in $arr
do
  iptables -A icmpin -i $EXTERNAL -p icmp --icmp-type $x -m state --state NEW,ESTABLISHED -j ACCEPT
done
iptables -A FORWARD -p icmp -j icmpin


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



