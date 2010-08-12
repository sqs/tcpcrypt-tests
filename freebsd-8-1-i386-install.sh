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

test/tcpcrypt -t 0 171.66.3.211 80
R=$?

killall tcpcryptd

return $R