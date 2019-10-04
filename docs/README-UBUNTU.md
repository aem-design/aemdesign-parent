UBUNTU
======

Please read main readme before running these commands

### First Time Install

You already know how to do this, but here are some notes

For Ubuntu 17.04


After cloning parent repo run ```sudo ./devops```

Packages

```bash
sudo add-apt-repository ppa:webupd8team/java -y && \
sudo apt-get update -y && \
echo "oracle-java8-installer shared/accepted-oracle-license-v1-1 select true" | sudo debconf-set-selections && \
sudo apt-get install -y oracle-java8-installer && \
sudo apt-get install -y autoconf build-essential libffi-dev libtool pkg-config gcc make libcurl4-openssl-dev libssl-dev python3 python3-dev python3-pip python3-cryptography python3-openssl python3-setuptools python3-boto python3-httplib2 python3-six python3-packaging python3-appdirs nodejs nodejs-legacy unzip maven git npm && \
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash && \
sudo apt-get install git-lfs
```

Git LFS

```bash
sudo su -
apt-get install software-properties-common
add-apt-repository ppa:git-core/ppa
curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | sudo bash
apt-get install git-lfs
git lfs install
```
Node

```bash
sudo su -
apt-get install python-software-properties
curl -sL https://deb.nodesource.com/setup_8.x | sudo -E bash -
apt-get install nodejs
```
Python VirtualEnv Wrapper

```bash
sudo su -
apt-get -y install python-pip python-dev build-essential
pip install virtualenv virtualenvwrapper
pip install --upgrade pip
```

Bash Profile
```bash
echo "source ~/.bash_profile">>~/.bashrc
```

Virtual Box

[Ubuntu + Secure boot + Virtualbox install Guide](https://stegard.net/2016/10/virtualbox-secure-boot-ubuntu-fail/)

After you have installed make sure Virtual Box drivers are activated

```bash
sudo su -
modprobe vboxdrv
modprobe vboxnetadp
modprobe vboxnetflt
modprobe vboxpci
```

