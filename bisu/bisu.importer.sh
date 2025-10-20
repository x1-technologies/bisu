#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
# shellcheck disable=SC2170,SC2219,SC2090,SC2190,SC2145,SC2294,SC2124,SC2139,SC2163,SC2043
################################################################### BISU Importer Start ########################################################################
## Official Web Site: https://bisu.x1.autos
## Version: v11-20251020Z1
## Recommended BISU PATH: /usr/local/bin/bisu
## Set the required version of BISU
export BISU_VERSION_REQUIREMENT=">=11.0.0"
export BISU_BOUND="./bisu"
export BISU_BIN_PATH="/usr/local/bin/bisu"
export BISU_TERMUX_BIN_PATH="/data/data/com.termux/files/usr/bin/bisu"
export BISU_DL_COMMAND="curl -sL https://g.x1.autos/bisu-file -o ./bisu && chmod +x ./bisu && sudo ./bisu -f install"

## <user-customized-variables>
# Set this utility's name
export BISU_CURRENT_UTIL_NAME=""
# Set this utility's version number
export BISU_CURRENT_UTIL_VERSION=""
# Set this utility's last release date
export BISU_CURRENT_UTIL_LAST_RELEASE_DATE=""
# Set this utility's doc URI
export BISU_CURRENT_UTIL_INFO_URI=""
# Set this utility's asc sig file URL
export BISU_CURRENT_UTIL_ASC_FILE_URL=""
# Signature verification switch
export BISU_CURRENT_UTIL_VERIFY_SIG="false"
# GPG Signature algorithm set
export BISU_CURRENT_UTIL_GPG_SIG_ALGO="sha256"
# Installation target dir
export BISU_CURRENT_UTIL_TARGET_DIR=""
# Atomic mutex lock switch for single-threaded utilities
export BISU_USE_AML_LOCK="false"
# Style code injection function
export BISU_STYLE_CODE_INJECTION_FUNC="__style_code_injection"
# Debug Switch
export BISU_DEBUG_MODE="false"
## </user-customized-variables>

## <required-external-commands>
export BISU_CURRENT_UTIL_REQUIRED_COMMANDS=()
## </required-external-commands>

## <actions-read-only>
export BISU_CURRENT_UTIL_ACTIONS_RO=()
## </actions-read-only>

## <auto-run-commands>
export BISU_CURRENT_UTIL_AUTORUN_COMMANDS=()
## </auto-run-commands>

## <required-scripts>
export BISU_CURRENT_UTIL_REQUIRED_SCRIPTS=()
## </required-scripts>

## <exit-with-commands>
export BISU_CURRENT_UTIL_EXIT_WITH_COMMANDS=()
## </exit-with-commands>

## Import BISU file
source "$BISU_BOUND" 2>/dev/null || source "$BISU_BIN_PATH" 2>/dev/null || source "$BISU_TERMUX_BIN_PATH" 2>/dev/null || {
    command -v "bash" &>/dev/null || {
        printf '%s\n' "Error: BISU is bash dedicated, using it in another shell is risky."
        exit 1
    }
    command -v "bisu" &>/dev/null && [[ $(bash -c "bisu installed") == "true" ]] || {
        printf '%s\n%s\n' "Error: BISU is not correctly installed, please use the command below to fix it." "$BISU_DL_COMMAND"
        exit 1
    }
    printf '%s\n' "Error: Unable to load BISU."
    exit 1
}
#################################################################### BISU Importer End #########################################################################
