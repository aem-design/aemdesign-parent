#!/bin/bash

export DEFAULT_SSL_LIBRARY
export DEFAULT_SSL_PATH
export DEFAULT_VIRTUALENV_HOME

DEFAULT_SSL_LIBRARY=openssl
DEFAULT_SSL_PATH="/usr/local/opt/openssl"
DEFAULT_VIRTUALENV_HOME="$HOME/.virtualenvs"

function doPythonInstallModules() {

    pip install --ignore-installed pycrypto BeautifulSoup4 xmltodict paramiko PyYAML Jinja2 httplib2 boto boto3 xmltodict six requests python-consul passlib cryptography appdirs packaging boto docker-compose docker awscli ansible

}

function doPythonConfig() {

    local CHECK_PIP3
    local CHECK_PYTHON3
    local CHECK_VIRTUALENV
    local CHECK_VIRTUALENVWRAPPER

    CHECK_PIP3="$(which pip3 2>/dev/null)"
    CHECK_PYTHON3="$(which python3 2>/dev/null)"
    CHECK_PYTHON3_VERSION="$($CHECK_PYTHON3 -c 'import platform; print(platform.python_version())')"
    CHECK_VIRTUALENV="$(which virtualenv 2>/dev/null)"
    CHECK_VIRTUALENVWRAPPER="$(find /usr -name virtualenvwrapper.sh 2>/dev/null | head -n 1)"

    debug "CHECK_PIP3=${CHECK_PIP3}" "info"
    debug "CHECK_PYTHON3=${CHECK_PYTHON3}" "info"
    debug "CHECK_PYTHON3_VERSION=${CHECK_PYTHON3_VERSION}" "info"
    debug "CHECK_VIRTUALENV=${CHECK_VIRTUALENV}" "info"
    debug "CHECK_VIRTUALENVWRAPPER=${CHECK_VIRTUALENVWRAPPER}" "info"

    if [[ ! -z "$CHECK_PYTHON3" ]]; then

        debug "Make new virtual environment: ${PYTHON_ENV}" "info"
        mkvirtualenv "${PYTHON_ENV}"

        doPythonActivateEnv

    else

        debug "PLEASE INSTALL PYTHON3 AND ITS DEPENDENCIES" "error"
        debug "pip3 virtualenv virtualenvwrapper workon" "error"
        exit 1
    fi
}

function doPythonActivateEnv() {

    #load virtenv functions
    if [ ! -z "$VIRTUALENVWRAPPER" ]; then
        debug "Loading $VIRTUALENVWRAPPER" "info"
        # shellcheck disable=SC1094
        source "${VIRTUALENVWRAPPER}"
    else
        doPythonConfig
    fi

    debug "Activate python env: ${PYTHON_ENV}" "info"
    workon "${PYTHON_ENV}"
    debug "Using Python: $(python --version 2>&1)" "info"

    debug "WORKON_HOME=${WORKON_HOME}" "info"
    debug "VIRTUALENVWRAPPER_PYTHON=${VIRTUALENVWRAPPER_PYTHON}" "info"
    debug "VIRTUALENVWRAPPER_VIRTUALENV=${VIRTUALENVWRAPPER_VIRTUALENV}" "info"
    debug "PYTHON_ENV=${PYTHON_ENV}" "info"

}

function doPythonCheck() {

    debug "Python Check" "info"

    local DEFAULT_PYTHON
    DEFAULT_PYTHON="$(which python3 2>/dev/null)"
    local CHECK_ALREADYINVIRTENV
    CHECK_ALREADYINVIRTENV="$($DEFAULT_PYTHON -c "import sys; print(hasattr(sys, 'real_prefix'))")"
    local CHECK_PYTHON_VERSION
    CHECK_PYTHON_VERSION="$($DEFAULT_PYTHON -c 'import platform; print(platform.python_version())')"


    if [ "$CHECK_ALREADYINVIRTENV" == "True" ]; then
        debug "Already running in virtual env" "info"
    else

        #if set activate env, no config
        if [ ! -z "$PYTHON_ENV" ] || [ "$PYTHON_VERSION" != "$CHECK_PYTHON_VERSION" ]; then
            doPythonActivateEnv
        else
            if [ "$PYTHON_VERSION" != "$CHECK_PYTHON_VERSION" ]; then
                debug "Python version has configured, configuring" "error"
            else
                debug "Python not configured, configuring" "error"
            fi
            doPythonConfig

            debug "Ensure modules are installed: ${PYTHON_ENV}" "info"
            doPythonInstallModules

        fi

    fi

    PYTHONPATH="$(python -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")"

    debug "PYTHONPATH=${PYTHONPATH}" "info"

}

