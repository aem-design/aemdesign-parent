#!/bin/bash


function doBuildPrototype() {

    checkProjectExist "$PROJECT_PROTOTYPE"

    cd "$PROJECT_PROTOTYPE" && ./build.sh || return

}


