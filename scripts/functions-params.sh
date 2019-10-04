#!/bin/bash


### DEFAULT PARAMS
export DIR_INC
export DIR_ROOT
export DIR_CURRENT
export SCRIPT_NAME
export SCRIPT_PATH
export SCRIPT_ARGS
export SCRIPT_ARG_1
export SCRIPT_ARG_2
export FLAG_DEBUG
export FLAG_DEBUG_LEVEL
export FLAG_DEBUG_LABEL
export FLAG_DEBUG_PAUSE

DIR_INC=${DIR_INC:-}
DIR_ROOT=${DIR_ROOT:-}
DIR_CURRENT=${0%/*}
SCRIPT_NAME=${0##*/}
SCRIPT_PATH=${0}
SCRIPT_ARGS=$*
SCRIPT_ARG_1=${1:-}
SCRIPT_ARG_2=${2:-}
FLAG_DEBUG=${FLAG_DEBUG:-true}
FLAG_DEBUG_LEVEL=${FLAG_DEBUG:-info}
FLAG_DEBUG_LABEL=${FLAG_DEBUG_LABEL:-false}
FLAG_DEBUG_PAUSE=${FLAG_DEBUG_PAUSE:-false}

function lowercase() {
    #echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
    echo "$1" | awk '{print tolower($0)}'
}

#getScriptArgsAfter(startfrom)
function getOtherScriptArgs() {
    local SCRIPT_ARGS_ARRAY=( $SCRIPT_ARGS )
    echo "${SCRIPT_ARGS_ARRAY[@]:$1}"
}

function getOs() {
    lowercase "$(uname -a | grep Microsoft -q && echo windowsnt || uname)"
}

OS="$(getOs)"

if [[ "$OS" == "windowsnt" || "$OS" == *"mingw"* || "$OS" == *"cygwin"*  ]]; then
    OS=windows
fi