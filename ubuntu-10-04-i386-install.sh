apt-get install -y \
    iptables libnfnetlink-dev libnetfilter-queue-dev libcap-dev libssl-dev

cd tcpcrypt/user
./configure && make

iptables -I INPUT -p tcp -j NFQUEUE --queue-num 666
iptables -I OUTPUT -p tcp -j NFQUEUE --queue-num 666

tcpcrypt/tcpcryptd -v &
sleep 2
LD_LIBRARY_PATH=`pwd`/lib test/tcpcrypt -v -t 0
kill %1