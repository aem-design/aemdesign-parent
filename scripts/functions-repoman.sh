#!/bin/bash

REPOS_SSH_KEY="$(realpath ~/.ssh/id_rsa)"

REPO_PARENT="git@github.com:aem-design/aemdesign-parent.git"

export REPOLIST
REPOLIST[0]="git@github.com:aem-design/aemdesign-aem-core.git"
REPOLIST[1]="git@github.com:aem-design/aemdesign-aem-support.git"
REPOLIST[2]="git@github.com:aem-design/aemdesign-operations.git"
REPOLIST[3]="git@github.com:aem-design/aemdesign-archetype.git"

function doAddKey() {

    debug "Using key for git operations: $REPOS_SSH_KEY"

    if [ -f "$REPOS_SSH_KEY" ]; then
        KEY_ADDED="$(ssh-add -l | grep "$REPOS_SSH_KEY")"
        if [ "$KEY_ADDED" == "" ]; then
            debug "Adding to ssh agent..." "warn"
            ssh-add "$REPOS_SSH_KEY"
        else
            debug "Already added..." "warn"
        fi
    fi

}

function getRepoName() {
    echo "$1"| sed -n "s/.*\/\(.*\)\.git/\1/p"
}

#doRepoClone(REPO_NAME,REPO_ADDRESS)
function doRepoClone() {
    local REPO_NAME=${1:?Need repo name}
    local REPO_ADDRESS=${2:?Need repo address}
    if [ ! -d "$REPO_NAME" ]; then
        debug "$REPO_NAME: Cloning" "warn"
        git clone "$REPO_ADDRESS"
        cd "$REPO_NAME" && git lfs install || true && cd - || return
    else
        debug "$REPO_NAME: Already Exists" "warn"
    fi

}

#doRepoFetchLfs(REPO_NAME,REPO_ADDRESS)
function doRepoFetchLfs() {
    local REPO_NAME=${1:?Need repo name}
    local REPO_ADDRESS=${2:?Need repo address}
    if [ ! -d "$REPO_NAME" ]; then
        debug "$REPO_NAME: Does not exist" "warn"
        doRepoClone "$REPO_NAME" "$REPO_ADDRESS"
    fi

    debug "$REPO_NAME: Fetching Large Files" "warn"
    cd "$REPO_NAME" && git lfs fetch || true && cd - || return

}

#doRepoPushLfs(REPO_NAME,REPO_ADDRESS)
function doRepoPushLfs() {
    local REPO_NAME=${1:?Need repo name}
    local REPO_ADDRESS=${2:?Need repo address}
    if [ ! -d "$REPO_NAME" ]; then
        debug "$REPO_NAME: Does not exist" "warn"
        doRepoClone "$REPO_NAME" "$REPO_ADDRESS"
    fi

    debug "$REPO_NAME: Pushing Large Files" "warn"
    cd "$REPO_NAME" && git lfs push || true && cd - || return

}

#doRepoPullLfs(REPO_NAME,REPO_ADDRESS)
function doRepoPullLfs() {
    local REPO_NAME=${1:?Need repo name}
    local REPO_ADDRESS=${2:?Need repo address}
    if [ ! -d "$REPO_NAME" ]; then
        debug "$REPO_NAME: Does not exist" "warn"
        doRepoClone "$REPO_NAME" "$REPO_ADDRESS"
    fi

    debug "$REPO_NAME: Pulling Large Files" "warn"
    cd "$REPO_NAME" && git lfs pull || true && cd - || return

}

#doRepoPush(REPO_NAME,REPO_ADDRESS)
function doRepoPush() {
    local REPO_NAME=${1:?Need repo name}
    local REPO_ADDRESS=${2:?Need repo address}
    if [ -d "$REPO_NAME" ]; then
        debug "$REPO_NAME: Pushing updates" "warn"
        cd "$REPO_NAME" && git push || true && cd - || return
    else
        debug "$REPO_NAME: Does not exist" "warn"
        doRepoClone "$REPO_NAME" "$REPO_ADDRESS"
    fi

}

#doRepoPull(REPO_NAME,REPO_ADDRESS)
function doRepoPull() {
    local REPO_NAME=${1:?Need repo name}
    local REPO_ADDRESS=${2:?Need repo address}
    if [ -d "$REPO_NAME" ]; then
        debug "$REPO_NAME: Pulling updates" "warn"
        cd "$REPO_NAME" && git pull || true && cd - || return
    else
        debug "$REPO_NAME: Repo does not exists locally, cloning" "warn"
        doRepoClone "$REPO_NAME" "$REPO_ADDRESS"
    fi

}

#doRepoPull(REPO_NAME,REPO_ADDRESS)
function doRepoStatus() {
    local REPO_NAME=${1:?Need repo name}
    local REPO_ADDRESS=${2:?Need repo address}
    if [ -d "$REPO_NAME" ]; then
        debug "$REPO_NAME: Checking status" "warn"
        cd "$REPO_NAME" && git status || true && cd - || return
    else
        debug "$REPO_NAME: Repo does not exists locally, cloning" "warn"
        doRepoClone "$REPO_NAME" "$REPO_ADDRESS"
    fi

}


