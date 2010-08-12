cd $HOME/tcpcrypt/user

make

# NOTE: Assumes that tcpcryptd is already launched, because Passthru doesn't
# seem to allow selective filtering based on ports.
# ./launch_tcpcryptd.sh &
# sleep 2

echo Checking for tcpcrypt session ID for connection to tcpcrypt.org:80...
echo | test/tcpcrypt -vvvv 171.66.3.211 80 | grep 'Session ID'
