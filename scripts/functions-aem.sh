#!/bin/bash

function doAEMStartAuthor() {

    checkProjectExist "$PROJECT_AEM"

    cd "$PROJECT_AEM/author" && ./start && cd - || return

}

function doAEMStartPublish() {

    checkProjectExist "$PROJECT_AEM"

    cd "$PROJECT_AEM/publish" && ./start && cd - || return

}



function doAEMStopAuthor() {

    checkProjectExist "$PROJECT_AEM"

    cd "$PROJECT_AEM/author" && ./stop && cd - || return

}

function doAEMStopPublish() {

    checkProjectExist "$PROJECT_AEM"

    cd "$PROJECT_AEM/publish" && ./stop && cd - || return

}


function doAEMStartBoth() {

    checkProjectExist "$PROJECT_AEM"

    cd "$PROJECT_AEM" && ./start && cd - || return

}



function doAEMStopBoth() {

    checkProjectExist "$PROJECT_AEM"

    cd "$PROJECT_AEM" && ./stop && cd - || return

}
