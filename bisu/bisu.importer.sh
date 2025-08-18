#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
################################################################### BISU Importer Start ########################################################################
## Official Web Site: https://bisu.cc
## Version: v9-20250818Z1
## Recommended BISU PATH: /usr/local/bin/bisu
## Set the required version of BISU
export THIS_REQUIRED_BISU_VERSION=">=9.0.0"
export BISU_BOUND="./bisu"
export BISU_PATH="/usr/local/bin/bisu"
export TERMUX_BISU_PATH="/data/data/com.termux/files/usr/bin/bisu"
export BISU_DL_COMMAND="curl -sL https://g.bisu.cc/bisu-file -o ./bisu && chmod +x ./bisu && ./bisu -f install"

## <user-customized-variables>
# Set this utility's name
export UTILITY_NAME=""
# Set this utility's version number
export UTILITY_VERSION=""
# Set this utility's last release date
export LAST_RELEASE_DATE=""
# Set this utility's doc URI
export UTILITY_INFO_URI=""
# Installation target dir
export TARGET_DIR=""
# Atomic mutex lock switch for single-threaded utilities
export ATOMIC_MUTEX_LOCK="false"
# Signature verification switch
export VERIFY_UTILITY_SIG="false"
# GPG Signature algorithm set
export GPG_SIG_ALGO="sha256"
# Style code injection function
export FUNC_STYLE_CODE_INJECTION="__style_code_injection"
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
source "$BISU_BOUND" 2>/dev/null || source "$BISU_PATH" 2>/dev/null || source "$TERMUX_BISU_PATH" 2>/dev/null || {
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
#################################################################### BISU Importer End #########################################################################
