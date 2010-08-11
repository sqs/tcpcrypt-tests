TCPCRYPT = ../tcpcrypt/

VM_DISK = $(PLATFORM)-disk
PID_FILE = vm-$(PLATFORM).pid
SNAPSHOT = -snapshot
QEMU_OPTS = -m 384 -net user -net nic,model=rtl8139    \
            -redir tcp:5022::22 -localtime $(SNAPSHOT) \
	    -daemonize -pidfile $(PID_FILE)

SSH_AUTH_OPTS = -i vmkey                       \
                -oStrictHostKeyChecking=no     \
                -oUserKnownHostsFile=/dev/null
SSH = ssh $(SSH_AUTH_OPTS) root@localhost -p 5022
SCP = scp $(SSH_AUTH_OPTS) -P 5022

$(PID_FILE):
	/usr/bin/qemu $(QEMU_OPTS) $(VM_DISK)

vm: $(PID_FILE)

.PHONY: ssh test

ssh: vm
	$(SSH)

test: vm
	$(SCP) -r $(TCPCRYPT) $(PLATFORM)-install.sh root@localhost:
	$(SSH) sh $(PLATFORM)-install.sh
#	kill `cat vm.pid`

#OSXHOST=192.168.64.128
OSXHOST=scs-sqs2
OSXUSER=sqs
test-osx:
	rsync -av -e "ssh $(SSH_AUTH_OPTS)" $(TCPCRYPT) macosx-106-i386-install.sh $(OSXUSER)@$(OSXHOST):tcpcrypt/
	ssh $(SSH_AUTH_OPTS) $(OSXUSER)@$(OSXHOST) sh tcpcrypt/macosx-106-i386-install.sh
