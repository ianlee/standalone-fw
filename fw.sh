src_net = "192.168.0.2/24"


#DO NOT TOUCH!
#remove all existing chains
iptables -F
#set policies to drop
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
iptables -P INPUT DROP

#create udpin chain
iptables -N udpin
iptables -A udpin -p udp --sport 0 -j DROP
iptables -A udpin -p udp --dport 0 -j DROP
iptables -A udpin -p udp -m multiport --sports 53,67 -j ACCEPT
iptables -A INPUT -p udp -j udpin
#create tcpin chain
iptables -N tcpin
iptables -A tcpin -p tcp --sport 0 -j DROP
iptables -A tcpin -p tcp --dport 0 -j DROP
iptables -A tcpin -p tcp --dport 80 -m multiport --sports 0:1024  -j DROP
iptables -A tcpin -p tcp -m multiport --sports 53,67 -j ACCEPT
iptables -A tcpin -p tcp -m multiport --sports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a client
iptables -A tcpin -p tcp -m multiport --dports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a server
iptables -A INPUT -p tcp -j tcpin

#create udpout chain
iptables -N udpout
iptables -A udpout -p udp --sport 0 -j DROP
iptables -A udpout -p udp --dport 0 -j DROP
iptables -A udpout -p udp -m multiport --dports 53,68 -j ACCEPT
iptables -A OUTPUT -p udp -j udpout
#create tcpout chain
iptables -N tcpout
iptables -A tcpout -p tcp -m multiport --dports 53,68 -j ACCEPT
iptables -A tcpout -p tcp -m multiport --dports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a client
iptables -A tcpout -p tcp -m multiport --sports 22,80,443 -m state --state NEW,ESTABLISHED -j ACCEPT # acting as a server
iptables -A OUTPUT -p tcp -j tcpout



