src_net="192.168.0.0/24"

#interface name
INTERFACE="em1"

#Allowing ports(protocols)
TCP_ALLOW_PORTS_IN="22,80,443" #from these ports (acting as a client)
TCP_ALLOW_PORTS_IN_SERVER="80" #acting as server (allow connections to these ports)
TCP_ALLOW_PORTS_OUT="22,80,443"
TCP_ALLOW_PORTS_OUT_SERVER="0"
UDP_ALLOW_PORTS_IN="0"
UDP_ALLOW_PORTS_IN_SERVER="0"
UDP_ALLOW_PORTS_OUT="0"
UDP_ALLOW_PORTS_OUT_SERVER="0"


#block traffic to and from these IP addresses
IP_BLOCK="192.168.0.1"
#block these ports regardless of IP or protocol.
BLOCK_PORTS_IN="0"
BLOCK_PORTS_OUT="0"




#DO NOT TOUCH!
#Allowing dns and dhcp ports.  you shouldn't touch these if you want your computer to work.
DNS_PORT_IN="53"
DNS_PORT_OUT="53"
DHCP_PORT_IN="67"
DHCP_PORT_OUT="68"

#remove all existing chains
iptables -F
#set policies to drop
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -P INPUT DROP

#block inbound traffic from specific IPs 
iptables -N blockin
iptables -A blockin -i $INTERFACE -s $IP_BLOCK -j DROP
iptables -A INPUT -j blockin

#block outbound traffic from specific IPs
iptables -N blockout
iptables -A blockout -o $INTERFACE -d $IP_BLOCK -j DROP
iptables -A OUTPUT -j blockout

#Accounting rules
#iptables -N accounting
#iptables -A accounting -i $INTERFACE -p tcp 

#create udpin chain
iptables -N udpin
iptables -A udpin -i $INTERFACE -p udp --sport $BLOCK_PORTS_IN -j DROP
iptables -A udpin -i $INTERFACE -p udp --dport $BLOCK_PORTS_IN -j DROP
iptables -A udpin -i $INTERFACE -p udp -m multiport --sports $DNS_PORT_IN,$DHCP_PORT_IN -j ACCEPT
iptables -A udpin -i $INTERFACE -p udp -m multiport --sports $UDP_ALLOW_PORTS_IN -m state --state ESTABLISHED -j ACCEPT # acting as a client
iptables -A udpin -i $INTERFACE -p udp -m multiport --dports $UDP_ALLOW_PORTS_IN_SERVER -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a server
iptables -A INPUT -p udp -j udpin
#create tcpin chain
iptables -N tcpin
iptables -A tcpin -i $INTERFACE -p tcp --sport $BLOCK_PORTS_IN -j DROP
iptables -A tcpin -i $INTERFACE -p tcp --dport $BLOCK_PORTS_IN -j DROP
iptables -A tcpin -i $INTERFACE -p tcp --dport 80 -m multiport --sports 0:1023  -j DROP		#drop packets to port 80 from ports less than 1024
iptables -A tcpin -i $INTERFACE -p tcp -m multiport --sports $DNS_PORT_IN,$DHCP_PORT_IN -j ACCEPT
iptables -A tcpin -i $INTERFACE -p tcp -m multiport --sports $TCP_ALLOW_PORTS_IN -m state --state ESTABLISHED -j ACCEPT # acting as a client
iptables -A tcpin -i $INTERFACE -p tcp -m multiport --dports $TCP_ALLOW_PORTS_IN_SERVER -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a server
iptables -A INPUT -p tcp -j tcpin

#create udpout chain
iptables -N udpout
iptables -A udpout -o $INTERFACE -p udp --sport $BLOCK_PORTS_IN -j DROP
iptables -A udpout -o $INTERFACE -p udp --dport $BLOCK_PORTS_IN -j DROP
iptables -A udpout -o $INTERFACE -p udp -m multiport --dports $DNS_PORT_OUT,$DHCP_PORT_OUT -j ACCEPT
iptables -A udpout -o $INTERFACE -p udp -m multiport --dports $UDP_ALLOW_PORTS_OUT -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a client
iptables -A udpout -o $INTERFACE -p udp -m multiport --sports $UDP_ALLOW_PORTS_OUT_SERVER -m state --state ESTABLISHED -j ACCEPT # acting as a server
iptables -A OUTPUT -p udp -j udpout
#create tcpout chain
iptables -N tcpout
iptables -A tcpout -o $INTERFACE -p tcp --sport $BLOCK_PORTS_IN -j DROP
iptables -A tcpout -o $INTERFACE -p tcp --dport $BLOCK_PORTS_IN -j DROP
iptables -A tcpout -o $INTERFACE -p tcp -m multiport --dports $DNS_PORT_OUT,$DHCP_PORT_OUT -j ACCEPT
iptables -A tcpout -o $INTERFACE -p tcp -m multiport --dports $TCP_ALLOW_PORTS_OUT -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a client
iptables -A tcpout -o $INTERFACE -p tcp -m multiport --sports $TCP_ALLOW_PORTS_OUT_SERVER -m state --state ESTABLISHED -j ACCEPT # acting as a server
iptables -A OUTPUT -p tcp -j tcpout



