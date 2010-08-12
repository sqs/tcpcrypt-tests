TCPCRYPT = ../tcpcrypt/

VM_DISK = $(PLATFORM)-disk
PID_FILE = vm-$(PLATFORM).pid
SNAPSHOT = -snapshot
SSH_PORT ?= 5022
QEMU_OPTS += -m 256 -net user -net nic,model=rtl8139    \
            -redir tcp:$(SSH_PORT)::22 -localtime $(SNAPSHOT) \
	    -daemonize -pidfile $(PID_FILE) $(NO_GFX)

ifeq ($(PLATFORM), winxp-sp3-i386)
	SSH_USER = tcpcrypt
else
	SSH_USER = root
endif
SSH_AUTH_OPTS = -i vmkey                       \
                -oStrictHostKeyChecking=no     \
                -oUserKnownHostsFile=/dev/null
SSH = ssh $(SSH_AUTH_OPTS) -p $(SSH_PORT) $(SSH_USER)@localhost 
SCP = scp $(SSH_AUTH_OPTS) -P $(SSH_PORT)

$(PID_FILE):
	/usr/bin/qemu $(QEMU_OPTS) $(VM_DISK)

vm: $(PID_FILE)

.PHONY: ssh test

ssh: vm
	$(SSH)

test: vm
	rsync -av -e "ssh $(SSH_AUTH_OPTS) -p $(SSH_PORT)" $(TCPCRYPT) $(PLATFORM)-install.sh $(SSH_USER)@localhost:tcpcrypt/
	$(SSH) sh tcpcrypt/$(PLATFORM)-install.sh
#	kill `cat vm.pid`

#OSXHOST=192.168.64.128
OSXHOST=scs-sqs2
OSXUSER=sqs
test-osx:
	rsync -av -e "ssh $(SSH_AUTH_OPTS)" $(TCPCRYPT) macosx-106-i386-install.sh $(OSXUSER)@$(OSXHOST):tcpcrypt/
	ssh $(SSH_AUTH_OPTS) $(OSXUSER)@$(OSXHOST) sh tcpcrypt/macosx-106-i386-install.sh

test-winxp:
	rsync -av -e "ssh $(SSH_AUTH_OPTS) -p $(SSH_PORT)" $(TCPCRYPT) $(PLATFORM)-install.sh $(SSH_USER)@localhost:tcpcrypt/
	$(SSH) sh tcpcrypt/$(PLATFORM)-install.sh
