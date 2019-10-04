Setup SSH and GPG setup on Gitlab
=================================

SSH Setup
---------

- Login into Gitlab and add your SSH key to your profile [SSH Keys](https://gitlab.com/profile/keys), if you don't have one generate it with PuTTY http://www.putty.org/

- Add ssh-agent loader into bash_profile and restart Cygwin Terminal

```bash
cat << 'EOL' >> ~/.bash_profile

SSHAGENT=/usr/bin/ssh-agent
SSHAGENTARGS="-s"
if [ -z "$SSH_AUTH_SOCK" -a -x "$SSHAGENT" ]; then
    eval `$SSHAGENT $SSHAGENTARGS`
    trap "kill $SSH_AGENT_PID" 0
fi

EOL
```

- Copy your SSH keys named ```id_rsa``` and ```id_rsa.pub``` to ```~/.ssh```

```bash
mkdir ~/.ssh
```

- Update your newly copied key permissions so that ssh can use them

```bash
chmod 0400 ~/.ssh/id_rsa
```

- Add your SSH key to SSH Agent

```bash
ssh-add ~/.ssh/id_rsa
```

Bonus Helper
- Create link to ```aemdesign-project``` in your home folder, this will save you changing directories

```bash
ln -s /cygdrive/c/projects/aemdesign-parent/ aemdesign-parent
```


GPG Setup
---------

MAC Link

- Install https://gpgtools.org

Windows Link
- Install https://www.gpg4win.org/get-gpg4win.html
- Be sure to confirm Kleopatra is marked for installation

### Key Import

you will need to link key from your GPG Toolchain with Git config

#### On Windows 


- Open Kleopatra and create new OpenPGP key pair

- Kleopatra will then list your key with the ID on the very right column

    (For step buy step reference load https://jamesmckay.net/2016/02/signing-git-commits-with-gpg)

- Run ```gpg --list-secret-keys``` and look for ```sec```, use the key ID for the next step

- Configure ```git``` to use GPG -- replace the key with the one from ```gpg --list-secret-keys```

```
git config --global user.signingkey {add-your-key-id-here}
git config --global commit.gpgsign true
git config --global gpg.program {file dir to gpg.exe} 
git config --global user.name {add your user name}
git config --global user.email {add your user email}
```

- Navigate Cyg to ```~/.ssh```

- Run ```gpg --allow-secret-key-import --import id_rsa.ppk```

#### On Mac and Linux?


- Add this line to ```~/.gnupg/gpg-agent.conf```

```
pinentry-program /usr/local/MacGPG2/libexec/pinentry-mac.app/Contents/MacOS/pinentry-mac
```

- Add this line to ```~/.gnupg/gpg.conf```

```
no-tty
```

- Login into Gitlab and add your GPG key to your profile [SSH Keys](https://gitlab.com/profile/gpg_keys), copy it from GPG Keychain.
