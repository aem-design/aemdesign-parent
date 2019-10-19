#!/bin/bash
#set -o nounset
#set -o errexit

export PROJECT_CONFIG_PREFIX
export PROJECT_VM
export PROJECT_ESB
export PROJECT_DEPLOY
export PROJECT_AEM
export PROJECT_PROTOTYPE
export PROJECT_CONFIG_PLATFROM
export PROJECT_CONFIG_APPLIANCE
export PROJECT_CONFIG_APPLIANCEFORMAT
export PROJECT_CONFIG_APPLIANCEBUILD
export PROJECT_OPERATIONS
export PROJECT_AEM_CORE
export PROJECT_AEM_SUPPORT

PROJECT_CONFIG_PREFIX="aemdesign"
PROJECT_OPERATIONS="$PROJECT_CONFIG_PREFIX-operations"
PROJECT_AEM_CORE="$PROJECT_CONFIG_PREFIX-aem-core"
PROJECT_AEM_SUPPORT="$PROJECT_CONFIG_PREFIX-operations"
PROJECT_VM="$PROJECT_AEM_SUPPORT/$PROJECT_CONFIG_PREFIX-vm"
PROJECT_ESB="$PROJECT_AEM_SUPPORT/$PROJECT_CONFIG_PREFIX-esb-mule"
PROJECT_DEPLOY="$PROJECT_AEM_SUPPORT/$PROJECT_CONFIG_PREFIX-deploy"
PROJECT_AEM="$PROJECT_AEM_SUPPORT/$PROJECT_CONFIG_PREFIX-aem"
PROJECT_PROTOTYPE="$PROJECT_AEM_SUPPORT/$PROJECT_CONFIG_PREFIX-prototype"
PROJECT_CONFIG_PLATFROM="centosatomic"
PROJECT_CONFIG_SETTINGS="settings/variables-centos-atomic-online.json"
PROJECT_CONFIG_TEMPLATE="templates/centos-atomic-virtualbox.json"
PROJECT_CONFIG_APPLIANCE="$PROJECT_CONFIG_PREFIX-vm"
PROJECT_CONFIG_APPLIANCEFORMAT="ova"
PROJECT_CONFIG_APPLIANCEBUILD="builds"

# only here for purpouse of intellij
# provides context handling in intellij
CHECK_IDE_INTELLIJ="intellij"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-params.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-debug.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-logic.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-info.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-menu.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-environment.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-settings.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-common.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-python.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-npm.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-repoman.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-prototype.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-aem.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-ansible.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-localdev.sh"
[ "ide" == "$CHECK_IDE_INTELLIJ" ] && source "./functions-maven.sh"

source "$DIR_INC/functions-params.sh"
source "$DIR_INC/functions-debug.sh"
source "$DIR_INC/functions-logic.sh"
source "$DIR_INC/functions-info.sh"
source "$DIR_INC/functions-menu.sh"
source "$DIR_INC/functions-environment.sh"
source "$DIR_INC/functions-settings.sh"
source "$DIR_INC/functions-common.sh"
source "$DIR_INC/functions-python.sh"
source "$DIR_INC/functions-npm.sh"
source "$DIR_INC/functions-repoman.sh"
source "$DIR_INC/functions-prototype.sh"
source "$DIR_INC/functions-aem.sh"
source "$DIR_INC/functions-ansible.sh"
source "$DIR_INC/functions-localdev.sh"
source "$DIR_INC/functions-maven.sh"

VBOXMANAGE="$(which VBoxManage || which VBoxManage.exe)"

