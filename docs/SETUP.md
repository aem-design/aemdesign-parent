# Development Setup

All of this software is going to make your life awesome!

Before you start make sure you have the following software setup:

* Update to Windows 10 20H2 - this will give your windows updates to run WSL2 and install needed applications. You will need to update your windows machine to at least version 20H2 preferred, use Windows Update and click "Check for updates Available at Microsoft"

You will need to have the following software installed to ensure you can contribute to development of this codebase:

* [Download and install Java 1.8](https://www.oracle.com/au/java/technologies/javase/javase-jdk8-downloads.html) - you will need this to ensure your code runs on AEM.
* [Docker Desktop](https://www.docker.com/products/docker-desktop) - this will be used by scripts to run tests
* [Powershell 7](https://github.com/PowerShell/PowerShell/releases) - this will make your windows terminal work check with `$PSVersionTable`
* [Enable Windows 10 Long Files Names](#Enable-Windows-10-Long-File-Names) - this will allow Windows to have long filenames.
* [Install Git Bash](https://gitforwindows.org/) - this will allow you to run git in terminal
* [Add Git Path Windows Path](#Add-Git-Path-Windows-Path) - this will allow you to run git and other helper functions in powershell and will make your powershell sing!
* [Windows Terminal](https://github.com/microsoft/terminal/releases) - a wrapper for all terminal available on windows
* [Add your normal user to Docker Users Group](#Add-your-normal-user-to-Docker-Users-Group) - this will allow your to run docker from your account.

You can now prepare your AEM and project for testing

* [Run AEM in Docker](#Run-AEM-in-Docker) - start a fresh copy of AEM running in Docker Container, wait for it to load and [http://localhost:4502](http://localhost:4502) and enter your license key.
* [Deploy Project Content](#Deploy-Project-Content) - deploy project code and content your AEM for testing
* [GPG using Kleopatra](https://tau.gr/posts/2018-06-29-how-to-set-up-signing-commits-with-git/) - will ensure your commits are from you!

### Update your Docker memory usage

Create a file called `.wslconfig` in your home directory with following content, update as needed:

```text
[wsl2]
memory=32GB
```

### Run AEM in Docker

[Back to Prerequisites](#Prerequisites)

To start a fresh copy of AEM running in Docker Container run following in project root:

```powershell
docker-compose up
```

### Add your normal user to Docker Users Group

[Back to Prerequisites](#Prerequisites)

Run the following command in an elevated powershell prompt:

```powershell
Add-LocalGroupMember -Group "docker-users" -Member "<YOUR USER NAME>"
```

### Enable Windows 10 Long File Names

[Back to Prerequisites](#Prerequisites)

To check if your registry entry value for long filenames support:

```powershell
reg query HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\FileSystem /v LongPathsEnabled
```

To enable Windows 10 long filename run following command in elevated powershell and restart your computer:

```powershell
reg add HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Control\FileSystem /v LongPathsEnabled /t REG_DWORD /d 0x1 /f 
```

To enable git to use long filename run following command in elevated powershell and restart your computer:

```powershell
git config --global core.longpaths true
```

### Add Git Path Windows Path

[Back to Prerequisites](#Prerequisites)

You need to add following paths to your System Path environment variable:

* C:\Program Files\Git\bin - this contains main git
* C:\Program Files\Git\usr\bin - this contains helpers that are available on linux
