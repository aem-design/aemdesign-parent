#!/bin/bash

MENU_MESSAGE="Please use following actions: "

# ADD NEW MENU HELP ITEMS
export MENULIST
MENULIST[0]="help - show help"
MENULIST[1]="quit - show nice logo"
MENULIST[2]="install - install of dependencies run as ROOT"
MENULIST[3]="clone - get configured repos"
MENULIST[4]="pull - get updates for all repos"
MENULIST[5]="push - push changes for all repos"
MENULIST[6]="status - view changes for all repos"
MENULIST[7]="buildpr - build prototype"
MENULIST[8]="startaut - run author node"
MENULIST[9]="startpub - run publisher node"
MENULIST[10]="startauthpub - run author and publisher nodes together"
MENULIST[11]="stopaut - run author node"
MENULIST[12]="stoppub - run publisher node"
MENULIST[13]="stopauthpub - run author and publisher nodes together"
MENULIST[14]="buildlocaldev - build a VM for development"
MENULIST[15]="accesslocal - ssh into local VM"
MENULIST[16]="deploylocaldev - run a playbook to deploy services to localdev"
MENULIST[17]="stashlist - show list of stash for all repos"
MENULIST[18]="quickstart - automated run from freshly cloned parent repo"
MENULIST[19]="resetrepos - reset all repos to master"
MENULIST[20]="checkout - checkout a branch on all submodules"
MENULIST[21]="stash - stash on all submodules"
MENULIST[22]="stash pop - stash pop on all submodules"
MENULIST[23]="dockerlocaldev - build localdev using local docker "

# ADD RELATED COMMAND FOR MENU ITEMS
export MENUCOMMAND
MENUCOMMAND[0]="showLongHelp"
MENUCOMMAND[1]="quit"
MENUCOMMAND[2]="doDependencyInstall"
MENUCOMMAND[3]="doReposClone"
MENUCOMMAND[4]="doReposPull"
MENUCOMMAND[5]="doReposPush"
MENUCOMMAND[6]="doReposStatus"
MENUCOMMAND[7]="doBuildPrototype"
MENUCOMMAND[8]="doAEMStartAuthor"
MENUCOMMAND[9]="doAEMStartPublish"
MENUCOMMAND[10]="doAEMStartBoth"
MENUCOMMAND[11]="doAEMStopAuthor"
MENUCOMMAND[12]="doAEMStopPublish"
MENUCOMMAND[13]="doAEMStopBoth"
MENUCOMMAND[14]="doBuildLocal"
MENUCOMMAND[15]="doAccessLocalVM"
MENUCOMMAND[16]="doDeployLocal"
MENUCOMMAND[17]="doReposStashList"
MENUCOMMAND[18]="doQuickstart"
MENUCOMMAND[19]="doReposReset"
MENUCOMMAND[20]="doRepoCheckout"
MENUCOMMAND[21]="doRepoStash"
MENUCOMMAND[22]="doRepoStashPop"
MENUCOMMAND[23]="doBuildLocalDevDocker"


function showHelp {
    debug "Usage:"

    debug "    ./devops {action} {action_params ...}" "info" "\n"
}

function showLongHelp {
    installAutoComplete
    showHelp
    debug "$MENU_MESSAGE"

    local MENUCOUNT=0
    while [ "${MENULIST[$MENUCOUNT]:-x}" != "x" ]
    do
        debug "    ${MENULIST[$MENUCOUNT]}" "info"
        MENUCOUNT=$(( MENUCOUNT + 1 ))
    done

    debug "" "" "\n"

}

function quit {
    tput clear
    displayLogo
    debug "    Thank you!" "info" "\n"
    exit 0;
}

function showStatsInfo() {
    debug "$(printf '*%.0s' {1..100})" "error"
    debug "Please note execution of all commands will be logged and submitted to Slack for debugging." "error"
    debug "$(printf '*%.0s' {1..100})" "error"
}


function getMenuNamesList() {
    local MENUCOUNT=0
    local MENUTERMS=""
    while [ "${MENULIST[MENUCOUNT]:-}" != "" ]
    do
        local TERM=(${MENULIST[MENUCOUNT]})
        MENUTERMS="${MENUTERMS} ${TERM[0]}"
        MENUCOUNT=$(( MENUCOUNT + 1 ))
    done
    echo "$MENUTERMS"
}

function _autoCompleteMenu() {
    local cur
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"

    COMPREPLY=( $(compgen -W "$(getMenuNamesList)" -- "${cur}") )

    return 0
}

function installAutoComplete() {
    local INCLUDEFILE
    INCLUDEFILE="source $(realpath ./scripts/functions-menu.sh)"

    local CHECK_LINE
    CHECK_LINE="$(grep "$INCLUDEFILE" "$DEFAULT_USER_PROFILE")"

    if [ -z "$CHECK_LINE" ]; then
        addLineToFile "$INCLUDEFILE" "$DEFAULT_USER_PROFILE"
        debug "Installing Auto Complete Helpers"
    fi

}

function setupAutoComplete() {
    complete -F _autoCompleteMenu -o filenames ./devops ./devops-cli
}

#if file being sourced do autocomplete
if [[ $_ != "$0" ]]; then
    setupAutoComplete
fi