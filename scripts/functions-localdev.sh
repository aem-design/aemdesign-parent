#!/bin/bash

TIMESTAMP="$(date +"%s")"

function doRemoveHostFromSSH() {

        local KNOWN_HOSTS
        KNOWN_HOSTS="$(dirname ~/.ssh)/.ssh/known_hosts"

        if [[ -f "$KNOWN_HOSTS" ]]; then
            debug "Update SSH Config: Remove $1 from $KNOWN_HOSTS"
            ssh-keygen -f "$KNOWN_HOSTS" -R "$1"
        else
            debug "Update SSH Config: Config does not exist $KNOWN_HOSTS"
        fi
}


#testHostPort($IP,$PORT,$COMMENT)
function testHostPort() {
    nc -vzn -w 2 -i 1 "$1" "$2" 2>&1 | grep -o succeeded
}

#waitForHost($IP,$PORT)
function waitForHost() {
    debug "Checking VM SSH access at $1:$2"
    #can't use NC to detect Status of just created VM need to do basic wait.
    if [[ "$OS" == "linux"  ]]; then
        debug "Waiting for boot"
        local HOST_STATUS_READY=30
        while [[ $HOST_STATUS_READY -ne 0 ]]; do
            let HOST_STATUS_READY=HOST_STATUS_READY-1
            debugStatus
            sleep 1
        done

    else
        local HOST_STATUS_READY=0
        while [[ $HOST_STATUS_READY -eq 0 ]]; do
            if [[ "$(testHostPort "$1" "$2")" == "succeeded" ]]; then
                let HOST_STATUS_READY=1
            fi
            debugStatus
            sleep 1
        done
        debug ""
    fi
}

