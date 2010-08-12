# NOTE: /etc/rc.conf must contain:
#   firewall_enable="YES"
#   firewall_type="open"
# and /boot/loader.conf must contain:
#   ipfw_load="YES"
#   ipdivert_load="YES"
cd /usr/ports/security/openssl && make && make install

cd /root/tcpcrypt/user
gmake
gmake install

./launch_tcpcryptd.sh &
sleep 1.5

echo Testing tcpcrypt connection to tcpcrypt.org:80...
echo | test/tcpcrypt -vv 171.66.3.211 80
R=$?

echo Testing tcpcrypt connection on localhost:7777...
test/tcpcrypt -v -l 127.0.0.1 7777 &
test/tcpcrypt -v 127.0.0.1 7777
R=$?

killall tcpcryptd tcpcrypt

return $R