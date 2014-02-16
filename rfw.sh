iptables -F
iptables -P OUTPUT ACCEPT
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -t filter -F
iptables -t mangle -F
iptables -t nat -F