function updatePythonEnv() {
    local DEFAULT_PROFILE="$DEFAULT_USER_PROFILE"
    local DEFAULT_PYTHON
    local DEFAULT_VIRTUALENV
    local DEFAULT_VIRTUALENVWRAPPER
    DEFAULT_PYTHON="$(which python 2>/dev/null)"
    DEFAULT_PYTHON_VERSION="$($DEFAULT_PYTHON -c 'import platform; print(platform.python_version())')"
    DEFAULT_VIRTUALENV="$(which virtualenv 2>/dev/null)"
    DEFAULT_VIRTUALENVWRAPPER="$(find /usr -name virtualenvwrapper.sh 2>/dev/null | head -n 1)"
    local WHICH_PYTHON_ENV="${1:-aemdesign.py}"
    local WHICH_PYTHON="${2:-$DEFAULT_PYTHON}"
    local WHICH_PYTHON_VERSION="${3:-$DEFAULT_PYTHON_VERSION}"
    local WHICH_VIRTUALENV="${4:-$DEFAULT_VIRTUALENV}"
    local WHICH_PROFILE="${5:-$DEFAULT_PROFILE}"
    local WHICH_VIRTUALENVWRAPPER="${6:-$DEFAULT_VIRTUALENVWRAPPER}"
    local WHICH_VIRTUALENV_HOME="${7:-$DEFAULT_VIRTUALENV_HOME}"

#    debug "Removing python config from $WHICH_PROFILE" "info"
#    removeLineFromFile "export PYTHON_ENV" "$WHICH_PROFILE"
#    removeLineFromFile "export PYTHON_VERSION" "$WHICH_PROFILE"
#    removeLineFromFile "export WORKON_HOME" "$WHICH_PROFILE"
#    removeLineFromFile "export VIRTUALENVWRAPPER_PYTHON" "$WHICH_PROFILE"
#    removeLineFromFile "export VIRTUALENVWRAPPER_VIRTUALENV" "$WHICH_PROFILE"
#    removeLineFromFile "export VIRTUALENVWRAPPER" "$WHICH_PROFILE"
#    removeLineFromFile "source \$VIRTUALENVWRAPPER" "$WHICH_PROFILE"

    debug "Adding python config from $WHICH_PROFILE" "info"
    addLineToFile "export PYTHON_ENV=$WHICH_PYTHON_ENV" "$WHICH_PROFILE"
    addLineToFile "export PYTHON_VERSION=$WHICH_PYTHON_VERSION" "$WHICH_PROFILE"
    addLineToFile "export WORKON_HOME=$WHICH_VIRTUALENV_HOME" "$WHICH_PROFILE"
    addLineToFile "export VIRTUALENVWRAPPER_PYTHON=$WHICH_PYTHON" "$WHICH_PROFILE"
    addLineToFile "export VIRTUALENVWRAPPER_VIRTUALENV=$WHICH_VIRTUALENV" "$WHICH_PROFILE"
    addLineToFile "export VIRTUALENVWRAPPER=$WHICH_VIRTUALENVWRAPPER" "$WHICH_PROFILE"
    addLineToFile "source \$VIRTUALENVWRAPPER" "$WHICH_PROFILE"
#    source ~/.bashrc

    export PYTHON_ENV="$WHICH_PYTHON_ENV"
    export PYTHON_VERSION="$WHICH_PYTHON_VERSION"
    export WORKON_HOME="$WHICH_VIRTUALENV_HOME"
    export VIRTUALENVWRAPPER_PYTHON="$WHICH_PYTHON"
    export VIRTUALENVWRAPPER_VIRTUALENV="$WHICH_VIRTUALENV"
    export VIRTUALENVWRAPPER="$WHICH_VIRTUALENVWRAPPER"

    # shellcheck disable=SC1094
    source "$WHICH_VIRTUALENVWRAPPER"

}
