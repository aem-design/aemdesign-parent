#!/bin/bash

#ENVIRONMENT

#checkRoot
function checkRoot {
    if [ ! "$OS" == "windows" ]; then
        checkUser "root" "please run as: \n sudo $0 $OS"
    fi
}

#checkUser(user,message)
function checkUser {
    local CURRENT_USER=${USER:-none}
    if [[ "$CURRENT_USER" != "$1" ]]; then
        debug "$2" "error"
        exit 1
    fi
}

##setEnvVar(variable,value)
#function setEnvVar {
#    local envVarName=`echo "$1" | sed 's/[PMX_]+//g'`
#    echo $"`sed  "/$envVarName=/d" $ENV`" > $ENV
#    echo export $1=$2 >> $ENV
#}

#setEnv(buildpath)
function setBuilEnvs {

    printEnvVars
}

function printEnvVars {
    debug ""
    debug "===:: Environment Variables ::========================================="
    debug "DIR_ROOT=$DIR_ROOT"
    debug "DIR_INC=$DIR_INC"
    debug "DIR_CURRENT=$DIR_CURRENT"
    debug "SCRIPT_NAME=$SCRIPT_NAME"
    debug "SCRIPT_PATH=$SCRIPT_PATH"
    debug "SCRIPT_ARGS=$SCRIPT_ARGS"
    debug "SCRIPT_ARG_1=$SCRIPT_ARG_1"
    debug "SCRIPT_ARG_2=$SCRIPT_ARG_2"
    debug "FLAG_DEBUG=$FLAG_DEBUG"
    debug "FLAG_DEBUG_LEVEL=$FLAG_DEBUG_LEVEL"
    debug "FLAG_DEBUG_LABEL=$FLAG_DEBUG_LABEL"
    debug "======================================================================="
    debug ""

}

function getExternalIp {
    /sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
}

function getLoopbackIp {
    /sbin/ifconfig lo | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'
}

function goToBuildDir {
    cd "${BUILD_PATH:-.}" || return
}


function getTimestamp() {
    date +"%s"
}

function fixPath() {
    local FIX_PATH="$1"
    local OS_CURRENT
    OS_CURRENT="$(getOs)"

    if [[ "$OS_CURRENT" == *"cygwin"*  ]]; then
        FIX_PATH="$(cygpath -m "$FIX_PATH")"
    elif [[ "$OS_CURRENT" == *"mingw"* ]]; then
        FIX_PATH="$(echo "$FIX_PATH" | sed -e 's/\\/c//')"
    elif [[ "$OS_CURRENT" == *"windows"* ]]; then
        FIX_PATH="$(echo "$FIX_PATH" | sed -E 's+^/mnt/(.{1})+\1:+' | sed 's+:$+:/+1' )"
    fi
    echo "$FIX_PATH"
}