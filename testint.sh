#testing firewall from an internal source.

#IP="192.168.0.3"
IP="google.ca"
BASEFILE="tests/test"
CASE=1

#testcase1
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase2
CASE=2
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase3
CASE=3
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase4
CASE=4
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase5
CASE=5
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase6
CASE=6
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase7
CASE=7
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase8
CASE=8
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase9
CASE=9
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase10
CASE=10
hping3 $IP -p 80 -c 5 -S -F > $BASEFILE$CASE
#testcase11
CASE=11
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase12
CASE=12
hping3 $IP -c 5 > $BASEFILE$CASE
#testcase13
CASE=13
hping3 $IP -c 5 > $BASEFILE$CASE
