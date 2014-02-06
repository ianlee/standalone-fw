#testing firewall from an internal source.

IP="192.168.0.3"
OUTPUT=""
#ssh into dest ip
echo "root\nuest1onQ? \n exit\n" | ssh $IP $OUTPUT


#iptables -Z
iptables -L -n -v -x -Z
