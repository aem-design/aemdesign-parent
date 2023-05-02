#!/bin/bash

export DEFAULT_SSL_LIBRARY
export DEFAULT_SSL_PATH
export DEFAULT_VIRTUALENV_HOME

DEFAULT_SSL_LIBRARY=openssl
DEFAULT_SSL_PATH="/usr/local/opt/openssl"
DEFAULT_VIRTUALENV_HOME="$HOME/.virtualenvs"


function doPythonCheck() {

    debug "Python Check" "info"

    CHECK_PIP3="$(which pip3 2>/dev/null)"
    CHECK_PYTHON3="$(which python3 2>/dev/null)"
    CHECK_PYTHON3_VERSION="$(${CHECK_PYTHON3} -c 'import platform; print(platform.python_version())')"
    CHECK_VIRTUALENV="$(which virtualenv 2>/dev/null)"
    CHECK_VIRTUALENVWRAPPER="$(find /usr -name virtualenvwrapper.sh 2>/dev/null | head -n 1)"
    PYTHON_ENV="$PROJECT_CONFIG_PREFIX.${CHECK_PYTHON3_VERSION}"

    debug "PIP3=${CHECK_PIP3}" "info"
    debug "PYTHON3=${CHECK_PYTHON3}" "info"
    debug "PYTHON3_VERSION=${CHECK_PYTHON3_VERSION}" "info"
    debug "PYTHON_ENV=${PYTHON_ENV}" "info"
    debug "CHECK_VIRTUALENVWRAPPER=${CHECK_VIRTUALENVWRAPPER}" "info"

    if [[  -z "$CHECK_PYTHON3" ]]; then
        debug "PLEASE INSTALL PYTHON3" "error"
        exit 1
    fi

    if [ ! -z "$VIRTUALENVWRAPPER" ]; then
        debug "Loading $VIRTUALENVWRAPPER" "info"
        # shellcheck disable=SC1094
        source "${VIRTUALENVWRAPPER}"

        doCreatePythonEnvironment "${PYTHON_ENV}"

#        doWorkOnPythonEnvironment "${PYTHON_ENV}"

        debug "Testing Python version" "info"
        CHECK_PYTHON="$(which python 2>/dev/null)"

        debug "Detected Python in Virtual Environment ${CHECK_PYTHON}" "info"

    else
        debug "Virtual Environment Wrapper does not exist please install before continuing." "error"
        exit 1
    fi

}

function doWorkOnPythonEnvironment() {
    if [[ ! -z $1 ]]; then
        debug "Attempting activate Python environment: $1"
        workon "$1"
    else
        debug "Please specify environment name" "error"
        exit 1
    fi
}

function doCreatePythonEnvironment() {
    if [[ ! -z $1 ]]; then
        debug "Attempting to create new environment: $1"
        mkvirtualenv "$1"
    else
        debug "Please specify environment name" "error"
        exit 1
    fi
}