function checkPreReqs() {
    debug "Checking Prerequisites:" "warn"

    local FAILTEST="0"

    printVerisonHeader

    checkVersion2 "$(java -version 2>&1 | grep 'java version' | awk -F'"' '{print $2}')" 1.8.0 [1-9].[8-9].[0-9] "java"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

    checkVersion2 "$(mvn --version 2>&1 | grep 'Apache Maven' | awk '{print $3}')" 3.5.0 [3-9].[3-9].[0-9] "mvn"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

    checkVersion2 "$(unzip --version 2>&1 | grep 'UnZip' | awk '{print $2}')" 6.00 "[0-9].[0-9]\{1,\}" "unzip"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

    checkVersion git 2.4.0 [2-9].[1-9].[0-9] "--version"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi
    checkVersion2 "$(git-lfs version | awk '{print $1}' | awk -F'/' '{print $2}')" 2.0.0 [2-9].[0-9].[0-9] "git-lfs"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

    checkVersion node 8.1.3 [0-9].[0-9].[0-9] "--version"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

    checkVersion2 "$(npm --version)" 2.12.1 [1-9].[1-9].[0-9] "npm"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

    checkVersion curl 7.35.0 [7-9].[3-9][0-9].[0-9] "--version"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

#    checkVersion2 "$(convert --version | head -n 1 | awk '{print $3}')" 7.0.7 [7-9].[0-9].[7-9] "imagemagick"
#    if [[ $_RETURNVALUE == 0 ]]; then
#        FAILTEST="1"
#    fi

    checkVersion realpath 8.29 [8-9].[2-9][0-9] "--version"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

#    checkVersion python2 2.7.10 [2-9].[7-9].[1-9][0-9] "--version"
#    if [[ $_RETURNVALUE == 0 ]]; then
#        FAILTEST="1"
#    fi
    checkVersion python3 3.6.1 [3-9].[0-9].[0-9][0-9] "--version"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi
    checkVersion2 "$(python -m pip --version 2>&1 | grep 'pip' | awk '{print $2}')" 7.0.0 [7-9].[0-9].[0-9] "pip"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

#    checkVersion2 "$(virtualenv --version 2>&1 | awk '{print $1}')" 15.1.0 [1-9][5-9].[1-9].[0-9] "virtualenv"
#    if [[ $_RETURNVALUE == 0 ]]; then
#        FAILTEST="1"
#    fi

    checkVersion2 "$(ansible --version 2>/dev/null | awk 'NR==1 {print $2}')" 2.4.1.0 [2].[4].[1-9].[0-9] "ansible"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

    checkVersion2 "$(ansible-playbook --version  2>/dev/null| awk 'NR==1 {print $2}')" 2.4.1.0 [2].[4].[1-9].[0-9] "ansible-playbook"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

#    checkVersion2 "$("$VBOXMANAGE" --version 2>&1 | awk '{ gsub(/[^0-9a-zA-Z .]/, "", $1); print $1}')" 5.2.24 [5-9].[2-9].[2-9][4-9] "VBox"
#    if [[ $_RETURNVALUE == 0 ]]; then
#        FAILTEST="1"
#    fi
#
#    checkVersion2 "$("$VBOXMANAGE" list extpacks 2>&1 | grep "Oracle VM VirtualBox Extension Pack" -A 2 | grep Version: | awk '{print $2}')" 5.2.24 [5-9].[2-9].[2-9][4-9] "VBox Ext"
#    if [[ $_RETURNVALUE == 0 ]]; then
#        FAILTEST="1"
#    fi

    checkVersion2 "$(nc -h 2>&1 | grep -E "usage:" -q && echo ok)" ok [ok] "netcat"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

#    checkVersion groovy 2.5.3 [2-9].[5-9].[3-9] "--version"
#    if [[ $_RETURNVALUE == 0 ]]; then
#        FAILTEST="1"
#    fi

#    checkVersion bundle 2.0.1 [2-9].[0-9].[1-9] "--version"
#    if [[ $_RETURNVALUE == 0 ]]; then
#        FAILTEST="1"
#    fi

    checkVersion socat 1.7.3.2 [1-9].[7-9].[3-9].[2-9] "-V"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi

    checkVersion2 "$(docker --version | awk 'NR==1 {print $3}')" 18.09.2 [1-9][8-9].[0-9][0-9].[0-9] "docker"
    if [[ $_RETURNVALUE == 0 ]]; then
        FAILTEST="1"
    fi
#
#    checkVersion virtualenv 16.4.3 [1-9][6-9].[4-9].[3-9] "--version"
#    if [[ $_RETURNVALUE == 0 ]]; then
#        FAILTEST="1"
#    fi
#
#    checkVersion2 "$(virtualenvwrapper --version | grep -E "virtualenvwrapper" -q && echo ok )" ok [ok] "virtualenvwrapper"
#    if [[ $_RETURNVALUE == 0 ]]; then
#        FAILTEST="1"
#    fi
#
#    checkVersion2 "$(workon --help | grep -E "workon" -q && echo ok )" ok [ok] "workon"
#    if [[ $_RETURNVALUE == 0 ]]; then
#        FAILTEST="1"
#    fi




    if [[ "$FAILTEST" -ne "0" ]]; then
        exit 1;
    fi

    echo ""
}

