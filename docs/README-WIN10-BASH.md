WINDOWS 10 UBUNTU BASH
=================

Please read main readme before running these commands

### First Time Install

For windows 10 this is the preferred method/

These steps will install all required Bash software 

- Upgrade you windows 10 to [Creators Edition](https://www.microsoft.com/en-us/software-download/windows10) 
- Once ready, load [Bash On Ubuntu on Windows](https://msdn.microsoft.com/en-au/commandline/wsl/about) and run following script: 

```bash
sudo add-apt-repository ppa:webupd8team/java -y && \
sudo apt-get update -y && \
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && \
sudo apt-get install -y oracle-java8-installer && \
sudo apt-get install -y autoconf build-essential libffi-dev libtool pkg-config gcc make libcurl4-openssl-dev libssl-dev python3 python3-dev python3-pip python3-cryptography python3-openssl python3-setuptools python3-boto python3-httplib2 python3-six python3-packaging python3-appdirs nodejs nodejs-legacy unzip maven git npm && \
chown -R $USER:$USER /usr/local && \
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
sudo apt-get install git-lfs && \
git config --global --add core.autocrlf true && \
git config --global core.eol lf && \
sudo bash -c "echo JAVA_HOME=\"/usr/lib/jvm/java-8-oracle\">>/etc/environment" && \
sudo bash -c 'echo PATH=\"\$PATH:/mnt/c/Program\\ Files/Oracle/VirtualBox\">>/etc/environment' && \
sudo bash -c "echo $(whoami) ALL=NOPASSWD: ALL>>/etc/sudoers" && \
cat << 'EOL' >> ~/.bashrc

if [ -f ~/.bash_profile ]; then
    . ~/.bash_profile
fi

EOL && \
cat << 'EOL' >> ~/.bash_profile

alias VirtualBox="/mnt/c/Program\ Files/Oracle/VirtualBox/VirtualBox.exe"
alias virtualbox="/mnt/c/Program\ Files/Oracle/VirtualBox/VirtualBox.exe"
alias VBoxManage="/mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe"
alias vboxmanage="/mnt/c/Program\ Files/Oracle/VirtualBox/VBoxManage.exe"

SSHAGENT=/usr/bin/ssh-agent

SSHAGENTARGS="-s"

if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT" ]; then

    eval `$SSHAGENT $SSHAGENTARGS`

    trap "kill $SSH_AGENT_PID" 0

fi

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
- Once done restart your bash
- Copy SSH Keys into your ```~/.ssh``` folder


