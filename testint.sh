#testing firewall from an internal source.

IP_ADDR="192.168.0.8"
FIREWALL_IP="192.168.10.1"
IP="192.168.0.8"
SSH_ADDR="root@$IP_ADDR"
BASEFILE="internal_tests/test"

################################# Test Case 1 ###################################
echo "Test case 1 commencing..."
CASE=1
# Allow Inbound/Outbound TCP Packets allowed on user defined port 80, 22, 443

echo "Pinging 5 TCP packets to port 80 of host $IP:"
hping3 $IP -S -c 5 -p 80 > $BASEFILE$CASE

echo "Pinging 5 TCP packets to port 22 of host $IP:"
hping3 $IP -S -c 5 -p 22 >> $BASEFILE$CASE

echo "Pinging 5 TCP packets to port 443 of host $IP:"
hping3 $IP -S -c 5 -p 443 >> $BASEFILE$CASE

echo "SSH Login of $SSH_ADDR"
sshpass -p "uest1onQ?" ssh -o StrictHostKeyChecking=no $SSH_ADDR "ifconfig;exit" >> $BASEFILE$CASE

echo "Test case 1 results written to file"

################################# Test Case 2 ###################################
echo "Test case 2 commencing..."
CASE=2
# Allow Inbound/Outbound UDP Packets allowed on user defined port 53

echo "Pinging 5 UDP Packets to port 53 of host $IP:"
hping3 $IP --udp -c 5 -p 53 > $BASEFILE$CASE

echo "Test case 2 results written to file"


################################# Test Case 3 ###################################
echo "Test case 3 commencing..."
CASE=3
# Allow Inbound/Outbound ICMP Packets allowed on type 8

echo "Pinging 5 ICMP packets to host $IP:"
hping3 $IP --icmp -C 8 -c 5 > $BASEFILE$CASE
echo "Test case 3 results written to file"


################################# Test Case 4 ###################################
echo "Test case 4 commencing..."
CASE=4
# Drop all packets destined to the firewall host from outside

echo "Pinging packets from internal host to firewall:"
hping3 $FIREWALL_IP -p ++0 -c 2000 -i u1000 -S > $BASEFILE$CASE
# Refer to Test Case 1 for ssh and they are dnat'd ports
echo "Test case 4 results written to file"


################################# Test Case 5 ###################################
echo "Test case 5 commencing..."
CASE=5
# Drop SYN packets to high ports 
echo "Pinging SYN packets to high ports to host $IP:"
hping3 $IP -p ++1024 -c 5000 -i u1000 -S > $BASEFILE$CASE
echo "Test case 5 results written to file"


################################# Test Case 6 ###################################
echo "Test case 6 commencing..."
CASE=6
# Drop SYN packets from low ports
echo "Pinging SYN packets from low ports to host $IP:"
hping3 $IP -s 0 -c 1024 -i u1000 -S > $BASEFILE$CASE
echo "Test case 6 results written to file"

################################# Test Case 7 ###################################
echo "Test case 7 commencing..."
CASE=7
# fragments
echo "Sending TCP/IP fragments to port 80 of host $IP:"
hping3 $IP -S -f -p 80 -c 5 > $BASEFILE$CASE
echo "Test case 7 results written to file"

################################# Test Case 8 ###################################
echo "Test case 8 commencing..."
CASE=8
#existing connections
echo "Sending packets to existing connections via port 53:"
hping3 $IP -A -p 53 -c 5 > $BASEFILE$CASE
echo "Test case 8 results written to file"

################################# Test Case 9 ###################################
echo "Test case 9 commencing..."
CASE=9
# Outside matching internal network. and vice versa
hping3 $IP -c 5 > $BASEFILE$CASE
echo "Test case 9 results written to file"

################################# Test Case 10 ##################################
echo "Test case 10 commencing..."
CASE=10
#Sending Packets with SYN and FIN flags toggled
echo "Sending packets with SYN and FIN flags toggled to port 80 of host $IP:"

hping3 $IP -p 80 -c 5 -S -F > $BASEFILE$CASE
echo "Test case 10 results written to file"

################################# Test Case 11 ##################################
echo "Test case 11 commencing..."
CASE=11
#Sending packets to port 23
echo "Sending packets to port 23 via Telnet of host $IP:"
hping3 $IP -S -c 5 -p 23 > $BASEFILE$CASE
echo "Test case 11 results written to file"

################################# Test Case 12 ##################################
echo "Test case 12 commencing..."
CASE=12

#Sending packets to port 32768 - 32775
echo "Sending 8 UDP packets to port 32768 - 32775 of host $IP:" 
hping3 $IP --udp -p 32768 -c 8 > $BASEFILE$CASE

#Sending packets to port 137 -139
echo "Sending 3 UDP packets to port 137 - 139 of host $IP:"
hping3 $IP --udp -p 137 -c 3 >> $BASEFILE$CASE
echo "Test case 12 results written to file"

################################# Test Case 13 ##################################
echo "Test case 13 commencing..."
CASE=13

echo "Sending 8 TCP packets to port 32768 - 32775 of host $IP:" 
hping3 $IP -p 32768 -c 8 > $BASEFILE$CASE
echo "Sending 3 TCP packets to port 137 - 139 of host $IP:"
hping3 $IP -p 137 -c 3 >> $BASEFILE$CASE
echo "Sending 3 TCP packets to port 111 of host $IP:"
hping3 $IP -p 111 -c 3 -k >> $BASEFILE$CASE
echo "Sending 3 TCP packets to port 515 of host $IP:"
hping3 $IP -p 515 -c 3 -k >> $BASEFILE$CASE
echo "Test case 13 results written to file"

################################# Test Case 14 ##################################
echo "Test case 14 commencing..."

# Use other tool for FTP
CASE=14

#Mangling SSH and FTP services
echo "Mangle SSH login of host $SSH_ADDR:"
sshpass -p "uest1onQ?" ssh -o StrictHostKeyChecking=no $SSH_ADDR "ifconfig;exit" > $BASEFILE$CASE

echo "Test case 14 results written to file"

################################# Test Case 15 ##################################
echo "Test case 15 commencing..."
# Use other tool for FTP
CASE=15
echo "Test case 15 results written to file"

################################# Test Case 16 ##################################
echo "Test case 16 commencing..."
CASE=16

echo "Sending 5 packets to port 416 of host $IP:"
hping3 $IP -s 2000 -p 416 -c 5 > $BASEFILE$CASE
echo "Test case 16 results written to file"