runVBoxManage() {

    if [ ! -z "${RUNASADMIN+x}" ]; then
        local PARAMS
        local FIXED_PARAMS="$*"

        PARAMS=${FIXED_PARAMS//[^A-Za-z0-9._-]/-}
        FIXED_PARAMS=${FIXED_PARAMS//[[/\\\"}
        FIXED_PARAMS=${FIXED_PARAMS//]]/\\\"}
        local TEMPFILE
        TEMPFILE="$(cygpath %USERPROFILE%\\AppData\\Local\\Temp\\devops-"${TIMESTAMP}"-VBoxManage.exe-"${PARAMS}".txt)"
        local WINTEMPFILE="%USERPROFILE%\\AppData\Local\Temp\devops-${TIMESTAMP}-VBoxManage.exe-${PARAMS}.txt"

        local COMMAND="start /B /w runas /user:${RUNASADMIN} /savecred \"cmd /K \"$VBOXMANAGE\" $FIXED_PARAMS>$WINTEMPFILE && echo ##END##>>$WINTEMPFILE && exit\" && ( For /L %n in (1,1,999) do ( findstr ##END## $WINTEMPFILE > nul 2>&1 && ( exit ) || ( echo Waiting %n of 999 && ping 127.0.0.1 -n 2 > nul 2>&1 ) ) )"

        cygstart -w cmd /C "$COMMAND"

        sleep 1

        local FILE_STATUS=0
        while [[ $FILE_STATUS -eq 0 ]]; do
            if [ -f "$TEMPFILE" ]; then
                let FILE_STATUS=1
                break
            fi
            sleep 1
        done

        cat "$TEMPFILE"
    else
        local FIXED_PARAMS="$@"
        debug "vboxmanage $FIXED_PARAMS" "info"
        # shellcheck disable=SC2086
#        "$VBOXMANAGE" $FIXED_PARAMS

#        debug "vboxmanage $FIXED_PARAMS" "info"
        # shellcheck disable=SC2086
#
        PARAMS=()

        j=''
        for PARAM in $FIXED_PARAMS; do

          if [ -n "$j" ]; then
            [[ $PARAM =~ ^(.*)[\"\']$ ]] && {
              PARAMS+=("$j ${BASH_REMATCH[1]}")

              j=''
            } || j+=" $PARAM"
          elif [[ $PARAM =~ ^[\"\'](.*)$ ]]; then
            j=${BASH_REMATCH[1]}
          else
#            echo "PARAM=${PARAM}"
            PARAMS+=($PARAM)
          fi
        done

        echo " -> $VBOXMANAGE $FIXED_PARAMS"

        eval "$VBOXMANAGE ${PARAMS[@]}"
    fi

}

function validateVirtualBoxMchineFolder() {
    CURRENT_PATH=$(runVBoxManage list systemproperties | grep "Default machine folder:" | awk '{ $1="";$2="";$3="";gsub(/^[ ]/, "", $0); gsub(/[^0-9a-zA-Z\/#\(\)-]/, "", $1); print $0}' | xargs)

    debug "VirtualBox: Machine Folder '$CURRENT_PATH'"  "info"

    if [[ $CURRENT_PATH == *" "* ]]; then
        debug "$(printf '*%.0s' {1..100})" "error"
        debug "VirtualBox: Please change Virtual Box \"Machine Path\" to path without spaces."  "error"
        debug "$(printf '*%.0s' {1..100})" "error"
        exit 0
    fi
}
function updateVirtualBox() {
    debug "VirtualBox: Update VirtualBox settings to make VLAN more stable inside the VM's" "info"
    runVBoxManage setextradata global VBoxInternal2/HostDNSSuffixesIgnore 1
}

#updateVirtualBoxVMRam($VM_NAME,$VM_RAM)
function updateVirtualBoxVMRam() {
    debug "VirtualBox: Increasing RAM for VM '$1' to $2"  "info"
    runVBoxManage modifyvm "$1" --memory "$2"
}

#updateVirtualBoxVMClock($VM_NAME)
function updateVirtualBoxVMClock() {
    debug "VirtualBox: Set VM '$1' to use UTC Hardware clock"  "info"
    runVBoxManage modifyvm "$1" --rtcuseutc on
}

#updateVirtualBoxCPU($VM_NAME)
function updateVirtualBoxCPU() {
    local CPUS=1
    debug "VirtualBox: Set VM '$1' to use '$CPUS' CPU's"  "info"

    CCPUS=$(runVBoxManage showvminfo "$PROJECT_VM" --machinereadable | grep cpus | cut -d= -f2 | tr -d '"')

    if [ -z "$CCPUS" ]; then
        CCPUS=1
    fi

    runVBoxManage modifyvm "$1" --cpuhotplug on



    if [[ $CCPUS == 8 ]]; then
        updateVirtualBoxUnplugCPU "$1" 7
        updateVirtualBoxUnplugCPU "$1" 6
        updateVirtualBoxUnplugCPU "$1" 5
        updateVirtualBoxUnplugCPU "$1" 4
        updateVirtualBoxUnplugCPU "$1" 3
        updateVirtualBoxUnplugCPU "$1" 2
        updateVirtualBoxUnplugCPU "$1" 1
    fi

    runVBoxManage modifyvm "$1" --cpus $CPUS
}

#updateVirtualBoxUnplugCPU($VM_NAME,$CPU)
function updateVirtualBoxUnplugCPU() {
    debug "VirtualBox: Un-Plug CPU '$2' from VM '$1'"  "info"
    runVBoxManage modifyvm "$1" --unplugcpu "$2"
}



#doVirtualBoxShutdownVM($VM_NAME)
function doVirtualBoxShutdownVM() {
    debug "VirtualBox: Shutting down VM '$1'"  "info"
    runVBoxManage controlvm "$1" acpipowerbutton
}

#doVirtualBoxStartVM($VM_NAME)
function doVirtualBoxStartVM() {
    debug "VirtualBox: Starting VM '$1'"  "info"
    runVBoxManage startvm "$1" --type headless
}


#doVirtualBoxImportVM($VM_OVA_PATH,$VM_NAME)
function doVirtualBoxImportVM() {
    local VM_PATH="$1"
    VM_PATH="$(fixPath "$VM_PATH")"

    debug "VirtualBox: Import VM '$2' from '$VM_PATH'"  "info"

    runVBoxManage import "$VM_PATH" --vsys 0 --vmname "$2"
}

#doVirtualBoxCreateHostLan
function doVirtualBoxCreateHostLan() {
    runVBoxManage hostonlyif create | sed -n "s/.*'\(.*\)'.*/\1/p"
}
#isVirtualBoxVMExist($VM_NAME)
function isVirtualBoxVMExist() {
    runVBoxManage list vms | grep "$1"
}

#isVirtualBoxHostOnlyLanExists($VM_NET_HOSTIP_INIT)
function isVirtualBoxHostOnlyLanExists() {
    runVBoxManage list hostonlyifs | grep "$1" -B 3 | grep Name: | awk '{ $1="";gsub(/^[ ]/, "", $0); gsub(/[^0-9a-zA-Z #\(\)-]/, "", $0); print $0}'
}

#getVirtualBoxFirstBridedLanExists($VM_NET_HOSTIP_INIT)
function getVirtualBoxFirstBridedLan() {
    runVBoxManage list bridgedifs | grep Up -m 1 -B 9 | grep Name: | awk '{ $1="";gsub(/^[ ]/, "", $0); gsub(/[^0-9a-zA-Z #\(\)-]/, "", $0); print $0}'
}

#isVirtualBoxVMRunning($VM_NAME)
function isVirtualBoxVMRunning() {
    runVBoxManage list runningvms | grep -o "$1"
}

#doVirtualBoxUpdateHostOnlyLan($VM_NET,$VM_NET_HOSTIP_INIT,$VM_NET_NETMASK)
function doVirtualBoxUpdateHostOnlyLan() {
    debug "VirtualBox: Updating Host Only Lan [$1] with ip [$2] and netmask [$3]" "info"

    if [[ "$1" =~ \ |\' ]]; then
       runVBoxManage hostonlyif ipconfig "\"${1// \\/ }\"" --ip "$2" --netmask "$3"
    else
       runVBoxManage hostonlyif ipconfig "$1" --ip "$2" --netmask "$3"
    fi
}


#isVirtualExtensionInstalled
function isVirtualExtensionInstalled () {

    local VM_CONFIG_EXTENTIONS
    VM_CONFIG_EXTENTIONS="$(runVBoxManage list extpacks | grep 'Oracle VM VirtualBox Extension Pack' -A 2 | grep Version | awk '{print $2}')"

    if [[ $(isNotEmpty "$VM_CONFIG_EXTENTIONS") == true ]]; then
        echo "$VM_CONFIG_EXTENTIONS"
    fi
}

#updateVirtualBoxVMLan($VM_NAME,$NET1_BRIDGE,$NET2_HOSTONLY,$NET3_HOSTONLY)
function updateVirtualBoxVMLan() {

    #UPDATE VM WITH NETWORK
    #NET1=public internet nat/bridge
    #NET2=host only - vm control
    #NET3=host only - management

    local NET1="$2"
    local NET2="$3"
    local NET3="$4"


    if [ "$OS" == "windows" ]; then
        debug "Updating VM '$1' Network" "info"
    #    VBoxManage modifyvm $1 --nic1 hostonly --hostonlyadapter1 $2 --nic2 nat --nic3 hostonly --hostonlyadapter3 $3
#        runVBoxManage modifyvm "$1"  --nic1 bridged --bridgeadapter1 "\"$NET1\"" --nic2 hostonly --hostonlyadapter2 "\"$NET2\"" --nic3 hostonly --hostonlyadapter3 "\"$NET3\""
        debug "Updating VM '$1' Nic 1 to Bridged '$NET1'" "info"
        runVBoxManage modifyvm "${1// /\ }"  --nic1 bridged --bridgeadapter1 "${NET1// /\ }"
        debug "Updating VM '$1' Nic 2 to HostOnly '$NET2'" "info"
        runVBoxManage modifyvm "${1// /\ }"  --nic2 hostonly --hostonlyadapter2 "${NET2// /\ }"
        debug "Updating VM '$1' Nic 3 to HostOnly '$NET3'" "info"
        runVBoxManage modifyvm "${1// /\ }"  --nic3 hostonly --hostonlyadapter3 "${NET3// /\ }"
    else
        debug "Updating VM '$1' Net Nic 2 to $NET2 and Nic 1 to NAT and VM Net Nic 3 to $NET3"
    #    VBoxManage modifyvm $1 --nic1 hostonly --hostonlyadapter1 $2 --nic2 nat --nic3 hostonly --hostonlyadapter3 $3
#        runVBoxManage modifyvm "$1"  --nic1 nat --nic2 hostonly --hostonlyadapter2 "\"$NET2\"" --nic3 hostonly --hostonlyadapter3 "\"$NET3\""
        debug "Updating VM '$1' Nic 1 to Nat" "info"
        runVBoxManage modifyvm "${1// /\ }"  --nic1 nat
        debug "Updating VM '$1' Nic 2 to HostOnly '$NET2'" "info"
        runVBoxManage modifyvm "${1// /\ }"  --nic2 hostonly --hostonlyadapter2 "${NET2// /\ }"
        debug "Updating VM '$1' Nic 3 to HostOnly '$NET3'" "info"
        runVBoxManage modifyvm "${1// /\ }"  --nic3 hostonly --hostonlyadapter3 "${NET3// /\ }"
    fi
}

#waitForVirtualBoxVMShutdown($VM_NAME)
function waitForVirtualBoxVMShutdown() {
    debug "Waiting for Virtual Box VM ""$1"" to shutdown"
    local VM_STATUS_SHUTDOWN=0
    while [[ $VM_STATUS_SHUTDOWN -eq 0 ]]; do
        if [ -z "$(isVirtualBoxVMRunning "$1")" ]; then
            let VM_STATUS_SHUTDOWN=1
        fi
        debugStatus
        sleep 1
    done
    debug ""
}
#waitForVirtualBoxVMStart($VM_NAME)
function waitForVirtualBoxVMStart() {
    debug "Waiting for VM '$1' to power on..."
    local VM_STATUS_START=0
    while [[ $VM_STATUS_START -eq 0 ]]; do
        if [[ "$(isVirtualBoxVMRunning "$1")" == "$1" ]]; then
            let VM_STATUS_START=1
            break
        fi
        debugStatus
        sleep 1
    done
    debug ""
}

#deleteVM($VM_NAME)
function deleteVM() {

    local VM_EXIST
    local VM_STATUS_ISRUNNING
    VM_EXIST="$(isVirtualBoxVMExist "$1")"
    VM_STATUS_ISRUNNING="$(isVirtualBoxVMRunning "$1")"

    debug "VM Status [$1]: $VM_EXIST, $VM_STATUS_ISRUNNING"

    if [[ $(isNotEmpty "$VM_EXIST") == true  ]]; then

        if [[ $(isNotEmpty "$VM_STATUS_ISRUNNING") == true ]]; then

            debug "VirtualBox: PowerOff VM '$1'"

            runVBoxManage controlvm "$1" poweroff

            VM_EXIST="$(isVirtualBoxVMExist "$1")"
            VM_STATUS_ISRUNNING="$(isVirtualBoxVMRunning "$1")"

            debug "VM Status [$1]: $VM_EXIST, $VM_STATUS_ISRUNNING"
        fi

        debug "VirtualBox: Unregister VM '$1'"

        runVBoxManage unregistervm "$1" --delete

        VM_EXIST="$(isVirtualBoxVMExist "$1")"
        VM_STATUS_ISRUNNING="$(isVirtualBoxVMRunning "$1")"

        debug "VM Status [$1]: $VM_EXIST, $VM_STATUS_ISRUNNING"
    fi

    debug "VirtualBox: Remove Build files '$2'"
    if [ -d "$2" ]; then
        rm -rf "$2"
    fi

}

#updateVirtualBoxVMDisk($VM_NAME,#CONTORLLER)
function updateVirtualBoxVMDisk() {
    #Convert VMDK Disks to VirtualBox native VDI format

    debug "VBoxManage showvminfo '$1' --machinereadable | grep '$2'"

    debug "VM_NAME: '$1'"
    debug "DISK_CONTROLLER_NAME: '$2'"

    local IFS_backup=$IFS
    IFS=$'\n'
    local DISK_LIST=( $(runVBoxManage showvminfo "$1" --machinereadable | grep "$2" | grep .vmdk) )
    IFS=$IFS_backup

    debug "DISK_LIST: ${DISK_LIST[@]}"

    for i in "${DISK_LIST[@]}"
    do
        DISK_CONTROLER="$(echo "$i" | awk -F'=' '{ gsub(/[^0-9a-zA-Z #\(\)-\\_]/, "", $1); print $1}')"
        DISK_FILE="$(echo "$i" | awk -F'=' '{ gsub(/[^0-9a-zA-Z #\(\)-\\_]/, "", $2); print $2}')"
        DISK_PORT="$(echo "$DISK_CONTROLER" | cut -d- -f2)"
        DISK_DEVICE="$(echo "$DISK_CONTROLER" | cut -d- -f3)"
        DISK_FILEVDI="${DISK_FILE//.vmdk/.vdi}"

        debug "DISK_CONTROLER: '$DISK_CONTROLER'"
        debug "DISK_FILE: '$DISK_FILE'"
        debug "DISK_PORT: '$DISK_PORT'"
        debug "DISK_DEVICE: '$DISK_DEVICE'"
        debug "DISK_FILEVDI: '$DISK_FILEVDI'"

        if [ ! -f "$DISK_FILEVDI" ]; then
            debug "VirtualBox: Cloning Existing HDD '$DISK_FILE' to '$DISK_FILEVDI'"

#            echo "runVBoxManage clonemedium disk "$DISK_FILE" "$DISK_FILEVDI" --format vdi"
            runVBoxManage clonemedium disk "$DISK_FILE" "$DISK_FILEVDI" --format vdi
        else

            debug "VirtualBox: Disk Already Exist '$DISK_FILEVDI'"

        fi

        debug "VirtualBox: Detaching HDD '$DISK_FILE' from VM!"

#        echo "runVBoxManage storageattach "$1" --storagectl "\"$2\"" --port "$DISK_PORT" --device "$DISK_DEVICE" --type hdd --medium none"
        runVBoxManage storageattach "$1" --storagectl "${2// /\\ }" --port "$DISK_PORT" --device "$DISK_DEVICE" --type hdd --medium none
        debugPause

        debug "VirtualBox: Closing and Removing existing HDD '$DISK_FILE'!"

#        echo "runVBoxManage closemedium disk "\"$DISK_FILE\"" --delete"
        runVBoxManage closemedium disk "$DISK_FILE" --delete
        debugPause

        debug "VirtualBox:Attaching new disk '$DISK_FILEVDI'"

#        echo "runVBoxManage storageattach "\"$1\"" \
#                             --storagectl "\"$2\"" \
#                             --device "\"$DISK_DEVICE\"" \
#                             --port "\"$DISK_PORT\"" \
#                             --type hdd \
#                             --medium "\"$DISK_FILEVDI\""
        runVBoxManage storageattach "$1" \
                             --storagectl "${2// /\\ }" \
                             --device "$DISK_DEVICE" \
                             --port "$DISK_PORT" \
                             --type hdd \
                             --medium "$DISK_FILEVDI"
        debugPause

    done

}

#doBuildVM($SETTINGS,$TEMPLATE,$HOSTNETIF)
function doBuildVM() {

    checkProjectExist "$PROJECT_VM"

    debug "Building VM with setting $1 using template $2" "warn"

    if [ "$OS" == "windows" ]; then
        debug "Building with Packer directly" "warn"
        cd "$PROJECT_VM" && ./build "$1" "$2" && cd - || return
    else
        debug "Building with Packer via maven" "warn"
        cd "$PROJECT_VM" && mvn verify -DskipTest=true -Pgeneratekeys -PverifyTemplate -PcreateVM -Dpacker.var-file="$1" -Dpacker.template="$2" -Dpacker.hostonlyadapter1="$3" -Dpacker.hostonlyadapter2="$4" && cd - || return
    fi
}

function doAccessLocalVM() {

    checkProjectExist "$PROJECT_VM"
    if [ -f "$PROJECT_VM/keys/accessvm" ]; then
        cd "$PROJECT_VM"/keys && ./accessvm && cd - || return
    else
        debug "Run ssh using keys in $PROJECT_VM/keys." "warn"
    fi
}

function doDeployLocal() {

    checkProjectExist "$PROJECT_DEPLOY"

    debug "cd $PROJECT_DEPLOY && ./site-localdev ${ACTION_PARAMS}" "info"

    if [ -f "$PROJECT_DEPLOY/site-localdev" ]; then
        cd "$PROJECT_DEPLOY" && ./site-localdev "${ACTION_PARAMS}" && cd - || return
    else
        debug "Run playbooks in $PROJECT_DEPLOY." "warn"
    fi
}

function doBuildLocalDev() {

    checkProjectExist "$PROJECT_DEPLOY"

    debug "cd $PROJECT_DEPLOY && ./vm-localdev ${ACTION_PARAMS}" "info"

    if [ -f "$PROJECT_DEPLOY/vm-localdev" ]; then
        cd "$PROJECT_DEPLOY" && ./vm-localdev "${ACTION_PARAMS}" && cd - || return
    else
        debug "Run playbooks in $PROJECT_DEPLOY." "warn"
    fi
}

function doBuildLocalDevDocker() {

    checkProjectExist "$PROJECT_DEPLOY"

    debug "cd $PROJECT_DEPLOY && ./docker-localdev ${ACTION_PARAMS}" "info"

    if [ -f "$PROJECT_DEPLOY/docker-localdev" ]; then
        cd "$PROJECT_DEPLOY" && ./docker-localdev "${ACTION_PARAMS}" && cd - || return
    else
        debug "Run playbooks in $PROJECT_DEPLOY." "warn"
    fi
}

function doUploadToNexus() {

    checkProjectExist "$PROJECT_AEM"

    debug "cd $PROJECT_AEM && ./upload-nexus" "info"

    if [ -f "$PROJECT_AEM/upload-nexus" ]; then
        cd "$PROJECT_AEM" && ./upload-nexus && cd - || return
    else
        debug "Upload file from $PROJECT_AEM." "warn"
    fi
}


function doSecureSSHKeys() {
    if [ "$OS" == "windows" ]; then
        cd "$1"/keys && ./protectkeys && stat -c '%a' current/* | uniq | awk '{print ($1=="500" || $1=="400" || $1=="444" ? "true" : "false")}' && cd - || return
    elif [ "$OS" == "darwin" ]; then
        cd "$1"/keys && ./protectkeys && stat -f '%A' current/* | uniq | awk '{print ($1=="400" ? "true" : "false")}' && cd - || return
    else
        cd "$1"/keys && ./protectkeys && stat -c '%a' current/* | uniq | awk '{print ($1=="400" ? "true" : "false")}' && cd - || return
    fi
}


function doInitAndGet() {
    debug "Check for updates for all repos"
    ./devops clone && ./devops get
}

##doRunPlaybook($INVENTORY,$PLAYBOOK,$PARAMS)
#function doRunPlaybook() {
#    checkProjectExist "$PROJECT_DEPLOY"
#
#    debug "Ansible: Inventory='$1', Playbook='$2', Params='${3:-}'" "info"
#    cd $PROJECT_DEPLOY && ansible-playbook -i $1 $2 ${3:-} && cd ..
#
#}

function doGenerateKeys() {
    debug "Check do SSH keys need generating"
    if [ -d "$PROJECT_CONFIG_APPLIANCE" ]; then

        if [ ! -f "$PROJECT_CONFIG_APPLIANCE/keys/current/aemdesign" ]; then
            debug "Generating new ssh keys"
            cd "$PROJECT_CONFIG_APPLIANCE"/keys && ./generatekeys && cd - || return
        else
            debug "SSH keys already exist"
        fi
    fi
}

function doTimeout() {
    local TIMEOUT_DEFAULT=5
    local TIMEOUT=${1:-$TIMEOUT_DEFAULT}

    (( TIMEOUT = TIMEOUT - 1 ))
    while [ "$TIMEOUT" -ge "0" ]; do
        echo -n "."
        sleep 1
        (( TIMEOUT = TIMEOUT - 1 ))
    done
    echo ""
}

function printSectionBanner() {
    TEXT=$1
    TYPE=$2
    debug "$(printf '@%.0s' {1..100})" "$TYPE"
    debug "$(printf '@  %-94s  @' "$TEXT")" "$TYPE"
    debug "$(printf '@%.0s' {1..100})" "$TYPE"

}
function doBuildLocal() {

    #check path for machines does not have spaces as it too hard to manage when passing to vboxmanage cli
    printSectionBanner "Checking Settings" "warn"
    validateVirtualBoxMchineFolder

    printSectionBanner "Setup Variables" "warn"

    local VM_PROJECT="$PROJECT_VM"
    local VM_NAME="$PROJECT_CONFIG_APPLIANCE"
    local VM_DISK_CONTROLER="SCSI Controller"
    local VM_PATH="$DIR_ROOT/$PROJECT_VM/$PROJECT_CONFIG_APPLIANCEBUILD/$PROJECT_CONFIG_PLATFROM/$PROJECT_CONFIG_APPLIANCE"
    local VM_OVA_PATH="$VM_PATH/$PROJECT_CONFIG_APPLIANCE.$PROJECT_CONFIG_APPLIANCEFORMAT"
    local VM_PROJECT_SSH_KEYS="$VM_PROJECT/keys/current"
    local VM_PROJECT_CONFIG_SETTINGS="${PROJECT_CONFIG_SETTINGS}"
    local VM_PROJECT_CONFIG_TEMPLATE="${PROJECT_CONFIG_TEMPLATE}"
    local VM_RAM=4096
    #local VM_NET2_NAME="dev-local-static-nat"
    local VM_NET2_SSH_PORT="22"
    export VM_NET2_RANGE="192.168.27.0/24"
    export VM_NET2_HOSTIP="192.168.27.1"
    export VM_NET2_IP="192.168.27.2"
    export VM_NET2_IP_LOCAL="192.168.27.2"
    export VM_NET2_NETMASK="255.255.255.0"
    export VM_NET3_HOSTIP="10.72.28.81"
    export VM_NET3_IP="10.72.28.80"
    export VM_NET3_DNS="10.72.40.33"
    export VM_NET3_ROUTE1="10.72.28.0/24"
    export VM_NET3_ROUTE2="10.72.28.250"
    local VM_NET2_EXIST
    local VM_NET3_EXIST
    local VM_NET_BRIDGE_EXIST
    local VM_EXIST
    local VM_STATUS_ISRUNNING
    debug "Using VM template: $VM_PROJECT_CONFIG_TEMPLATE" "info"
    debug "Using VM settings: $VM_PROJECT_CONFIG_SETTINGS" "info"
    debug "Using VM appliance: $VM_PATH" "info"
    debug "Using VM appliance in: $VM_OVA_PATH" "info"
    debug "Check Host Only Lan Exists: $VM_NET2_HOSTIP" "info"
    VM_NET2_EXIST="$(isVirtualBoxHostOnlyLanExists "$VM_NET2_HOSTIP")"
    debug "Check Host Only Lan Exists: $VM_NET3_HOSTIP" "info"
    VM_NET3_EXIST="$(isVirtualBoxHostOnlyLanExists "$VM_NET3_HOSTIP")"
    debug "Check Bridge Lan Exists" "info"
    VM_NET_BRIDGE_EXIST="$(getVirtualBoxFirstBridedLan)"
    debug "Check VM Exists: $VM_NAME" "info"
    VM_EXIST="$(isVirtualBoxVMExist "$VM_NAME")"
    debug "Check VM is Running: $VM_NAME" "info"
    VM_STATUS_ISRUNNING="$(isVirtualBoxVMRunning "$VM_NAME")"
    export VM_CREATED=false
#    local VM_DEPLOY_INVENTORY="inventory/localdev"
    local VM_NET_NEXUS_PORT="8081"
    local VM_STATUS_NEXUS
    debug "Check VM has Nexus Running: $VM_NET2_IP_LOCAL:$VM_NET_NEXUS_PORT" "info"
#    VM_STATUS_NEXUS="$(testHostPort "$VM_NET2_IP_LOCAL" "$VM_NET_NEXUS_PORT")"

    printSectionBanner "Verify VM Appliance" "error"

    debug "Check if VM has been build: $VM_PATH" "info"
    if [ -d "$VM_PATH" ]; then
        debug "Check if Appliance has been generated: $VM_OVA_PATH" "info"
        if [ -f "$VM_OVA_PATH" ]; then
            debug "VM Appliance already exist" "info"
        else
            debug "Deleting incomplete VM Appliance Build artifacts" "error"
            deleteVM "$VM_NAME" "$VM_PATH"
        fi
    fi

    printSectionBanner "Check Configurations" "warn"

    local VM_CONFIG_EXTENTIONS
    VM_CONFIG_EXTENTIONS=$(isVirtualExtensionInstalled)
    if [[ $(isEmpty "$VM_CONFIG_EXTENTIONS") == true ]]; then
        debug "Please install Oracle VM VirtualBox Extension Pack" "error"
        exit 0
    else
        debug "Oracle VM VirtualBox Extension Pack: $VM_CONFIG_EXTENTIONS" "info"
    fi
    debug "Check VM network availability" "info"

    debug "LAN1: '$VM_NET_BRIDGE_EXIST'" "info"
    debug "LAN2: '$VM_NET2_EXIST' [$VM_NET2_HOSTIP]" "info"
    debug "LAN3: '$VM_NET3_EXIST' [$VM_NET3_HOSTIP]" "info"

    debug "VM_EXIST ($VM_NAME): [$VM_EXIST] $(isNotEmpty "$VM_EXIST")" "info"
    debug "VM_STATUS_ISRUNNING ($VM_NAME): [$VM_STATUS_ISRUNNING] $(isNotEmpty "$VM_STATUS_ISRUNNING")" "info"

    debug "Check if VM project exists" "info"
    #check if VM project exists
    if [[ ! -d "$VM_PROJECT" ]] ; then
        debug "VM Project [$VM_PROJECT] Does Not Exists!" "warn"
        doInitAndGet
    else
        debug "VM Project [$VM_PROJECT] Exists!" "info"
    fi

    debug "Secure SSH Keys for injection into VM" "info"
    #secure SSH keys
    if [[ -d "$VM_PROJECT" ]] ; then
        local SSH_KEYS_SECURE
        SSH_KEYS_SECURE="$(doSecureSSHKeys "$VM_PROJECT")"
        debug "SSH Keys Secured in [$VM_PROJECT_SSH_KEYS]: $SSH_KEYS_SECURE" "info"
        if [[ "$SSH_KEYS_SECURE" == "false" ]]; then
            debug "VM Project keys could not be secured in path: $VM_PROJECT_SSH_KEYS" "info"
            exit
        fi
    fi

    printSectionBanner "Update VirtualBox Settings and Network Adapters" "warn"

    debug "Check First Boot VMControl Network" "info"
    #SETUP NETWORK
    #CREATE NEW HOST ONLY NETWORK WITH REQUIRED IP
    if [[ $(isEmpty "$VM_NET2_EXIST") == true ]]; then
        debug "Create Initial Host Only Adapter 2 [$VM_NET2_EXIST]" "info"
        VM_NET2_EXIST="$(doVirtualBoxCreateHostLan)"
#
        debug "New First Boot VMControl Host Only Adapter created [$VM_NET2_EXIST]" "info"

#        VM_CONFIG_EXTRAVARS="--limit=$VM_NET2_IP"

        doVirtualBoxUpdateHostOnlyLan "$VM_NET2_EXIST" "$VM_NET2_HOSTIP" "$VM_NET2_NETMASK"
    else
        debug "First Boot VMControl Network Exist: ${VM_NET2_EXIST}" "info"
    fi

    debug "Check VM Management Network" "info"
    if [[ $(isEmpty "$VM_NET3_EXIST") == true ]]; then
        debug "Create Management Host Only Adapter 3 [$VM_NET3_HOSTIP]" "info"
        VM_NET3_EXIST="$(doVirtualBoxCreateHostLan)"

        debug "New Initial Host Only Adapter created [$VM_NET3_EXIST]" "info"

        doVirtualBoxUpdateHostOnlyLan "$VM_NET3_EXIST" "$VM_NET3_HOSTIP" "$VM_NET2_NETMASK"
    else
        debug "VM Management Network Exist: $VM_NET3_EXIST" "info"
    fi

    printSectionBanner "Build VM Appliance" "warn"


    debug "Check if VM Appliance is Built" "info"
    #check if VM is Built
    if [[ ! -f "$VM_OVA_PATH" ]] ; then
        debug "VM Appliance does not exist!"

        debug "Check SSH Keys"
        doGenerateKeys

        debug "Building new VM"
        doBuildVM "$VM_PROJECT_CONFIG_SETTINGS" "$VM_PROJECT_CONFIG_TEMPLATE" "${VM_NET2_EXIST}" "$VM_NET3_EXIST"

        VM_EXIST="$(isVirtualBoxVMExist "$VM_NAME")"
        VM_STATUS_ISRUNNING="$(isVirtualBoxVMRunning "$VM_NAME")"

        debug "VM Status [$VM_NAME]: exists: $VM_EXIST; is running: $VM_STATUS_ISRUNNING;"

        if [[ -f "$VM_OVA_PATH" ]]; then
            debug "VM Build is Done!" "info"
        else
            debug "VM Build Failed!" "error"
            exit 1
        fi
    else
        debug "VM Appliance Already Built! $VM_OVA_PATH" "info"
    fi

    updateVirtualBox

    printSectionBanner "Configure VM" "warn"


    #check if VM Appliance exists, could mean it has been imported already
    if [[ $(isEmpty "$VM_EXIST") == true ]]; then
        debug "VM Does not exist trying to import from Appliance: $VM_OVA_PATH" "info"
        if [ -e "$VM_OVA_PATH" ]; then
            debug "Importing VM Appliance" "warn"
            doVirtualBoxImportVM "$VM_OVA_PATH" "$VM_NAME"
            VM_EXIST=$(isVirtualBoxVMExist "$VM_NAME")

            if [[ $(isEmpty "$VM_EXIST") == false ]]; then
                VM_CREATED=true
            fi

            #remove host IP's as its being imported
            doRemoveHostFromSSH "$VM_NET2_IP"

            #update VM settings
            updateVirtualBoxVMRam "$VM_NAME" "$VM_RAM"
            updateVirtualBoxVMClock "$VM_NAME"

            #debug "VM Network Exist: ${VM_NET2_EXIST}"
            updateVirtualBoxVMLan "$VM_NAME" "${VM_NET_BRIDGE_EXIST}" "${VM_NET2_EXIST}" "${VM_NET3_EXIST:-$VM_NET2_EXIST}"

            debug "VM [$VM_NAME] has just been Created, updating LAN to use IP [$VM_NET2_IP]!"  "info"

            doVirtualBoxUpdateHostOnlyLan "${VM_NET2_EXIST}" "$VM_NET2_HOSTIP" "$VM_NET2_NETMASK"

            VM_NET2_EXIST="$(isVirtualBoxHostOnlyLanExists "$VM_NET2_HOSTIP")"

            #expand existing drive
            debug "Expand [$VM_NAME] drive" "info"
            updateVirtualBoxVMDisk "$VM_NAME" "$VM_DISK_CONTROLER"

            #update cpus
            debug "Update [$VM_NAME] CPU config" "info"
            updateVirtualBoxCPU "$VM_NAME" 1

        else
            debug "VM Source not found" "info"
        fi
    else
        debug "VM [$VM_NAME] Already Imported!" "info"
    fi

    printSectionBanner "Start VM" "warn"


    #start VM
    if [[ $(isNotEmpty "$VM_EXIST") == true && $(isEmpty "$VM_STATUS_ISRUNNING") == true ]]; then
        doVirtualBoxStartVM "$VM_NAME"

        waitForHost "$VM_NET2_IP" "$VM_NET2_SSH_PORT"

        VM_STATUS_ISRUNNING="$(isVirtualBoxVMRunning "$VM_NAME")"
        debug "VM Started! $VM_STATUS_ISRUNNING" "info"
    else
        debug "VM Running! $VM_STATUS_ISRUNNING" "info"
    fi


    printSectionBanner "Local Dev Setup" "warn"


    #Start processing if running
    if [[ $(isNotEmpty "$VM_STATUS_ISRUNNING") == true ]]; then

        local VM_STATUS_SSH=""
        if [[ $(isNotEmpty "$VM_NET2_EXIST") == true ]]; then
            debug "Testing VM Local Access: $VM_NET2_IP_LOCAL $VM_NET2_SSH_PORT" "info"
            VM_STATUS_SSH="$(testHostPort $VM_NET2_IP_LOCAL $VM_NET2_SSH_PORT)"
            debug "VM_STATUS_SSH ($VM_NET2_IP): $VM_STATUS_SSH" "info"

            debug "Testing VM Nexus Service: $VM_NET2_IP_LOCAL $VM_NET_NEXUS_PORT" "info"
            VM_STATUS_NEXUS="$(testHostPort $VM_NET2_IP_LOCAL $VM_NET_NEXUS_PORT)"
            debug "VM_STATUS_NEXUS ($VM_NET2_IP): $VM_STATUS_NEXUS" "info"
        fi

        debug "Working with $VM_NET2_IP" "info"

        if [[ -n "$VM_NET2_IP" && $(isNotEmpty "$VM_STATUS_ISRUNNING") == true ]]; then

            # Do not do anything to VM outside of site.yml
#            #setup vm first time to work on Local Lan IP
#            if [[ -d "$PROJECT_DEPLOY" ]] ; then
#                debug "Working from Parent Folder ${DIR_ROOT}" "info"
#
#                debug "Checking if VM Has not been configured" "info"
#                if [[ $(isEmpty "$VM_STATUS_NEXUS") == true ]]; then
#                    debug "Configuring VM for the First Time" "error"
#
#                    debug "Use Initial VMControl IP Address: $VM_NET2_IP_LOCAL" "info"
##                    local VM_CONFIG_EXTRAVARS="--limit=$VM_NET2_IP"
#
#                    doBuildLocalDev
#
#                    debug "VM has been configured " "info"
#
#                    debug "Testing VM Nexus Service: $VM_NET2_IP_LOCAL $VM_NET_NEXUS_PORT" "info"
#                    VM_STATUS_NEXUS="$(testHostPort $VM_NET2_IP_LOCAL $VM_NET_NEXUS_PORT)"
#                    debug "VM_STATUS_NEXUS ($VM_NET2_IP): $VM_STATUS_NEXUS" "info"
#
#                else
#                    debug "VM Has already been configured" "info"
#                    debug "VM is accessible on: $VM_NET2_IP_LOCAL" "info"
#                fi
#            fi
            debug "VM is accessible on: $VM_NET2_IP_LOCAL" "info"

            debug "NEXT STEPS: install services in local vm [$VM_NET2_IP_LOCAL] run:" "warn"
            debug "./devops deploylocaldev" "warn"
            debug "Executing in 10 sec" "info"

            doTimeout 10
            doDeployLocal

        else
            debug "Could not determine IP address to finalise config of VM" "warn"
        fi
    else
        debug "VM '$VM_NAME' does not Exist!"
    fi

# No need to upload to nexus as all containers are build globally (hub.docker.com)
#    if [[ $(isEmpty "$VM_STATUS_NEXUS") == false ]]; then
#
#        debug "NEXT STEPS: upload AEM jar to nexus on [$VM_NET2_IP_LOCAL] run:" "warn"
#        debug "cd $PROJECT_AEM && ./upload-nexus" "warn"
#        debug "Executing in 10 sec" "info"
#
#        doTimeout 10
#        doUploadToNexus
#
#        debug "NEXT STEPS: install services in local vm [$VM_NET2_IP_LOCAL] run:" "warn"
#        debug "./devops deploylocaldev" "warn"
#        debug "Executing in 10 sec" "info"
#
#        doTimeout 10
#        doDeployLocal
#
#    fi

    if [[ $(isEmpty "$VM_STATUS_SSH") == true ]]; then

        debug "NEXT STEPS: access local vm [$VM_NET2_IP_LOCAL] run:" "warn"
        debug "./devops accesslocal" "warn"

        debug "Executing in 10 sec" "info"
        doTimeout 10
        doAccessLocalVM

    fi
}

