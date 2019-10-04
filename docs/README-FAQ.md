Troubleshooting
=================


- Check your Python virtualenv is working
create a new env

```bash
mkvirtualenv aemdesign
```

activate new env

```bash
workon aemdesign
```

- if you have problems with deploy dependency install in regards to opensshv.h not being found, you may need to link the openssl includes into your python.

```bash
ln -s /usr/local/opt/openssl/include/openssl /usr/local/Cellar/python/2.7.13/Frameworks/Python.framework/Versions/2.7/include/python2.7/openssl
```

- import parent project in Intellij and Check the check box below:
    * Search for projects recursively
    * Import Maven projects automatically
- google some stuff post an issue after googling, if you found a solution post that as feature update

- cleaning up line endings in file

```bash
sed -i 's/\r$//' scripts/functions.sh
```


- your dev AEM instance running a bit slow, possible because of not enough ram, try:
    - restart AEM container you are using
    - restart the VM
    - stopping some containers you are not using.
    - add more ram to your VM and update AEM container maximum ram

- VT-x is not available
    - need to Disable Hyper-V and/or enable Virtual support in Bios?

- Some problems with your virtualenv can be fixed by relinking virtualenv to latest references, this usualy happens after updates

```bash
cd ~/.virtualenvs/aemdesign.py36/
rm -rf .Python bin/python* lib/python2.7/* include/python2.7
virtualenv .
workon aemdesign.py36
pip freeze
```

    
Repos Set to Incorrect branch
-----------------------------

If you have not worked on a project for a while, please checkout and pull master for all repos before you start working.

- Using Cygwin run the following in ```aemdesign-parent``` repo:

```bash
git checkout master && git pull && cd ..
cd aemdesign-aem &&  git checkout master && git pull && cd ..
cd aemdesign-aem-author &&  git checkout master && git pull && cd ..
cd aemdesign-aem-common &&  git checkout master && git pull && cd ..
cd aemdesign-aem-config &&  git checkout master && git pull && cd ..
cd aemdesign-aem-content &&  git checkout master && git pull && cd ..
cd aemdesign-aem-services &&  git checkout master && git pull && cd ..
cd aemdesign-aem-showcase &&  git checkout master && git pull && cd ..
cd aemdesign-aem-training &&  git checkout master && git pull && cd ..
cd aemdesign-deploy &&  git checkout master && git pull && cd ..
cd aemdesign-devbot &&  git checkout master && git pull && cd ..
cd aemdesign-docker &&  git checkout master && git pull && cd ..
cd aemdesign-esb-mule &&  git checkout master && git pull && cd ..
cd aemdesign-jenkins &&  git checkout master && git pull && cd ..
cd aemdesign-aem-prototype &&  git checkout master && git pull && cd ..
cd aemdesign-security &&  git checkout master && git pull && cd ..
cd aemdesign-testing &&  git checkout master && git pull && cd ..
cd aemdesign-vm &&  git checkout master && git pull && cd ..
```

SSH Keys
--------
SSH Keys should be generated automatically the first time you build locally, however there are times when you may need to regenerate or rotate these keys.
This rotation process can be initiated by a pre-existing playbook found at:
```bash
aemdesign-deploy/playbooks/docker/container-sshkeys.yml
```
Alternatively keys can be generated manually through:
```bash
./aemdesign-vm/keys/generatekeys
```

All keys should be rotated when:
- A developer leaves the project
- Periodically every 3 months