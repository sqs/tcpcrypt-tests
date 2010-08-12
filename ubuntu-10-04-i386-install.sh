apt-get install -y \
    iptables libnfnetlink-dev libnetfilter-queue-dev libcap-dev libssl-dev

cd tcpcrypt/user
make
make install

./launch_tcpcryptd.sh &
sleep 0.5

test/tcpcrypt -v -l 127.0.0.1 7777 > server.log &
sleep 0.3
test/tcpcrypt -v 127.0.0.1 7777 > client.log

server_sessid=`grep 'Session ID' server.log`
client_sessid=`grep 'Session ID' client.log`

killall tcpcryptd tcpcrypt 2> /dev/null
sleep 0.1

echo -n Testing that local connection uses tcpcrypt and that session IDs match...
if [ -n "$server_sessid" ] && \
   [ -n "$client_sessid" ] && \
   [ "$server_sessid" = "$client_sessid" ]
then
    echo OK
    exit 0
else
    echo FAIL
    exit 1
fi