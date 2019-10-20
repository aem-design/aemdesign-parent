AEM Design Parent
=================

[![build_status](https://github.com/aem-design/aemdesign-parent/workflows/ci/badge.svg)](https://github.com/aem-design/aemdesign-parent/actions?workflow=ci)
[![github license](https://img.shields.io/github/license/aem-design/aemdesign-parent)](https://github.com/aem-design/aemdesign-parent) 
[![github issues](https://img.shields.io/github/issues/aem-design/aemdesign-parent)](https://github.com/aem-design/aemdesign-parent) 
[![github last commit](https://img.shields.io/github/last-commit/aem-design/aemdesign-parent)](https://github.com/aem-design/aemdesign-parent) 
[![github repo size](https://img.shields.io/github/repo-size/aem-design/aemdesign-parent)](https://github.com/aem-design/aemdesign-parent) 
[![github repo size](https://img.shields.io/github/languages/code-size/aem-design/aemdesign-parent)](https://github.com/aem-design/aemdesign-parent) 


This project is used to facilitate packaging and deployment of AEM projects and related tech.

***
<p style="color:red;">
<b>PLEASE ENSURE THAT YOU STUDY THE README, DO NOT SKIM OVER THIS AS THERE IS A LOT OF MOVING PARTS YOU WONT KNOW ABOUT</b><br><br>
<b>PLEASE ENSURE THAT ALL PREREQUISITES ARE INSTALLED BEFORE DOING ANYTHING, OTHERWISE YOU WILL HAVE ISSUES YOU WILL NEED TO ANALYSE AND FIX ON YOUR OWN</b><br><br>
<b>YOUR BASH AND TEAM MATES WILL THANK YOU!!!</b>
</p>

***

# Preamble

**_BIG NOTE: DevOps by default will send output log of all operations to Slack!_**

Please check channel ```devops-builds``` in ```aem.design``` slack!

This will make it easier for everyone to trouble shoot.

# Project A-B-C's

Overall process of getting your local environment setup for development

- A. Get your perquisites ready - setup dependencies, use ```./devops``` as a test if ok
- B. Run ```./devops buildlocaldev``` - this will build a vm and add it to Virtual box and configure it to be used locally and deploy all services.
- C. Run playbooks in deploy project
- D. Read the [AEM.Design Principles](docs/README-PRINCIPLES.md) before you start inventing the wheel again


# Pre-Requisites

This project was built for Linux, Mac Osx and Windows (Cygwin and Bash on Ubuntu on Windows).

**Following is the map of logic around getting started:**

<a href="https://www.draw.io/?state=%7B%22ids%22:%5B%220Byd8VBrCoqkAR3NmOXZhRzNkZzA%22%5D,%22action%22:%22open%22,%22userId%22:%22100423874271124247542%22%7D#G0Byd8VBrCoqkAR3NmOXZhRzNkZzA">
<img src="docs/README-ProjectFlow.png" alt="Drawing" style="height: 500px;"/>
</a>

# Getting Started Approach

* [Get some soft](#get-some-soft) (https://www.youtube.com/watch?v=KpWqTjLn7Fg)
* [Setup SSH and GPG setup on Gitlab](docs/README-SSH-GPG.md) **IMPORTANT: ALL NON VERIFIED COMMITS WILL BE REJECTED**
* Choose your Setup, ***pick one*** that matches your machine config
    * **PLEASE ENSURE THAT** ```./devops``` RETURNING **OK** FOR ALL PREREQUISITES BEFORE CONTINUING, if you find missing dependencies please raise a PR ot this readme after you update the [Dependencies Table](#dependencies-table)
    * [Mac](docs/README-MAC.md) - PREFERRED - you run Mac as your main OS
    * [Windows Docker] - PREFERRED - you have docker setup
    * [Ubuntu](docs/README-UBUNTU.md) - you run Ubuntu as a main OS
    * [Windows 10 Dual Account](docs/README-WIN10-DualAccount.md) - EXPERIMENTAL - is you have dual account please follow this
    * [Windows 10 Bash](docs/README-WIN10-BASH.md) - EXPERIMENTAL - preferred if you run Windows 10 as main OS
    * [Windows 10 Cygwin](docs/README-WIN10-CYGWIN.md) - EXPERIMENTAL - you run Windows 10 as main OS but wan't Cygwin
* Proceed to [Ready to Roll](#ready-to-roll) once you have all Pre-Requisites installed
* If you run into issues check [Troubleshooting](docs/README-FAQ.md) before you create an issue
* Check out [Repo Info](#repos-info) section to see project descriptions
* Start by checking out [Contributing](docs/README-CONTRIBUTING.md) info



## Get some soft

### Software you will need before you start!

####Dependencies Table


***
<p style="color:red;">
<b>Please DO NOT install apps into paths with Spaces</b><br><br>
<b>YOUR BASH WILL THANK YOU!!!</b></p>
***

Download and install following dependencies, please see following table for help on how to install these:

```
[OK]    java              1.8.0_202            1.8.0+
[OK]    mvn               3.6.0                3.5.0+
[OK]    unzip             6.00                 6.00+
[OK]    git               2.21                 2.4.0+
[OK]    git-lfs           2.7.1                2.0.0+
[OK]    node              1.11                 8.1.3+
[OK]    npm               6.7.0                2.12.1+
[OK]    curl              7.54.0               7.35.0+
[OK]    imagemagick       7.0.8-32             7.0.7+
[OK]    realpath          8.31                 8.29+
[OK]    python2           2.7.16               2.7.10+
[OK]    python3           3.7.2                3.6.1+
[OK]    pip               19.0.3               7.0.0+
[OK]    virtualenv        16.4.3               15.1.0+
[OK]    ansible           2.5.15               2.4.1.0+
[OK]    ansible-playbook  2.5.15               2.4.1.0+
[OK]    VBox              6.0.4r128413         5.2.24+
[OK]    VBox Ext          6.0.4                5.2.24+
[OK]    netcat            ok                   ok+
[OK]    groovy            5.6                  2.5.3+
[OK]    bundle            2.0.1                2.0.1+
[OK]    socat             1.7.3.2              1.7.3.2+
```

How to install dependencies:

| Manual Install On Platform       | Software       | Purpose  | Location | Add to System Path  | Script Executable <sup id="a1">[1](#f1)</sup> |
|:---:              |----------------|----------|----------| :---:               |-------------------|
| LINUX | [Virtual Box](https://www.virtualbox.org/wiki/Downloads) | used for creating VM Docker Host |  | Yes | ```VirtualBox``` |
| LINUX | [Virtual Box Ext](https://www.virtualbox.org/wiki/Downloads) | allows automation of VM |  | Yes |  |
| LINUX | [Maven](https://archive.apache.org/dist/maven/maven-3/3.5.0/binaries/) | used as build automation |  | Yes | ```mvn``` |
| LINUX | [Java JDK8](http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-windows-x64.exe?AuthParam=1493724079_cdb2ad47b66a10357fd9749f14b1d8e4) | check latest versions [here](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) |  | Yes | ```java``` |
| LINUX | [Nodejs](https://nodejs.org/dist/v6.10.3/) | used for prototype  |   | Yes | ```node``` |
| LINUX | [Git LFS](https://git-lfs.github.com/) | need it for binaries |   | Yes | ```git-lfs``` |
| LINUX | [FFmpeg](https://www.ffmpeg.org/) | for local AEM instance |  | Yes | ```ffmpeg``` |
| LINUX | [Groovy](http://groovy-lang.org/install.html) | or running groovy scripts |  | Yes | ```groovy``` |
| CYGWIN | [Imagemagick](http://www.imagemagick.org/) | for comparing screenshots while testing |  | Yes | ```compare``` |
| CYGWIN | [Virtual Box](https://www.virtualbox.org/wiki/Downloads) | used for creating VM Docker Host | ```C:\shared\apps\Oracle\VirtualBox``` | Yes | ```VirtualBox``` |
| CYGWIN | [Virtual Box Ext](https://www.virtualbox.org/wiki/Downloads) | allows automation of VM | | Yes |  |
| CYGWIN | [Java JDK8](http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-windows-x64.exe?AuthParam=1493724079_cdb2ad47b66a10357fd9749f14b1d8e4) | check latest versions [here](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html) | ```C:\shared\apps\Java\jdk1.8.0_131``` | Yes | ```java``` |
| CYGWIN | [Maven](https://archive.apache.org/dist/maven/maven-3/3.5.0/binaries/) | used as build automation | ```C:\shared\apps\apache-maven-3.5.0\bin```| Yes | ```mvn``` |
| CYGWIN | [Nodejs](https://nodejs.org/dist/v6.10.3/) | used for prototype  | ```C:\shared\apps\node-v6.10.2-win-x64``` | Yes | ```node``` |
| CYGWIN | [Git LFS](https://git-lfs.github.com/) | need it for binaries | ```C:\Program Files\Git LFS``` | Yes | ```git-lfs``` |
| CYGWIN | [Unzip](http://gnuwin32.sourceforge.net/packages/unzip.htm) | need it for binaries | ```C:\unzip``` | Yes | ```unzip``` |
| CYGWIN | [FFmpeg](https://www.ffmpeg.org/) | for local AEM instance |  | Yes | ```ffmpeg``` |
| CYGWIN | [Imagemagick](http://www.imagemagick.org/) | for comparing screenshots while testing |  | Yes | ```compare``` |
| CYGWIN | [Groovy](http://groovy-lang.org/install.html) | or running groovy scripts |  | Yes | ```groovy``` |
| MAC | [Brew](https://brew.sh/) | need it on mac in general | ```/usr/local/bin/brew``` | Yes | ```brew``` |
| MAC | ```brew install node@8``` | used for prototype  | ```C:\shared\apps\node-v6.10.2-win-x64``` | Yes | ```node``` |
| MAC | ```brew cask install java8``` | | | Yes | ```java``` |
| MAC | ```brew install git-lfs``` | need it for binaries |  | Yes | ```git-lfs``` |
| MAC | ```git lfs install``` | need it to initialise git-lfs |  | Yes | ```git-lfs``` |
| MAC | ```brew install coreutils``` | need it for realpath |  | Yes | ```realpath``` |
| MAC | ```brew install maven``` | used as build automation |  | Yes | ```mvn``` |
| MAC | ```brew cask install virtualbox``` | used for creating VM Docker Host |  | Yes | ```VirtualBox``` |
| MAC | ```brew cask install virtualbox-extension-pack``` | allows automation of VM |  | Yes |  |
| MAC | ```brew install ffmpeg``` | for local AEM instance |  | Yes | ```ffmpeg``` |
| MAC | ```brew install imagemagick``` | for comparing screenshots while testing |  | Yes | ```compare``` |
| MAC | ```brew install groovy``` | for running groovy scripts |  | Yes | ```groovy``` |
| MAC | ```brew install socat``` | for running groovy scripts |  | Yes | ```groovy``` |
| MAC | ```brew cask install docker && brew install bash-completion docker-completion docker-compose-completion docker-machine-completion``` | for running containers |  | Yes | ```docker``` |
| MAC | ```export PIP_REQUIRE_VIRTUALENV=false pip install virtualenv virtualenvwrapper``` | for python environments to store dependencies |  | Yes | ```workon``` |


###  Software Installation Notes:
Virtual Box: - Turn off other Virtual Box programs
             - Run VBox as admin to install extensions
             - Change Default Machine Folder dir so there are no spaces in folder names
              
<b id="f1"><sup>1</sup></b> - This command line is hardcoded in all scripts, run ```./devops``` to test your dependencies. [↩](#a1)

# Ready to Roll

Chose your path

- [Quick using Docker](#quick-path-using-docker) - I don't want to deep-dive but I want to use this awesomeness!
- [Quick using VirtualBox](#quick-path-using-docker) - let's get this show on the road!
- [Manual](#manual-path) - I've got this!

## Overview

Following is the map of commands and important artifacts and steps that you need to be aware of:

<a href="https://www.draw.io/?state=%7B%22ids%22:%5B%220Byd8VBrCoqkAR0xlNklRc3NHckE%22%5D,%22action%22:%22open%22,%22userId%22:%22100423874271124247542%22%7D#G0Byd8VBrCoqkAR0xlNklRc3NHckE">
<img src="docs/README-DevFlow.png" alt="Drawing" style="height: 500px;"/>
</a>

* VM Keys are generated for you only and added to the VM during Build Process, these same keys you will use to access the VM, for PROD use these should be provided.


## Quick Path using Docker
Quick path to getting Docker containers deployed on your local Docker Host, this will only setup Author and Selenium Hub in a docker container.

- clone parent repo

```bash
git clone --recursive git@gitlab.com:aem.design/aemdesign-parent.git
```

- Verify dependencies (some missing dependencies will be installed using install steps)

```bash
./devops
```

- Start quickstart this will run clone, install and buildlocaldev in one step, good for testing end to end process

```bash
./devops dockerlocaldev
```




## Quick Path using VirtualBox
Quick path to getting VM built with project deployed, this uses all command in order to build a VM for first time users only.

- clone parent repo

```bash
git clone --recursive git@gitlab.com:aem.design/aemdesign-parent.git
```

- Verify dependencies (some missing dependencies will be installed using install steps)

```bash
./devops
```

- Start quickstart this will run clone, install and buildlocaldev in one step, good for testing end to end process

```bash
./devops quickstart
```


## Manual Path
Manually run commands to get a vm built, will help you learn commands

- clone parent repo

```bash
git clone --recursive git@gitlab.com:aem.design/aemdesign-parent.git
```

- Verify dependencies, this will show you if you are missing dependencies

```bash
./devops
```

- Clone child projects, if you dont have them

```bash
./devops clone
```

- Install dependencies, if you have missing dependencies run following

```bash
./devops install
```


NOTE: install will run buildlocaldev after 10sec timeout

- build local VM and deploy containers

```bash
./devops buildlocaldev
```

- Post some screenshots on your blog when is done :)

# Repos Info

Following is a description of each repo and their purpose.

For more information see [Project Artifacts](http://aem.design/manifesto/project/#project-artifacts)

| Repo                            | Notes                                       |
|---------------------------------|---------------------------------------------|
| aemdesign-parent/               | root repo for devops script and automation  |
| aemdesign-aem-core/             | primary repo for aemdesign code artifacts   |
| aemdesign-aem-support/          | repo with reference implementation          |
| aemdesign-operations/           | operations and deployment projects          |
| aemdesign-archetype/            | archetype project for new projects          |

#Container Logs

You can monitor logs of containers by either using Docker container logs interface or manually tail using docker exec

Here is an example of monitoring error log on author

If you have deployed the config repo it would have forced all logs to output to container console, this is done to allow easy collection of logs from containers.

You can monitor container out put using following command

```bash
docker logs -f author
```

If your container is not configured to output all log to console then you can use the exec to tail the logs directly

```bash
docker exec -it author tail -f crx-quickstart/logs/error.log
```


#DevOps Script Commands

Usage for script

```bash
    ./devops {action} {action_params ...}
```

| Command        | Description |
|:---:           |--- |
| help           | show help |
| quit           | show nice logo |
| install        | install of dependencies run as ROOT |
| clone          | get configured repos |
| pull           | get updates for all repos |
| push           | push changes for all repos |
| status         | view changes for all repos |
| buildpr        | build prototype |
| buildlocaldev  | build a VM for development |
| accesslocal    | ssh into local VM |
| deploylocaldev | run a playbook to deploy services to localdev |
| stashlist      | show list of stash for all repos |
| quickstart     | automated run from freshly cloned parent repo |
| resetrepos     | reset all repos to master |
| checkout       | checkout a branch on all submodules |
| stash          | stash on all submodules |
| stash pop      | stash pop on all submodules |
| dockerlocaldev | build localdev using local docker |

### Local AEM Instance Command

***Please use Docker instead see ```./devops dockerlocaldev``` command***

For the commands below refer for module specific setup in aemdesign-operations/aemdesign-aem/README.md

| Command        | Description |
|:---:           |--- |
| startaut       | run author nodev |
| startpub       | run publisher node | 
| startauthpub   | run author and publisher nodes together |
| stopaut        | stop author node. |
| stoppub        | stop publisher node |
| stopauthpub    | run author and publisher nodes together |


# Process: Build a VM for development

Following is the the structure of the VM ```buildlocaldev``` process:

* Setup Shell ENV
* Check Env Settings
* Setup Process Variables
* Verify if VM Appliance is already configured
* Check VirtualBox config
* Update VirtualBox Network settings
* IF Required Build Appliance using Packer
* IF Required Import Appliance as a VM
* IF Required Start VM
* Check if VM is configured
* IF Required upload AEM Jar to Nexus
* Run Ansible Site playbook

NOTE: If Ansible playbook fails you need restart the process

# Docker

Tail container log from latest date

```bash
docker logs -ft author --since 2019-01-18
```
