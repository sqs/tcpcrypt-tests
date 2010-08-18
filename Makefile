TCPCRYPT = ../tcpcrypt/

VM_DISK = $(PLATFORM)-disk
PID_FILE = vm-$(PLATFORM).pid
SNAPSHOT = -snapshot
SSH_PORT ?= 5022
HOST ?= localhost
QEMU_OPTS += -m 256 -net user -net nic,model=rtl8139    \
            -redir tcp:$(SSH_PORT)::22 -localtime $(SNAPSHOT) \
	    -daemonize -pidfile $(PID_FILE) $(NO_GFX)

ifeq ($(PLATFORM), winxp-sp3-i386)
	SSH_USER = tcpcrypt
	EXE = .exe
else
	SSH_USER = root
	EXE = 
endif

ifeq ($(PLATFORM), freebsd-81-i386)
	VM_MAKE = gmake
else
	VM_MAKE = make
endif

SSH_AUTH_OPTS = -i vmkey                       \
                -oStrictHostKeyChecking=no     \
                -oUserKnownHostsFile=/dev/null
SSH = ssh $(SSH_AUTH_OPTS) -p $(SSH_PORT) $(SSH_USER)@$(HOST)
SCP = scp $(SSH_AUTH_OPTS) -P $(SSH_PORT)
RSYNC = rsync --exclude='*.d' --exclude='*.o' --exclude='*.so' --exclude='*.a' -av -e "ssh $(SSH_AUTH_OPTS) -p $(SSH_PORT)"

$(PID_FILE):
	/usr/bin/qemu $(QEMU_OPTS) $(VM_DISK)

vm: $(PID_FILE)

.PHONY: ssh test getsrc buildsrc

ssh: vm
	$(SSH)

test: vm getsrc
	$(SSH) sh tcpcrypt/$(PLATFORM)-install.sh

getsrc: vm
	$(RSYNC) $(TCPCRYPT) $(PLATFORM)-install.sh $(SSH_USER)@$(HOST):tcpcrypt/

buildsrc: getsrc
	$(SSH) 'cd tcpcrypt/user && $(VM_MAKE) && $(VM_MAKE) install'

stop:
	kill `cat $(PID_FILE)`

static-bin: getsrc
	mkdir -p bin > /dev/null
	$(SSH) 'cd tcpcrypt/user && $(VM_MAKE) clean && $(VM_MAKE) STATIC=1'
	$(SCP) $(SSH_USER)@$(HOST):tcpcrypt/user/tcpcrypt/tcpcryptd$(EXE) bin/tcpcryptd-$(PLATFORM)$(EXE)

MOD_TCPCRYPT = ../mod_tcpcrypt
REMOTE_WWW_ROOT = /tmp/mod_tcpcrypt
REMOTE_APACHECTL = /etc/init.d/apache2
APACHE_USER = www-data
APACHE_GROUP = www-data
test-apache: getsrc buildsrc apache-mod-install do-test-apache

apache-mod-install:
	$(MAKE) -C $(MOD_TCPCRYPT) clean
	$(RSYNC) $(MOD_TCPCRYPT) $(SSH_USER)@$(HOST):
	$(SSH) 'cd mod_tcpcrypt && make install && a2enmod tcpcrypt'
	$(SCP) $(MOD_TCPCRYPT)/test/test-tcpcrypt-site $(SSH_USER)@$(HOST):/etc/apache2/sites-available
	$(SSH) mkdir -p $(REMOTE_WWW_ROOT)
	$(SCP) $(MOD_TCPCRYPT)/test/tcpcrypt.sh $(SSH_USER)@$(HOST):$(REMOTE_WWW_ROOT)
	$(SSH) "chown -R $(APACHE_USER):$(APACHE_GROUP) $(REMOTE_WWW_ROOT) && \
		chmod -R 700 $(REMOTE_WWW_ROOT)"
	$(SSH) 'a2dissite default && a2ensite test-tcpcrypt-site'
	$(SSH) $(REMOTE_APACHECTL) restart

do-test-apache:
#	sudo $(TCPCRYPT)/user/launch_tcpcryptd.sh &
	echo Need to have tcpcryptd running on server and set up for http server...
	sleep 1
	$(MOD_TCPCRYPT)/test/test_mod_tcpcrypt.sh on http://$(HOST):80/tcpcrypt.sh
	sudo killall tcpcryptd
	sleep 1
	$(MOD_TCPCRYPT)/test/test_mod_tcpcrypt.sh off http://$(HOST):80/tcpcrypt.sh