function printVerisonHeader() {

    debug "$(printf "%-7s %-17s %-20s %-20s\n" "Status" "App" "Found" "Required")" "warn"

}

#checkVersion(APP,VERSIONMIN,VERSIONMINEXP,VERSIONPARAM)
function checkVersion() {
    local APP="${1:?Need app name to check version}"
    local VERSIONMIN=${2:-0.0.0} #min version
    local VERSIONMINEXP=${3:-[1-9].[1-9].[1-9]} #expression
    local VERSIONPARAM=${4:--v} #param to pass
    local TESTCHECK="s/.*\($VERSIONMINEXP*\).*/\1/p"
    local TESTAPP
    TESTAPP=$(command -v "$APP")
    local APPVERSION="0"
    _RETURNVALUE=0

    if [[ $(isNotEmpty "$TESTAPP") == true ]]; then
#        APPTEST=$($APP $VERSIONPARAM 2>&1)
        APPVERSION="$("$APP" "$VERSIONPARAM" 2>&1 | sed -n "$TESTCHECK")"
        _RETURNVALUE=1
    fi


    local outputLine
    outputLine="$(printf "%-17s %-20s %-20s" "$APP" "$APPVERSION" "$VERSIONMIN+")"

    if [[ "$APPVERSION" == "0" ]]; then
        debug "$(printf "%-14.12s%s" "[#e:FAIL#i:]" "$outputLine")" "info"
    else
        debug "$(printf "%-14.12s%s" "[#d:OK#i:]" "$outputLine")" "info"
    fi

}


#checkVersion(CHECKOUTPUT,VERSIONMIN,VERSIONMINEXP,APPTEXT)
function checkVersion2() {
    local CHECKOUTPUT=$1
    local VERSIONMIN=${2:-0.0.0} #min version
    local VERSIONMINEXP=${3:-[1-9].[1-9].[1-9]} #expression
    local VERSIONPARAM=${4--v} #param to pass
    local TESTCHECK="s/.*\($VERSIONMINEXP\).*/\1/p"
    local APPVERSION="0"
    _RETURNVALUE=0

    if [[ $(isNotEmpty "$CHECKOUTPUT") == true ]]; then
        APPVERSION="$(echo "$CHECKOUTPUT" | sed -n "$TESTCHECK")"
#        echo "VERSIONPARAM=$VERSIONPARAM"
#        echo "CHECKOUTPUT=$CHECKOUTPUT"
#        echo "TESTCHECK=$TESTCHECK"
#        echo "APPVERSION=$APPVERSION"
        _RETURNVALUE=1
    fi

    local outputLine
    outputLine="$(printf "%-17s %-20s %-20s" "$VERSIONPARAM" "${CHECKOUTPUT//[^a-zA-Z0-9._-]/ }" "$VERSIONMIN+")"

    if [[ "$APPVERSION" == "0" ]]; then
        debug "$(printf "%-14.12s%s" "[#e:FAIL#i:]" "$outputLine")" "info"
    else
        debug "$(printf "%-14.12s%s" "[#d:OK#i:]" "$outputLine")" "info"
    fi

}


function checkProjectExist() {
    PROJECT_PATH=${1:-}

    if [ -d "$DIR_ROOT/$PROJECT_PATH" ] ; then
        debug "Project [$PROJECT_PATH] found" "info"
    else
        debug "Project [$PROJECT_PATH] not found" "error"
        debug "use [./devops pull] to pull available projects" "info"
        exit 1
    fi
}

function doVersionHash {
    debug "======================"
    debugln "Generating File Hashes"
    debugln "======================"
    mkdir -p ./files
    rm -f ./files/files.hash
    for i in $(find . -type f | sed s/"\.\/"//); do git hash-object "$i" | tr -d '\n'; echo -e "\t$i"; done > ./files/files.hash
    #mv /tmp/files.hash ./files/files.hash

}

debug "Functions Loaded." "info"
