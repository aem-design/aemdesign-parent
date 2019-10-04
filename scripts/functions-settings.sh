#!/bin/bash

##getSettingValue(setting,path)
#function getSettingValue {
#    local CURRENTPATH=`dirname $0`
#    local FILEPATH=${2:-$CURRENTPATH}
#    echo $(FILEPATH=$FILEPATH; cd $FILEPATH && grep -m 1 -e "$1" -F "$FILEPATH/Dockerfile" | awk -F"=" '{ print $2 }')
#}

#getSettingValue search,infile,separator
function getSettingValue {
    local DEFAULT_SEPARATOR="="
    local SEPARATOR="${3:-$DEFAULT_SEPARATOR}"

    grep -m 1 -E -i -w "$1" "$2" | awk -F"$SEPARATOR" '{ print $2; exit}'

}


function getValue {
    local DEFAULT_SEPARATOR="="
    local SEPARATOR="${3:-$DEFAULT_SEPARATOR}"

    echo "$2" | grep -m 1 -E -i -w "$1" | awk -F"$SEPARATOR" '{ print $2; exit}'

}


function removeLineFromFile() {
    local FINDTEXT=$1
    local INFILE=$2

    sed -i -n "/$FINDTEXT/!p" "$INFILE"
}

function addLineToFile() {
    local ADDTEXT=$1
    local TOFILE=$2

    echo "$ADDTEXT">>"$TOFILE"
}