#!/bin/bash

#LOGIC


#findInString(source,search,success,fail)
function findInString {
    if [[ $1 == *"$2"* ]]; then
        echo true
    else
        echo false
    fi
}

#findNotInString(source,search,success,fail)
function findNotInString {
    if [[ $1 == *"$2"* ]]; then
        echo false
    else
        echo true
    fi
}

function isNotEmpty {

    local PARAM="${1:-}"

    if [ -n "$PARAM" ]; then
            echo true
        else
            echo false
    fi

}

function isEmpty {

    local PARAM="${1:-}"

    if [ "$PARAM" == "" ]; then
        echo true
    else
        echo false
    fi

}

function join { local IFS="$1"; shift; echo "$*"; }