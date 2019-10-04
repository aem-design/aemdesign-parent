WINDOWS 10 CYGWIN
=================

This package is used to facilitate packaging and deployment of AEM projects.

# First Time Install

Install Cygwin and prepare PATH variables  
- [Cygwin](https://www.cygwin.com/setup-x86_64.exe) - download and execute following in the download directory using Windows Command.

```bash
setup-x86_64.exe -P zip,unzip,wget,lynx,curl,git,openssh,openssl,openssl-devel,python3,python3-devel,python3-pip,python-jinja2,python3-cryptography,python3-openssl,python3-setuptools,python3-boto,python3-httplib2,python3-six,python3-packaging,python3-appdirs,nc,libffi-devel,gcc-g++,make,libcurl-devel,procps-ng
```

- Add paths to PATH Variable

```
C:\apache-maven-3.5.0\bin
C:\Program Files\Oracle\VirtualBox
C:\node-v6.10.2-win-x64
```

- Create new Environment Vars

```
JAVA_HOME=C:\Program Files\Java\jdk1.8.0_131
MAVEN_HOME=C:\apache-maven-3.5.0
```

## Update your Cygwin Profile

You need to configure Git CRLF handling and GIT SSH keys permissions

```bash
git config --global --add core.autocrlf true && \
git config --global core.eol lf && \
cat << 'EOL' >> ~/.bash_profile

if [ -f ~/.ssh/id_rsa ]; then
	chmod 400 ~/.ssh/id_rsa
fi

if [ -f ~/.ssh/id_rsa.pub ]; then
	chmod 660 ~/.ssh/id_rsa.pub
fi

if [ -f ~/.ssh/id_rsa.pub ]; then
	ssh-add ~/.ssh/id_rsa
fi

EOL
```

# Dual Account Setup on Windows (Corporate Desktops)

- Run ```./devops install``` as admin account
- Change all permissions of ```/usr``` to your primary non-admin account
- First run of ```./devops buildlocaldev``` as non-admin account will fail during Network configurations,
following command will fail, run them manually as admin account, then resume as non-admin account
```vboxmanage hostonlyif ipconfig "VirtualBox Host-Only Ethernet Adapter ....```

# Cygwin Problems

## Random forked process died unexpectedly!

You will see errors like this:

```text
TASK [config-copyfiles : copy files to remote ( aem-base )] **************************************************************************
Wednesday 07 June 2017  23:26:43 +1000 (0:00:00.143)       0:04:26.225 ********
      0 [main] python2 6756 fork: child -1 - forked process 952 died unexpectedly, retry 0, exit code 0xC0000142, errno 11
An exception occurred during task execution. To see the full traceback, use -vvv. The error was: OSError: [Errno 11] Resource temporarily unavailable
fatal: [192.168.27.2]: FAILED! => {"failed": true, "msg": "Unexpected failure during module execution.", "stdout": ""}
```

Read more about this here: https://cygwin.com/ml/cygwin/2012-02/msg00212.html

This is due to some dodgy apps aka BLODA, not much can be done just need to watch-out for them, there is a big list located here: https://cygwin.com/faq.html#faq.using.bloda

You can read more about fork issues here: https://cygwin.com/faq.html#faq.using.fixing-fork-failures

If you see this issue please run following, restart Cygwin and you last action

```bash
echo "CYGWIN=detect_bloda">>~/.bash_profile
```

In addition to this add following folder to your VirusScanner(Windows Defender etc)

- C:\projects\aemdesign-parent
- C:\Program Files\Oracle\VirtualBox
- C:\apache-maven-3.5.0
- C:\cygwin64


## Experiment configs

You bash will need some general packages for this project to operate as expected.

For Windows, using cygwin 64bit setup exe Python 3

```bash
setup-x86_64.exe -P zip,unzip,wget,lynx,curl,git,openssh,openssl,openssl-devel,nc,libffi-devel,gcc-g++,make,libcurl-devel,procps-ng,python3,python3-devel,python3-pip,python-jinja2,python3-cryptography,python3-openssl,python3-setuptools,python3-boto,python3-httplib2,python3-six,python3-packaging,python3-appdirs
```

For Windows, using cygwin 64bit setup exe Python 2

```bash
setup-x86_64.exe -P zip,unzip,wget,lynx,curl,git,openssh,openssl,openssl-devel,nc,libffi-devel,gcc-g++,make,libcurl-devel,procps-ng,python2,python2-devel,python2-pip,python-jinja2,python2-cryptography,python2-openssl,python2-setuptools,python2-boto,python2-httplib2,python2-six,python2-packaging,python2-appdirs
```

For Windows, using cygwin 64bit setup exe Python 2 and 3

```bash
setup-x86_64.exe -P zip,unzip,wget,lynx,curl,git,openssh,openssl,openssl-devel,nc,libffi-devel,gcc-g++,make,libcurl-devel,procps-ng,python2,python2-devel,python2-pip,python-jinja2,python2-cryptography,python2-openssl,python2-setuptools,python2-boto,python2-httplib2,python2-six,python2-packaging,python2-appdirs,python3,python3-devel,python3-pip,python3-cryptography,python3-openssl,python3-setuptools,python3-boto,python3-httplib2,python3-six,python3-packaging,python3-appdirs
```
