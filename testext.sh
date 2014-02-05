#testing firewall from an external source.

IP="192.168.0.2"
OUTPUT=""
#ssh into dest ip
echo "root\nuest1onQ? \n exit\n" | ssh $IP $OUTPUT
#test case 3: drop inbound traffic to port 80 from source ports < 1024
hping3 $IP -s 0 -c 1024 -p 80 -S -V
hping3 $IP -s 1024 -c 10 -p 80 -S -V
#test case 4
hping3 $IP -s 0 -p 80 -S -V
hping3 $IP -s 8000 -p 0 -S -V
#test case 6
hping3 $IP -s 8000 -p ++0 -c 2000 -S -V # should receive 5 packets
