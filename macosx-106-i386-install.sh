cd $HOME/tcpcrypt/user

make

sudo ./launch_tcpcryptd.sh &
sleep 2
LD_LIBRARY_PATH=`pwd`/lib test/tcpcrypt -v -t 0
sudo killall tcpcryptd
exit