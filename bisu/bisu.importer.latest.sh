#!/usr/bin/env bash
######################################################## BISU Importer Start #########################################################
## Official Web Site: https://bisu.cc
## Version: 20250726Z1
## Recommended BISU PATH: /usr/local/sbin/bisu
## Set the required version of BISU
export THIS_REQUIRED_BISU_VERSION=">=9.0.0"
export BISU_PATH="/usr/local/sbin/bisu"
export TERMUX_BISU_PATH="/data/data/com.termux/files/usr/bin/bisu"
export BISU_DL_COMMAND="curl -sL https://g.bisu.cc/bisu -o ./bisu && chmod +x ./bisu && ./bisu -f install"

## <user-customized-variables>
# Set this utility's name
export UTILITY_NAME=""
# Set this utility's version number
export UTILITY_VERSION=""
# Set this utility's doc URI
export UTILITY_INFO_URI=""
# Set this utility's last release date
export LAST_RELEASE_DATE=""
# Atomic mutex lock switch for single-threaded utilities
export ATOMIC_MUTEX_LOCK="true"
# Debug Switch
export DEBUG_MODE="false"
## </user-customized-variables>

## <required-external-commands>
export REQUIRED_EXTERNAL_COMMANDS=()
## </required-external-commands>

## <required-scripts>
export REQUIRED_SCRIPTS=()
## </required-scripts>

## <actions-read-only>
export ACTIONS_RO=()
## </actions-read-only>

## <auto-run-commands>
export AUTORUN=()
## </auto-run-commands>

## <exit-with-commands>
export EXIT_WITH_COMMANDS=()
## </exit-with-commands>

## Import BISU file
source "$BISU_PATH" 2>/dev/null || source "$TERMUX_BISU_PATH" 2>/dev/null || {
    command -v "bash" &>/dev/null || {
        printf '%s\n' "BISU is bash dedicated, using it in another shell is risky."
        exit 1
    }
    [ -f "$BISU_PATH" ] && [[ $(bash -c "${BISU_PATH} installed") == "true" ]] || {
        printf '%s\n%s\n' "Error: BISU is not correctly installed, please use the command below to fix it." "$BISU_DL_COMMAND"
        exit 1
    }
    printf '%s\n' "Error: Unable to load BISU."
    exit 1
}
######################################################## BISU Importer End ###########################################################