#doRepoStashList(REPO_NAME,REPO_ADDRESS)
function doRepoStashList() {
    local REPO_NAME=${1:?Need repo name}
    local REPO_ADDRESS=${2:?Need repo address}
    if [ -d "$REPO_NAME" ]; then
        debug "$REPO_NAME: Checking stash" "warn"
        cd "$REPO_NAME" && git stash list && cd - || return
    else
        debug "$REPO_NAME: Does not exist" "warn"
    fi

}

function doReposClone() {

#    npm-run repoman init

    doAddKey

    debug "GIT SUBMODULE: UPDATE" "warn"
    git submodule update --recursive --remote

    doReposPull

}

function doReposPull() {

#    npm-run repoman get

    doAddKey

    doReposStatus

    debug "PARENT: PULL" "warn"
    git pull

    debug "PARENT: LFS PULL" "warn"
    git lfs pull

    debug "GIT SYNC ALL SUBMODULES" "warn"
    git submodule sync

    debug "GIT INIT ALL NEW SUBMODULES" "warn"
    git submodule update --remote --init

    debug "GIT ATTACH SUBMODULE HEADS" "warn"
    git submodule foreach '(git status | grep "HEAD detached") && git checkout master || true'

    debug "GIT PULL ALL SUBMODULES" "warn"
    git submodule foreach "git pull"

    debug "GIT LFS PULL ALL SUBMODULE" "warn"
    git submodule foreach "git lfs pull"

}

function doReposStashList() {

#    npm-run repoman get

    doAddKey

    debug "GIT SUBMODULE: PULL" "warn"
    git submodule foreach git stash list

    debug "PARENT: STASH LIST" "warn"
    git stash list


}

function doReposPush() {

#    npm-run repoman save

    doAddKey

    debug "GIT SUBMODULE: PUSH" "warn"
    git submodule foreach git push

    debug "GIT SUBMODULE: LFS PUSH" "warn"
    git submodule foreach git lfs push

    debug "PARENT: PUSH" "warn"
    git push

    debug "PARENT: LFS PUSH" "warn"
    git lfs push


}

#doRepoCheckout()
function doRepoCheckout() {
    local REPO_BRANCH=$ACTION_PARAMS

    if [[ -z $REPO_BRANCH ]]; then
        REPO_BRANCH="master"
    fi

    debug "PARENT ACTION: CHECKOUT $REPO_BRANCH IN ALL SUBMODULES" "warn"
    git submodule foreach --recursive git checkout $REPO_BRANCH

}

#doRepoStash()
function doRepoStash() {

    debug "PARENT ACTION: STASH IN ALL SUBMODULES" "warn"
    git submodule foreach --recursive git stash

}

#doRepoStashPop()
function doRepoStashPop() {

    debug "PARENT ACTION: STASH POP IN ALL SUBMODULES" "warn"
    git submodule foreach --recursive git stash pop

}

function doReposStatus() {

#    npm-run repoman changes

    doAddKey

    printSectionBanner "DETACHED HEAD CHECK" "warn"

    debug "GIT DETACHED HEAD IN:" "warn"
    git submodule foreach `git status | grep "HEAD detached" -B 1 | head -n 1 | awk -F "'" '{print "\033[0;31;93m -> " $2 "\033[0m"}'`
    git status | grep "HEAD detached" -B 1 | head -n 1 | awk -F "'" '{print "\033[0;31;93m -> " $2 "\033[0m"}'

    printSectionBanner "ALL REPOS WILL BE CHECKOUT TO MASTER" "error"

    printSectionBanner "REPO CHANGES CHECK" "warn"
    debug "UNCOMMITED CHANGES IN:" "warn"

    git submodule foreach 'if [ "$(git diff --name-only)" != "" ]; then echo "\033[0;31;93m -> CHANGED TO COMMIT: $(git diff --name-only | grep . -c)\033[0m"; fi'

    if [[ "$(git diff --name-only)" != "" ]]; then
        debug "$(basename $(pwd))" "warn"
        debug " -> CHANGED TO COMMIT: $(git diff --name-only | grep . -c)" "warn"
    fi

    printSectionBanner "PLEASE STASH YOUR CHANGES" "error"

}


function doReposReset() {

#    npm-run repoman save

    doAddKey

    printSectionBanner "THIS WILL RESET ALL YOUR MODULES TO MASTER" "error"

    echo -n "Enter [RESET ALL REPOS] and press [ENTER]: "
    read RESETALL

    if [[ "$RESETALL" == "RESET ALL REPOS" ]]; then


        debug "GIT PARENT CLEAN" "error"
        git clean -xdf

        debug "GIT PULL CHECKOUT MASTER" "error"
        git pull master origin master

        debug "GIT PARENT CHECKOUT MASTER" "error"
        git checkout master --force

        debug "GIT CLEAN ALL SUBMODULES" "error"
        git submodule foreach "git clean -xdf"

        debug "GIT PULL ALL SUBMODULES" "error"
        git submodule foreach "git pull origin master"

        debug "GIT CHECKOUT ALL SUBMODULES" "error"
        git submodule foreach "git checkout master --force"


    else
        printSectionBanner "ABORTED" "warn"
        exit 1
    fi


}
