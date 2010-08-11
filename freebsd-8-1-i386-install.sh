# NOTE: /etc/rc.conf must contain:
#   firewall_enable="YES"
#   firewall_type="open"
# and /boot/loader.conf must contain:
#   ipfw_load="YES"
#   ipdivert_load="YES"
cd /usr/ports/security/openssl && make && make install

cd /root/tcpcrypt/user
gmake clean && gmake

ipfw 01 add divert 666 tcp from 127.0.0.1/32 to 127.0.0.1/32

tcpcrypt/tcpcryptd -v &
sleep 2
LD_LIBRARY_PATH=`pwd`/lib test/tcpcrypt -v -t 0
