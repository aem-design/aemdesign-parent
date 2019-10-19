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
    CHECK_PYTHON3_VERSION="$($CHECK_PYTHON3 -c 'import platform; print(platform.python_version())')"

    debug "PIP3=${CHECK_PIP3}" "info"
    debug "PYTHON3=${CHECK_PYTHON3}" "info"
    debug "PYTHON3_VERSION=${CHECK_PYTHON3_VERSION}" "info"

    if [[  -z "$CHECK_PYTHON3" ]]; then

        debug "PLEASE INSTALL PYTHON3" "error"
        exit 1
    fi

}

