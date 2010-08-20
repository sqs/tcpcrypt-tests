import sys, os, unittest
import ssh

LOCAL_TCPCRYPT = "/home/sqs/src/tcpcrypt"

class PlatformTestCase(unittest.TestCase):

    host = ""
    port = 22
    user = "root"

    def setUp(self):
        self.get_source()
        
    def tearDownClass(self):
        self.ssh.close()

    def get_source(self):
        self.ssh.execute(self.base_deps)
        os.system("rsync -avz -e 'ssh %s' %s %s@%s:" % \
                      (self.ssh_opts, LOCAL_TCPCRYPT, self.user, self.host))
        self.ssh.execute(self.cd_user + self.make_clean)
    
    @property
    def ssh(self):
        if not hasattr(self, '__ssh'):
            self.__ssh = ssh.Connection(self.host, port=self.port,
                                        username=self.user, private_key='vmkey')
        return self.__ssh

    ssh_opts  = "-i vmkey -oStrictHostKeyChecking=no " \
                "-oUserKnownHostsFile=/dev/null"
        
    install_deps = None
    make = "make"
    make_install = "make install"
    make_clean = "make clean"
    cd_user = "cd tcpcrypt/user && "

    def test_make(self):
        self.ssh.execute(self.build_deps)
        self.ssh.execute(self.cd_user + self.make)

    def test_make_install(self):
        self.ssh.execute(self.cd_user + self.make_install)
        

class UbuntuVMTestCase(PlatformTestCase):
    base_deps    = "apt-get install git-core build-essential"
    build_deps   = "apt-get install libcap-dev libnfnetlink-dev " \
                   "libnetfilter-queue-dev iptables openssl-dev"

if __name__ == "__main__":
    suite = unittest.TestLoader().loadTestsFromTestCase(UbuntuVMTestCase)
    unittest.TextTestRunner(verbosity=2).run(suite)

