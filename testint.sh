#testing firewall from an internal source.

IP_ADDR="192.168.0.3"
FIREWALL_IP="192.168.10.1"
IP="google.ca"
BASEFILE="tests/test"

# Test Case 1
CASE=1
# Allow Inbound/Outbound TCP Packets allowed on user defined port 80, 22, 443
hping3 $IP -S -c 5 -p 80 > $BASEFILE$CASE
hping3 $IP -S -c 5 -p 22 >> $BASEFILE$CASE
hping3 $IP -S -c 5 -p 443 >> $BASEFILE$CASE
echo "root\nuest1onQ?\nifconfig\nexit\n" | ssh $IP_ADDR

# Test Case 2
CASE=2
# Allow Inbound/Outbound UDP Packets allowed on user defined port 0
hping3 $IP --udp -c 5 -p 0 > $BASEFILE$CASE

#Test Case 3
CASE=3
# Allow Inbound/Outbound ICMP Packets allowed on type 8
hping3 $IP --icmp -C 8 -c 5 > $BASEFILE$CASE

#Test Case 4
CASE=4
# Drop all packets destined to the firewall host from outside
hping3 $FIREWALL_IP -p ++0 -c 2000 -i u1000 -S > $BASEFILE$CASE
#Refer to Test Case 1 for ssh and they are dnat'd ports

#Test Case 5
CASE=5
# 
hping3 $IP -p ++1024 -c 5000 -i u1000 -S > $BASEFILE$CASE
#Test Case 6
CASE=6
#
hping3 $IP -s 0 -c 1024 -i u1000 -S > $BASEFILE$CASE
#Test Case 7
CASE=7
# fragments
hping3 $IP -S -f -p 80 -c 5 > $BASEFILE$CASE
#Test Case 8
CASE=8
#existing connections
hping3 $IP -c 5 > $BASEFILE$CASE
#Test Case 9
CASE=9
# Outside matching internal network. and vice versa
hping3 $IP -c 5 > $BASEFILE$CASE
#Test Case 10
CASE=10

hping3 $IP -p 80 -c 5 -S -F > $BASEFILE$CASE
#Test Case 11
CASE=11	
hping3 $IP -S -c 5 -p 23 > $BASEFILE$CASE
#Test Case 12
CASE=12
hping3 $IP --udp -p 32768 -c 8 > $BASEFILE$CASE
hping3 $IP --udp -p 137 -c 3 >> $BASEFILE$CASE
#Test Case 13
CASE=13
hping3 $IP -p 32768 -c 8 > $BASEFILE$CASE
hping3 $IP -p 137 -c 3 >> $BASEFILE$CASE
hping3 $IP -p 111 -c 1 >> $BASEFILE$CASE
hping3 $IP -p 515 -c 1 >> $BASEFILE$CASE

#Test Case 14
# Use other tool for FTP
CASE=14
echo "root\nuest1onQ?\nexit\n" | ssh $IP_ADDR

# Test Case 15
# Use other tool for FTP
CASE=15


#Test Case 16
CASE=16
hping3 $IP -s 2000 -p 416 -c 5







