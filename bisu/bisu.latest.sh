#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283
########################################################## BISU_START: Bash Internal Simple Utils ##############################################################
## Official Web Site: https://bisu.cc
## Recommended BISU PATH: /usr/local/sbin/bisu
## Have a fresh installation of BISU by copying and pasting the command below
## curl -sL https://g.bisu.cc/bisu -o ./bisu && chmod +x ./bisu && ./bisu -f install
# Define BISU VERSION
export BISU_VERSION="10.1.0"
# Set this utility's last release date
LAST_RELEASE_DATE=${LAST_RELEASE_DATE:-"2025-08-11Z"}
# Minimal Bash Version
export MINIMAL_BASH_VERSION="5.0.0"
export _ASSOC_KEYS=()   # Core array for common associative arrays, no modification
export _ASSOC_VALUES=() # Core array for common associative arrays, no modification
export _LOG_BUFFER=()
export _CK="_ASSOC_KEYS"   # Current big array key storage
export _CV="_ASSOC_VALUES" # Current big array value storage
export PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export HOME="$(eval printf '%s' "~${SUDO_USER:-$USER}")"
export KERNEL_INFO=""
export OS_INFO=""
# BISU path
export BISU_FILE_PATH="${BASH_SOURCE[0]}"
# Default title
export DEFAULT_TITLE="-bash"
# Auto line-break length
export LINE_BREAK_LENGTH=160
# Set $TMPDIR
TMPDIR="/tmp" && [ -w "$TMPDIR" ] || TMPDIR="$(dirname $(mktemp -d))" && export TMPDIR
# Set $HOME
HOME=${HOME:-$(getent passwd $(id -u) 2>/dev/null | cut -d: -f6)} && export HOME
# awk prefix
export AWK_PREFIX="awk"
# fifo dir
export BISU_FIFO_DIR="$TMPDIR/bisu_fifo"
# fork limit for per process
export SAFE_FORK_LIMIT=16
# Required external commands list
export BISU_REQUIRED_EXTERNAL_COMMANDS=(
    'bash' 'getopt' 'awk' 'sed' 'grep' 'mapfile' 'head' 'cut' 'tr' 'od' 'xxd' 'bc' 'uuidgen' 'md5sum' 'tee' 'sort' 'uniq'
    'mkfifo' 'whoami' 'hostname'
)
# Required external commands list
REQUIRED_EXTERNAL_COMMANDS=(${REQUIRED_EXTERNAL_COMMANDS[@]:-})
# Required scripts
export BISU_REQUIRED_SCRIPTS=()
# Required scripts
REQUIRED_SCRIPTS=(${REQUIRED_SCRIPTS[@]:-})
# Read-only actions avoiding AML lock
export BISU_ACTIONS_RO=(
    'version' 'v' 'info' 'usage' 'doc' 'help' 'h' 'callfunc' 'installed'
)
# Read-only actions avoiding AML lock for user definitions
ACTIONS_RO=(${ACTIONS_RO[@]:-})
# Auto run commands
export BISU_AUTORUN=(${BISU_AUTORUN[@]:-})
# Auto run commands
AUTORUN=(${AUTORUN[@]:-})
# Exit with commands
export BISU_EXIT_WITH_COMMANDS=()
# Exit with commands
EXIT_WITH_COMMANDS=(${EXIT_WITH_COMMANDS[@]:-})
# Global Variables
export ROOT_LOCK_FILE_DIR="/var/run"
export USER_LOCK_FILE_DIR="$HOME/.local/var/run"
export LOCK_FILE_DIR="$TMPDIR"
export LOCK_ID=""
export LOCK_FILE=""
export CURRENT_LOG_FILE_DIR=""                                         # Current Log file dir
export ROOT_LOG_FILE_DIR="/var/log"                                    # Root Log file dir
export USER_LOG_FILE_DIR="$HOME/.local/var/log"                        # User Log file dir
export TARGET_PATH_PREFIX="/usr/local/sbin"                            # Default target path for moving scripts
export TERMUX_TARGET_PATH_PREFIX="/data/data/com.termux/files/usr/bin" # Android Termux target path for moving scripts
# Current Process ID
export CURRENT_PID=""
# The current file path
export CURRENT_FILE_PATH=""
# The current file name
export CURRENT_FILE_NAME=""
# The user's config dir
export USER_CONF_DIR=""
# The current command by the actual script
export CURRENT_COMMAND=""
# The current args by the actual script
export CURRENT_ARGS=()
# The action currently specified
export CURRENT_ACTION=""
# Specific Empty Expression
export EMPTY_EXPR="0x00"
# Error message prefix
export ERROR_MSG_PREFIX="Error:-( "
# Quitting flag
export QUITTING_FLAG=0
# Lock held
export LOCK_HELD=0
# Machine's current username
export UNIX_USERNAME=""
# Machine's hostname
export UNIX_HOSTNAME=""
# Set this utility's name
UTILITY_NAME=${UTILITY_NAME:-"bisu"}
# Set this utility's version number
UTILITY_VERSION=${UTILITY_VERSION:-"$BISU_VERSION"}
# Set this utility's doc URI
UTILITY_INFO_URI=${UTILITY_INFO_URI:-"https://bisu.cc"}
# Atomic mutex lock switch for single-threaded utilities
ATOMIC_MUTEX_LOCK=${ATOMIC_MUTEX_LOCK:-"true"}
# Debug Switch
DEBUG_MODE=${DEBUG_MODE:-"false"}

# Version: v1-20250811Z1
# ================================================================ Bash OOP Engine Start =======================================================================
unset -f class.sed >/dev/null 2>&1
{
    printf '' | sed -E '' >/dev/null 2>&1 &&
        class.sed() {
            sed -E "$(printf '%s ' "$@")" 2>/dev/null
        } || exit 1
}

@valid.name() {
    local var_name="$1"
    var_name="${var_name#"${var_name%%[![:space:]]*}"}"
    var_name="${var_name%"${var_name##*[![:space:]]}"}"
    if [[ -z "$var_name" || ! "$var_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        return 1
    fi
    return 0
}

class.new() {
    local file="${BASH_SOURCE[1]}"
    local line=${BASH_LINENO[1]}
    local methods_var="CLASSES_M_$1"
    local -n methods_ref="$methods_var"
    local ts=
    [[ -n $EPOCHSECONDS ]] && {
        ts=$EPOCHSECONDS
        [[ $EPOCHREALTIME =~ ^[0-9]+\.(.*)$ ]] && ns=$(printf '%-9s' "${BASH_REMATCH[1]}" | tr ' ' 0) || ns=000000000
        ts+=${ns}
    } || { command -v date >/dev/null 2>&1 && {
        ts=$(date +%s%N 2>/dev/null || true)
        [[ $ts =~ ^[0-9]{19,}$ ]] && : || {
            ts=$(date +%s 2>/dev/null || true)
            [[ $ts =~ ^[0-9]{10}$ ]] && ts=${ts}000000000 || ts=''
        }
    } || ts=''; }
    local obj="@:object.o$(md5sum <<<"${1}-${file}-${line}-${RANDOM}-${ts}")"

    for name in ${methods_ref}; do
        local newname=$obj.${name##*.}
        class.exists "$newname" && newname="${newname%.*}.parent.${newname//*./}"
        class.copy "$name" "$newname" "$obj" "$1"
    done

    local vars_var="CLASSES_V_$1"
    local -n vars_ref="$vars_var"
    for name in ${vars_ref//|/ }; do
        eval "$obj.$name() { class.var \"$obj\" \"$name\" \"\$@\"; }"
    done

    printf -v "$2" "%s" "$obj"
    shift 2
    class.exists "$obj.__construct" && "$obj.__construct" "$@"
}

class.rename() {
    class.copy "$1" "$2"
    unset -f "$1"
}

class.copy() {
    if [ "$3" ]; then
        local vars_var="CLASSES_V_${4//.*/}"
        local -n keys="$vars_var"
        local func_body
        func_body="$(declare -f "$1")"
        func_body="${func_body#*\{}"
        func_body="${func_body%$'\n}'}"
        func_body="$(class.sed "s/{?this\[(@${keys[*]})\]}?/${3#*.}__\\1/g" <<<"$func_body")"
        eval "$2() {"$'\n'"local this=\"$3\" parent=\"$4.parent\" self=\"$4\""$'\n'"$func_body"$'\n'"}"
    else
        local vars_var="CLASSES_V_${2//.*/}"
        local -n keys="$vars_var"
        local func_body
        func_body="$(declare -f "$1")"
        func_body="${func_body#*\{}"
        func_body="${func_body%$'\n}'}"
        func_body="$(class.sed "s/{?self\[(@${keys[*]})\]}?/${2//.*/}_static_\\1/g" <<<"$func_body")"
        eval "$2() {"$'\n'"local self=\"${2//.*/}\""$'\n'"$func_body"$'\n'"}"
    fi
}

class.var() {
    local name="${1#*.}__$2"
    if [ -z "$3" ]; then
        printf '%s' "${!name}"
    else
        printf -v "$name" "%s" "${3#=}"
    fi
}

class.exists() {
    typeset -F "$1" >/dev/null 2>&1
}

class.append() {
    if [ "$2" ]; then
        local props="CLASSES_V_$__CLASS_NAME"
        local -n val="$props"
        val="${val}|$2"
    else
        local len=${#BASH_SOURCE[@]}
        local file="${BASH_SOURCE[$((len - 1))]}"
        local line=${BASH_LINENO[$((len - 2))]}
        local name=($(awk -F ' *; *| *\\(' -v l="$line" '
            NR == l {print $2}
            NR == l + 1 {gsub("[ \t]", "", $1); print $1; exit}
        ' "$file"))
        local methods="CLASSES_M_$__CLASS_NAME"
        local -n val="$methods"
        val="${val} $__CLASS_NAME.$1${name}"
    fi
}

@def() {
    if [[ "$1" == "static" ]]; then
        class.append
    else
        class.append "public." "$1"
    fi
}

@set() {
    local name="$1"
    shift
    @valid.name "$name" && printf -v "$name" '%s' "$@"
}

@return() {
    local name="$1"
    shift
    @valid.name "$name" && printf -v "$name" "$@"
}

@class() {
    export __CLASS_NAME=("$@")
    local name vars val
    for name in "${__CLASS_NAME[@]:1}"; do
        vars="CLASSES_V_$name"
        val="${!vars}"
        printf -v "CLASSES_V_${__CLASS_NAME[0]}" "%s" "$val"
    done
}

@class.end() {
    local methods_var="CLASSES_M_${__CLASS_NAME[0]}"
    local -n methods="$methods_var"
    eval "${__CLASS_NAME[0]}.new() { class.new ${__CLASS_NAME[0]} \"\$@\"; }"

    if [ "${#__CLASS_NAME[@]}" -gt 1 ]; then
        for parent in "${__CLASS_NAME[@]:1}"; do
            local parentmethods_var="CLASSES_M_$parent"
            local -n parentmethods="$parentmethods_var"
            methods+=" ${parentmethods[*]}"
        done
    fi

    for name in ${methods}; do
        class.rename "${name##*.}" "$name"
    done

    unset __CLASS_NAME
    methods="$(printf '%s\n' ${methods} | sort -u | tr '\n' ' ')"
    printf -v "$methods_var" "%s" "$methods"
}

@destroy() {
    class.exists "$1.__destruct" && "$1.__destruct"
    for name in $(typeset -F | awk "/ $1[^ ]*/ {print \$3}"); do
        unset -f "$name"
    done
    for name in $(set | grep -o "^${1//*./}__[^=]*="); do
        unset "${name%%=*}"
    done
}

@class.gc() {
    local vars
    vars="$(set)"
    for name in $(typeset -F | grep -o " @:object\.[^ ]*" 2>/dev/null | cut -d. -f2 | sort -u); do
        grep -q "@:object.$name\$" <<<"$vars" || @destroy "@:object.$name"
    done
}

# Export functions to ensure availability in defining and importing files
export -f class.sed class.new class.rename class.copy class.var class.exists class.append @def @return @set @valid.name @class @class.end \
    @destroy @class.gc >/dev/null 2>&1
# ================================================================ Bash OOP Engine End =========================================================================

# Robust and POSIX-compliant isset function
isset() {
    local name index pattern
    for arg in "$@"; do
        # Parse "name[index]" vs "name"
        case "$arg" in
        *\[*\]*)
            name="${arg%%\[*}"
            index="${arg#*\[}"
            index="${index%\]*}"
            # Strip quotes from index if present
            if [[ $index == \"*\" ]]; then
                index="${index#\"}"
                index="${index%\"}"
            fi
            ;;
        *)
            name="$arg"
            index=""
            ;;
        esac
        # Check if base variable exists
        if ! declare -p "$name" &>/dev/null; then
            return 1
        fi
        # If an index/key is given, verify it exists in the array
        if [ -n "$index" ]; then
            pattern="\\[\"?$index\"?\\]="
            if ! declare -p "$name" 2>/dev/null | awk -v patt="$pattern" '
                { if ($0 ~ patt) { found=1; exit } }
                END { exit(!found) }' &>/dev/null; then
                return 1
            fi
        fi
    done
    return 0
}

# POSIX-compliant trim functions using gawk (UTF-8 supported)
trim() {
    local str="$1"
    local chars="${2:-[:space:]}" # default POSIX space class
    local ci="$3"
    in_array "$ci" "true" "false" || ci="false"
    if [[ "$ci" == "true" ]]; then
        ci=1
    else
        ci=0
    fi
    [ $# -ne 0 ] || str=$(cat)

    if [[ "$chars" == "[:space:]" ]]; then
        str="${str#"${str%%[![:space:]]*}"}"
        str="${str%"${str##*[![:space:]]}"}"
    else
        str=$(awk -v chars="[$chars]" -v IGNORECASE="$ci" '
            {
                gsub("^" chars "+", "")
                gsub(chars "+$", "")
                print
            }
        ' <<<"$str" 2>/dev/null)
    fi

    printf '%s' "$str"
    return 0
}

# POSIX-compliant trim functions using gawk (UTF-8 supported)
ltrim() {
    local str="$1"
    local chars="${2:-[:space:]}" # default POSIX space class
    local ci="$3"
    in_array "$ci" "true" "false" || ci="false"
    if [[ "$ci" == "true" ]]; then
        ci=1
    else
        ci=0
    fi
    [ $# -ne 0 ] || str=$(cat)

    if [[ "$chars" == "[:space:]" ]]; then
        str="${str#"${str%%[![:space:]]*}"}"
    else
        str=$(awk -v chars="[$chars]" -v IGNORECASE="$ci" '
            { gsub("^" chars "+", ""); print }
        ' <<<"$str" 2>/dev/null)
    fi

    printf '%s' "$str"
    return 0
}

# POSIX-compliant trim functions using gawk (UTF-8 supported)
rtrim() {
    local str="$1"
    local chars="${2:-[:space:]}" # default POSIX space class
    local ci="$3"
    in_array "$ci" "true" "false" || ci="false"
    if [[ "$ci" == "true" ]]; then
        ci=1
    else
        ci=0
    fi
    [ $# -ne 0 ] || str=$(cat)

    if [[ "$chars" == "[:space:]" ]]; then
        str="${str%"${str##*[![:space:]]}"}"
    else
        str=$(awk -v chars="[$chars]" -v IGNORECASE="$ci" '
            { sub(chars "$", ""); print }
        ' <<<"$str" 2>/dev/null)
    fi

    printf '%s' "$str"
    return 0
}

# Function to validate a variable name
is_valid_var_name() {
    @valid.name "$1" || return 1
    return 0
}

# get timestamp_sec faster and more robust
time_sec() {
    local ts sec

    # Prefer Bash 5+ built-ins for performance and zero external calls
    if [[ -n $EPOCHSECONDS ]]; then
        printf '%d\n' "$EPOCHSECONDS"
        return 0
    fi

    # GNU date fallback
    if command -v date >/dev/null 2>&1; then
        ts=$(date +%s 2>/dev/null || true)
        # Validate timestamp length (10 digits for seconds)
        if [[ $ts =~ ^[0-9]{10}$ ]]; then
            printf '%s\n' "$ts"
            return 0
        fi
    fi

    printf ''
    return 1
}

# get timestamp_ms faster and more robust
time_ms() {
    local ts sec ns ms

    # Prefer Bash 5+ built-ins for best performance and zero external calls.
    if [[ -n $EPOCHSECONDS ]]; then
        sec=$EPOCHSECONDS
        # Extract fractional nanoseconds padded to 9 digits, else zero
        if [[ -n $EPOCHREALTIME && $EPOCHREALTIME =~ ^[0-9]+\.(.*)$ ]]; then
            ns=$(printf '%-9s' "${BASH_REMATCH[1]}" | tr ' ' 0)
        else
            ns="000000000"
        fi
        # Convert nanoseconds to milliseconds by truncating last 6 digits
        ms=$((10#${sec} * 1000 + 10#${ns:0:3}))
        printf '%d\n' "$ms"
        return 0
    fi

    # GNU date fallback (Ubuntu, Termux)
    if command -v date >/dev/null 2>&1; then
        ts=$(date +%s%N 2>/dev/null || true)
        # Validate output length for seconds+nanoseconds (>=19 digits)
        if [[ $ts =~ ^[0-9]{19,}$ ]]; then
            sec=${ts:0:10}
            ns=${ts:10:9}
            ms=$((10#$sec * 1000 + 10#${ns:0:3}))
            printf '%d\n' "$ms"
            return 0
        fi

        # POSIX date fallback: seconds only, pad milliseconds zero
        ts=$(date +%s 2>/dev/null || true)
        if [[ $ts =~ ^[0-9]{10}$ ]]; then
            ms=$((10#$ts * 1000))
            printf '%d\n' "$ms"
            return 0
        fi
    fi

    printf ''
    return 1
}

# get timestamp_ns faster and more robust
time_ns() {
    local ts sec ns

    # Use Bash 5+ built-ins if available (preferred, no external call)
    if [[ -n $EPOCHSECONDS ]]; then
        sec=$EPOCHSECONDS
        # Use nanoseconds if fractional part exists, else zero-pad
        if [[ -n $EPOCHREALTIME && $EPOCHREALTIME =~ ^[0-9]+\.(.*)$ ]]; then
            ns=$(printf '%-9s' "${BASH_REMATCH[1]}" | tr ' ' 0) # pad right with zeros to 9 digits
        else
            ns="000000000"
        fi
        ts="${sec}${ns}"
        printf '%s\n' "$ts"
        return 0
    fi

    # GNU date fallback: expects nanoseconds appended to seconds (length >= 19)
    if command -v date >/dev/null 2>&1; then
        ts=$(date +%s%N 2>/dev/null || true)
        # Validate: must be all digits and at least 19 chars (10 for seconds + 9 nanoseconds)
        if [[ $ts =~ ^[0-9]{19,}$ ]]; then
            printf '%s\n' "$ts"
            return 0
        fi

        # POSIX date fallback: seconds only
        ts=$(date +%s 2>/dev/null || true)
        if [[ $ts =~ ^[0-9]{10}$ ]]; then
            printf '%s000000000\n' "$ts" # append zeros for nanoseconds to unify length
            return 0
        fi
    fi

    printf ''
    return 1
}

# BISU file path
bisu_file() {
    printf '%s' "$BISU_FILE_PATH"
}

# BISU file name
bisu_filename() {
    printf '%s' $(basename $(bisu_file))
}

# Function: output a message
output() {
    local message="$1"
    local use_newline=$(trim "$2")
    in_array "$use_newline" "true" "false" || use_newline="true"
    local log_only=$(trim "$3")
    in_array "$log_only" "true" "false" || log_only="false"
    local log_file="$(current_log_file)"

    local command
    command="printf '%b\\n' \"$message\""

    if [[ "$log_only" == "true" ]]; then
        eval "$(printf '%s ' "$command")" |
            { [[ "$use_newline" == "false" ]] && rtrim "$(cat)" '\n' || cat; } |
            { debug_mode_on && fold -s -w "$LINE_BREAK_LENGTH" 2>&1 || fold -s -w "$LINE_BREAK_LENGTH" 2>/dev/null; } |
            tee -a -- "$log_file" &>/dev/null ||
            return 1
    else
        eval "$(printf '%s ' "$command")" |
            { [[ "$use_newline" == "false" ]] && rtrim "$(cat)" '\n' || cat; } |
            { debug_mode_on && fold -s -w "$LINE_BREAK_LENGTH" || fold -s -w "$LINE_BREAK_LENGTH" 2>/dev/null; } |
            { debug_mode_on && tee -a -- "$log_file" || tee -a -- "$log_file" 2>/dev/null; } ||
            return 1
    fi

    return 0
}

# Function to check if a command is existent
command_exists() {
    local command=$(trim "$1")
    [ -n "$command" ] || return 1
    command -v "$command" &>/dev/null || return 1

    return 0
}

# Function to check if a func is defined
is_func() {
    local command=$(trim "$1")
    [ -n "$command" ] || return 1
    [[ "$(type -t "$command")" == "function" ]] &>/dev/null || return 1

    return 0
}

# Function to check if the command is executable
is_executable() {
    local command=$(trim "$1")
    [ -n "$command" ] || return 1
    if ! is_func "$command" && ! command_exists "$command"; then
        return 1
    fi

    return 0
}

# Function to check if the process is running
process_is_running() {
    local pid=$(trim "$1")
    is_nn_int "$pid" || return 1
    kill -0 "$pid" &>/dev/null || return 1
    return 0
}

# count processes number by running command
processes_count() {
    local cmd=$(trim "$1")
    local count=$(ps aux | grep -c "$cmd" 2>/dev/null) || {
        printf '0'
        return 1
    }
    count=$(trim "$count")
    is_nn_int "$count" || count=0
    printf '%s' "$count"
    return 0
}

# Quit the current command with a protocol-based signal
quit() {
    local original_sigterm=$(trap -p SIGTERM)

    local exit_code=$1
    local pid=$(trim "$2")
    local quit_group=$(trim "$3")
    local force=$(trim "$4")

    local command=""
    local signal="TERM"

    if [[ "$pid" == "" ]]; then
        pid=$CURRENT_PID
    fi

    if ! is_posi_int "$pid"; then
        exit 1
    fi

    is_posi_int "$exit_code" || exit_code=0
    in_array "${quit_group}" "true" "false" || quit_group="true"
    in_array "${force}" "true" "false" || force="false"

    if [[ "$force" == "true" ]]; then
        signal="9"
    fi

    if [[ "$exit_code" != 0 ]]; then
        exit_code=1
    fi

    if process_is_running "$pid"; then
        if [[ "$QUITTING_FLAG" == 1 && "$pid" == "$CURRENT_PID" ]]; then
            exit $exit_code
        fi

        trap '' SIGTERM 2>/dev/null
        if [[ "$quit_group" == "true" ]]; then
            command="kill -${signal} -- $pid"
        else
            command="kill -${signal} $pid"
        fi

        exec_command "$command" "true" &

        trap "$original_sigterm" SIGTERM 2>/dev/null
    fi

    [[ "$pid" == "$CURRENT_PID" ]] && QUITTING_FLAG=1
    exit $exit_code
}

# Dump
dump() {
    printf '%s ' "$@"
    quit
}

# Function: current_command
# Description: According to its naming
current_command() {
    if [ -z "$CURRENT_COMMAND" ]; then
        output "Invalid current command"
        quit
    fi
    printf '%s' "$CURRENT_COMMAND"
}

# Function: current_args
# Description: According to its naming
current_args() {
    printf '%s' "$CURRENT_ARGS"
}

# Function: current_file
# Description: According to its naming
current_file() {
    if [ -z $CURRENT_FILE_PATH ] || ! is_file "$CURRENT_FILE_PATH"; then
        output "Invalid current file path: $CURRENT_FILE_PATH"
        quit
    fi
    printf '%s' "$CURRENT_FILE_PATH"
}

# Function: current_filename
# Description: According to its naming
current_filename() {
    if [ -z $CURRENT_FILE_NAME ]; then
        output "Invalid current file name"
        quit
    fi
    printf '%s' "$CURRENT_FILE_NAME"
}

# Function: user_conf_dir
# Description: According to its naming
user_conf_dir() {
    if [ -z $USER_CONF_DIR ]; then
        output "Invalid user conf dir"
        quit
    fi
    printf '%s' "$USER_CONF_DIR"
}

# Function: user_backup_dir
# Description: According to its naming
user_backup_dir() {
    printf '%s' "$(user_conf_dir)/backup"
}

# Function: current_dir
# Description: According to its naming
current_dir() {
    printf '%s' $(dirname $(current_file))
}

# The current log file
current_log_file() {
    local log_file_dir=""
    local log_file=""
    local filename="$(current_filename)"

    [ -n "$filename" ] || quit

    if [ -z "$CURRENT_LOG_FILE_DIR" ]; then
        if is_root_user; then
            log_file_dir="$ROOT_LOG_FILE_DIR"
        else
            log_file_dir="$USER_LOG_FILE_DIR"
        fi

        log_file_dir=$(trim "$log_file_dir")

        [ -n "$log_file_dir" ] || {
            log_file_dir="$HOME/.local/var/run"
        }

        CURRENT_LOG_FILE_DIR="$log_file_dir"
    fi

    log_file_dir="$CURRENT_LOG_FILE_DIR"
    string_starts_with "$log_file_dir" "$USER_LOG_FILE_DIR" || string_starts_with "$log_file_dir" "$ROOT_LOG_FILE_DIR" || {
        error_log "Failed to mkdir: $log_file_dir"
        quit
    }

    local date_str="$(date +'%Y%m%d')"
    is_valid_datetime "$date_str" || quit

    local month_str=$(substr "$date_str" 0 6)
    local day_str=$(substr "$date_str" 6 2)
    log_file_dir="$log_file_dir/$filename/$month_str"
    log_file="$log_file_dir/$day_str.log"

    is_dir "$log_file_dir" || {
        mkdir -p "$log_file_dir" &>/dev/null || quit
        chmod -R 755 "$log_file_dir" &>/dev/null || quit
    }

    touch "$log_file" || quit
    is_file "$log_file" || quit

    printf '%s' "$log_file"
}

# Add a log record to buffer
log_add() {
    local msg="$1"
    array_push "_LOG_BUFFER" "$msg" || return 1
    return 0
}

# Flush the log buffer to the log file
log_flush() {
    local output_buffer=$(trim "$1")
    in_array "${output_buffer}" "true" "false" || output_buffer="true"
    local log_only=$(trim "$2")
    in_array "${log_only}" "true" "false" || log_only="false"
    local log_file=$(current_log_file)

    is_array "_LOG_BUFFER" || {
        output "${ERROR_MSG_PREFIX}Illegal log buffer array."
        quit 1
    }

    local array_count=$(array_count "_LOG_BUFFER")

    if [[ "$output_buffer" == "true" ]] && [ "$array_count" -gt 0 ]; then
        local content=""
        for log_record in "${_LOG_BUFFER[@]}"; do
            content+="${log_record}\n"
        done

        output "$content" "false" "$log_only"
    fi

    _LOG_BUFFER=()
    return 0
}

# Function: log_msg
# Description: Log messages with timestamps to a specified log file, with fallback options.
log_msg() {
    local msg="$1"
    local log_only=$(trim "$2")
    in_array "${log_only}" "true" "false" || log_only="false"
    local use_newline=$(trim "$3")
    in_array "${use_newline}" "true" "false" || use_newline="true"

    output "$(date +'%Y-%m-%d %H:%M:%S') - $msg" "$use_newline" "$log_only" || return 1

    return 0
}

# Function: error_log
error_log() {
    local error_msg="$1"
    log_msg "${ERROR_MSG_PREFIX}$error_msg" "true"
    return 0
}

# Function: forcefully terminate and show errors
error_exit() {
    local msg=$(trim "$1")
    local status_code=$(trim "$2")
    is_posi_int "${status_code}" || status_code=1

    [ -n "$msg" ] && {
        log_msg "${ERROR_MSG_PREFIX}$msg"
    }

    quit $status_code
}

# The current file's run lock by signed md5 of full path
current_lock_file() {
    if [ -z "$LOCK_ID" ]; then
        local lock_file_dir="$LOCK_FILE_DIR"
        if ! is_dir "$lock_file_dir"; then
            if is_root_user; then
                lock_file_dir="$ROOT_LOCK_FILE_DIR"
            else
                lock_file_dir="$USER_LOCK_FILE_DIR"
            fi
        fi

        if ! is_dir "$lock_file_dir"; then
            lock_file_dir="$HOME/.local/var/run"
            mkdir_p "$lock_file_dir"
        fi

        if ! is_dir "$lock_file_dir"; then
            error_exit "❗️ Failed to create 🔒 lock_file_dir: ${lock_file_dir}."
        fi

        if string_ends_with "$lock_file_dir" "/"; then
            lock_file_dir=$(substr "$lock_file_dir" 0 -1)
        fi

        LOCK_FILE_DIR="$lock_file_dir"
        LOCK_ID=$(md5_sign "$(current_command)")
        LOCK_FILE="$LOCK_FILE_DIR/$(current_filename)_$LOCK_ID.lock" || {
            error_exit "❗️ Failed to set 🔒 lock_file: ${LOCK_FILE}"
        }
    fi

    if [ -z "$LOCK_ID" ]; then
        error_exit "❗️ Could not set 🔒 lock_id."
    fi

    printf '%s' "$LOCK_FILE"
    return 0
}

# Get the variable for requirements if it is set.
get_importer_var() {
    local var_name=$(str_replace $(strtoupper $(trim "$1")) "-" "_")
    isset "$var_name" || error_exit "Undefined importer variable: $var_name; Please define it in the importer block <user-customized-variables>."
    printf '%s' "${!var_name}"
}

# Function: target_path
# Description: According to its naming
target_path() {
    local target_path="$TARGET_PATH_PREFIX"
    local os_name=$(get_os_name)

    if [[ "$os_name" == "android" ]]; then
        target_path="$TERMUX_TARGET_PATH_PREFIX"
    fi

    if [ -n "$(current_file)" ]; then
        local current_file=$(current_file)
    else
        local current_file=$(bisu_file)
    fi
    target_path="$target_path/$(current_filename)"
    target_path=$(file_real_path "$target_path")
    printf '%s' "$target_path"
}

# Function: strtolower
# Description: According to its naming
strtolower() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

# Function: strtoupper
# Description: According to its naming
strtoupper() {
    printf '%s' "$1" | tr '[:lower:]' '[:upper:]'
}

# Function: substr
# Description: According to its naming
substr() {
    local string="$1"
    local offset=$(trim "$2")
    local length=$(trim "$3")
    local strlen="${#string}"

    [ -z "$length" ] && length="$strlen"

    # Validate integers
    if [[ "$strlen" -eq 0 ]] || ! is_int "$offset" || ! is_int "$length" ||
        [[ "$length" -eq 0 || $(abs "$offset") -gt "$strlen" || $(abs "$length") -gt "$strlen" ]]; then
        return 1
    fi

    # Handle negative offset
    ((offset < 0)) && offset=$((strlen + offset))

    # Handle negative length
    ((length < 0)) && length=$((strlen - offset + length))

    # Bounds check
    ((offset + length > strlen)) && length=$((strlen - offset))

    # Extract substring
    printf '%s' "${string:offset:length}"
    return 0
}

# Description: Normalize a string
normalize_string() {
    local input
    if [ $# -eq 0 ]; then
        input="$(cat)"
    else
        input="$*"
    fi

    awk '{
        sub(/[ \t]+$/, "")
        gsub(/[ \t]+/, " ")
        print
    }' <<<"$input" 2>/dev/null || {
        printf ''
        return 1
    }

    return 0
}

# Function: string_join
string_join() {
    local array_name=$(trim "$1")
    local sep="$2"
    local -n arr_ref="$array_name"

    array_is_available "$array_name" || {
        printf ''
        return 1
    }

    # Join using awk: read lines from printf, accumulate with sep, no explicit loop in bash
    printf '%s\n' "${arr_ref[@]}" | awk -v ORS="" -v sep="$sep" '
    {
        if (NR == 1) out = $0;
        else out = out sep $0;
    }
    END { print out }' 2>/dev/null || {
        printf ''
        return 1
    }

    return 0
}

# Function: normalize_number
# Description: Normalizes a number string by removing unnecessary leading zeros,
#              trailing zeros after decimal point, and unnecessary decimal point
# Usage: normalize_number "number_string"
# Returns: Normalized number string, or empty string on failure
# Exit status: 0 on success, 1 on failure
normalize_number() {
    # Validate number of arguments
    if [[ $# -ne 1 ]]; then
        printf ''
        return 1
    fi

    local input=$(trim "$1")
    local result=""

    # Handle empty input
    if [ -z "$input" ]; then
        printf ''
        return 1
    fi

    # Check if input is a valid number
    if ! [[ "$input" =~ ^[+-]?([0-9]+([.][0-9]*)?|[.][0-9]+)$ ]]; then
        printf ''
        return 1
    fi

    # Use awk for precise number formatting
    result=$(awk -v num="$input" '
        BEGIN {
            # Handle special case where input is just a decimal point
            if (num == ".") {
                print "0";
                exit 0;
            }
            
            # Convert input to a number to normalize it
            numeric_val = num + 0;
            
            # Handle integer case specially to avoid decimal point
            if (int(numeric_val) == numeric_val) {
                printf "%d", numeric_val;
            } else {
                # For decimal numbers, use sprintf to convert to string
                # and then remove trailing zeros
                str = sprintf("%.16f", numeric_val);
                
                # Remove trailing zeros after decimal point
                sub(/\.?0+$/, "", str);
                
                # Special handling for numbers like .5 to become 0.5
                if (match(str, /^\./)) {
                    str = "0" str;
                }
                
                print str;
            }
        }
    ' 2>/dev/null) || {
        printf ''
        return 1
    }

    # Output the normalized number
    printf '%s' "$result"
    return 0
}

# Function: md5_sign
# Description: According to its naming
md5_sign() {
    printf '%s\n' $(trim "$1") | md5sum | awk '{print $1}' 2>/dev/null
}

# PHP-like function as its naming
strpos() {
    # Assign core args
    local haystack="$1"
    local needle="$2"
    local offset="${3:-0}"
    local ci=$(trim "$4")
    in_array "$ci" "true" "false" || ci="false"
    local reverse=$(trim "$5")
    in_array "$reverse" "true" "false" || reverse="false"

    [ -n "$haystack" ] && [ -n "$needle" ] || {
        printf '%s' "false"
        return 1
    }
    is_nn_int "$offset" || {
        printf '%s' "false"
        return 1
    }

    [ "$offset" -gt 0 ] && haystack=${haystack:$offset}

    local grep_opt=""
    [[ "$ci" == "true" ]] && grep_opt="-i"

    pos=$(printf '%s' "$haystack" |
        grep -abo $grep_opt -- "$needle" 2>/dev/null |
        cut -d: -f1 |
        { [[ "$reverse" == "true" ]] && tail -n1 || head -n1; })

    is_nn_int "$pos" || {
        printf '%s' "false"
        return 1
    }

    [ "$offset" -gt 0 ] && pos=$((pos + offset))

    printf '%s' "$pos"
    return 0
}

# PHP-like function as its naming
stripos() {
    strpos "$1" "$2" "$3" "true" "false" || return 1
    return 0
}

# PHP-like function as its naming
strrpos() {
    strpos "$1" "$2" "$3" "false" "true" || return 1
    return 0
}

# PHP-like function as its naming
stripos() {
    strpos "$1" "$2" "$3" "true" "true" || return 1
    return 0
}

# PHP-like function as its naming
strlen() {
    local input="$1"
    local length=""

    # Check if input is provided
    if [ -z "$input" ]; then
        # Empty or unset input is valid, return 0 length
        length=0
    else
        # Use parameter expansion to count characters, POSIX-compliant
        length=${#input} 2>/dev/null
    fi

    is_nn_int "$length" || {
        printf '%s' "0"
        return 1
    }

    # Output length or empty string on failure
    printf '%s' "$length"
    return 0
}

# PHP-like function as its naming
strstr() {
    local haystack="$1"
    local needle="$2"
    local result=""

    # Check if inputs are provided and valid
    if [ -z "$needle" ]; then
        printf '%s' "false"
        return 1
    fi

    # If haystack is empty and needle is non-empty, no match possible
    if [ -z "$haystack" ]; then
        printf '%s' "false"
        return 1
    fi

    # Use awk to find the substring, POSIX-compliant and robust
    result=$(printf '%s\n' "$haystack" | awk -v needle="$needle" '{
        pos = index($0, needle)
        if (pos > 0) {
            print substr($0, pos)
        }
    }' 2>/dev/null)

    # If no match found, result will be empty
    if [ -z "$result" ]; then
        printf '%s' "false"
        return 1
    fi

    # Output the result
    printf '%s' "$result"
    return 0
}

# PHP-like function as its naming
stristr() {
    local haystack="$1"
    local needle="$2"
    local result=""

    # Check if inputs are provided and valid
    if [ -z "$needle" ]; then
        output "Needle cannot be empty"
        printf '%s' "false"
        return 1
    fi

    # If haystack is empty and needle is non-empty, no match possible
    if [ -z "$haystack" ]; then
        printf '%s' "false"
        return 1
    fi

    # Use awk for case-insensitive search, POSIX-compliant and robust
    result=$(printf '%s\n' "$haystack" | awk -v needle="$needle" '
        BEGIN {
            # Convert needle to lowercase for case-insensitive comparison
            needle_lower = tolower(needle)
        }
        {
            # Convert current line to lowercase for comparison
            haystack_lower = tolower($0)
            pos = index(haystack_lower, needle_lower)
            if (pos > 0) {
                # Return original string from matched position
                print substr($0, pos)
            }
        }
    ' 2>/dev/null)

    # If no match found, result will be empty
    if [ -z "$result" ]; then
        printf '%s' "false"
        return 1
    fi

    # Output the result
    printf '%s' "$result"
    return 0
}

# Check string start with
string_starts_with() {
    local string=$1
    local phrase=$2
    local ignore_case=$(trim "$3")
    in_array "${ignore_case}" "true" "false" || ignore_case="false"
    local pos

    if [[ "$ignore_case" == "true" ]]; then
        pos=$(stripos "$string" "$phrase")
    else
        pos=$(strpos "$string" "$phrase")
    fi

    if [[ "$pos" != "0" ]]; then
        return 1
    fi

    return 0
}

# Check string end with
string_ends_with() {
    local string=$1
    local phrase=$2
    local ignore_case=$(trim "$3")
    in_array "${ignore_case}" "true" "false" || ignore_case="false"
    local pos strlen phraselen

    if [[ "$ignore_case" == "true" ]]; then
        pos=$(strripos "$string" "$phrase")
    else
        pos=$(strrpos "$string" "$phrase")
    fi

    strlen=$(strlen "$string")
    phraselen=$(strlen "$phrase")
    if [[ "$pos" != $(($strlen - $phraselen)) ]]; then
        return 1
    fi

    return 0
}

# continuous spaces count
cspaces_count() {
    local input="$1"
    [[ "$input" =~ [[:space:]]+ ]] || {
        printf '0'
        return 1
    }
    local count=$(printf '%s' "$input" | grep -o ' ' | wc -l 2>/dev/null) || {
        printf '0'
        return 1
    }
    count=$(trim "$count")
    is_nn_int "$count" || count=0
    printf '%s' "$count"
    return 0
}

# str_replace
# Replace all occurrences of a string with another string.
# Usage:
#   str_replace <string> <search> <replace>
# Returns:
#   0 if successful, 1 if an error occurs.
str_replace() {
    [ "$#" -lt 2 ] && {
        printf ''
        return 1
    }

    if [ "$#" -lt 3 ]; then
        local haystack
        haystack=$(cat)
    else
        local haystack="$1"
        shift
    fi

    local cspaces=""
    while [ "$#" -gt 1 ]; do
        local needle="$1" replace="$2"
        shift 2
        [ -z "$needle" ] && continue
        local cspaces_count=$(cspaces_count "$replace")
        cspaces=$(printf '%*s' $cspaces_count '')

        haystack=$(awk -v needle="$needle" -v replace="$replace" -v ORS="$cspaces" '
            BEGIN { IGNORECASE=0 }
            { gsub(needle, replace); print }
        ' <<<"$haystack" 2>/dev/null)
    done

    printf '%s' "$haystack"
    return 0
}

# str_ireplace
# Replace all occurrences of a string with another string, case-insensitively.
# Usage:
#   str_ireplace <string> <search> <replace>
# Returns:
#   0 if successful, 1 if an error occurs.
str_ireplace() {
    [ "$#" -lt 2 ] && {
        printf ''
        return 1
    }

    if [ "$#" -lt 3 ]; then
        local haystack
        haystack=$(cat)
    else
        local haystack="$1"
        shift
    fi

    local cspaces=""
    while [ "$#" -gt 1 ]; do
        local needle="$1" replace="$2"
        shift 2
        [ -z "$needle" ] && continue
        local cspaces_count=$(cspaces_count "$replace")
        cspaces=$(printf '%*s' $cspaces_count '')

        haystack=$(awk -v needle="$needle" -v replace="$replace" -v ORS="$cspaces" '
            BEGIN { IGNORECASE=0 }
            { gsub(needle, replace); print }
        ' <<<"$haystack" 2>/dev/null)
    done

    printf '%s' "$haystack"
    return 0
}

# string to array
string_to_array() {
    local input="$1"
    local array_name=$(trim "$2")
    local delim="${3-" "}"

    is_valid_var_name "$array_name" || return 1

    local -n arr_ref="$array_name"
    local delim_awk

    case "$delim" in
    '.' | '[' | ']' | '\\' | '^' | '$' | '*' | '+' | '?' | '(' | ')' | '|')
        delim_awk="\\$delim"
        ;;
    $'\t')
        delim_awk="\\t"
        ;;
    *)
        delim_awk="$delim"
        ;;
    esac

    # Prevent empty input leading to mapfile hanging by using printf only if input is non-empty
    if [ -n "$input" ]; then
        mapfile -t arr_ref < <(
            printf '%s\n' "$input" |
                awk -v FS="$delim_awk" '{
                for (i = 1; i <= NF; i++) print $i;
                if (length($0) > 0 && substr($0, length($0), 1) == FS) print "";
            }'
        ) 2>/dev/null
    else
        arr_ref=()
    fi

    return 0
}

# compare 2 files, if they have identical contents then return 0
compare_files() {
    local file1=$(trim "$1")
    local file2=$(trim "$2")

    is_file "$file1" || return 1
    is_file "$file2" || return 1
    exec_command "cmp -s \"$file1\" \"$file2\"" || return 1

    return 0
}

# Remove lines matching a pattern from a specified file (robust and efficient)
remove_matched_lines() {
    local file=$(trim "$1") # The file to modify
    local pattern="$2"      # The pattern to match and remove
    local tmp_file          # Temporary file for processing

    # Ensure file and pattern are provided
    [ -n "$file" ] && [ -n "$pattern" ] || return 1

    # Ensure file exists
    is_file "$file" || return 1

    # Create a temporary file for output
    tmp_file=$(mktemp) || return 1

    # Remove matched lines using a while loop with awk to process each line
    while IFS= read -r line; do
        # Using awk to check if the line matches the pattern
        printf '%s\n' "$line" | awk -v pat="$pattern" '{if ($0 !~ pat) print $0}' 2>/dev/null >>"$tmp_file"
    done <"$file" || return 1

    # Check if any changes were made, and compare the files
    if compare_files "$file" "$tmp_file"; then
        local base_dir=$(dirname "$tmp_file")
        is_file "$tmp_file" || return 0
        saferm "$tmp_file" "$base_dir" || return 1
    else
        move_file "$tmp_file" "$file" || return 1
    fi

    return 0
}

# Check if the current user is root (UID 0)
is_root_user() {
    if [[ "$(id -u)" != 0 ]]; then
        return 1
    fi
    return 0
}

# debug mode switch checker
debug_mode_on() {
    in_array "$DEBUG_MODE" "true" "false" || DEBUG_MODE="false"
    [[ "$DEBUG_MODE" == "true" ]] || return 1
    return 0
}

# Execute command
exec_command() {
    local phrase=$(trim "$1")
    local args=""
    string_to_array "$phrase" "phrase"
    normalize_array "phrase"
    local cmd=$(array_get "phrase" 0)
    array_splice "phrase" 0 1
    args=$(trim "$(printf '%s ' "${phrase[@]}")")
    phrase="$(printf '%s ' "${cmd} ${args}")"

    is_executable "$cmd" || return 1

    local run_in_bg=$(trim "$2")
    local log_file=$(current_log_file)
    in_array "${run_in_bg}" "true" "false" || run_in_bg="false"
    local logging=$(trim "$3")
    in_array "${logging}" "true" "false" || logging="true"

    log_msg "🕒 Command executing: $phrase" "true"
    if [[ "$run_in_bg" == "false" ]]; then
        {
            { debug_mode_on && eval "$(printf '%s' "$phrase")" 2>&1 || eval "$(printf '%s' "$phrase")" 2>/dev/null; } |
                {
                    if [[ "$logging" == "true" ]]; then
                        tee -a -- "$(current_log_file)"
                    fi
                }
        } || {
            log_msg "❗️ Last execution failure was from: $phrase" "true"
            return 1
        }
    else
        pid=$(safe_fork "$phrase" "$logging")
    fi

    log_msg "✅ Command execution done: $phrase" "true"
    return 0
}

# Confirmation method
confirm() {
    local message=$(trim "$1")
    local default=$(trim "$2")
    local prompt="[y/n]"

    case "$default" in
    [Yy]*) prompt="[Y/n]" ;; # Default Yes (uppercase Y)
    [Nn]*) prompt="[y/N]" ;; # Default No (uppercase N)
    esac

    while [ 0 ]; do
        log_msg "$message" "false" "false"
        read -p " $prompt " -r input

        # If user just presses Enter, use default
        input=$(trim "$input")
        if [ -z "$input" ]; then
            input="$default"
        fi

        case "$input" in
        [Yy]) return 0 ;; # Yes
        [Nn]) return 1 ;; # No
        *) return 1 ;;    # No
        esac
    done
}

# Get the file's real path and verify the base folder's existence
file_real_path() {
    # Trim spaces and handle parameters
    local file=$(trim "$1")
    local check_base_existence=$(trim "$2")
    in_array "${check_base_existence}" "true" "false" || check_base_existence="false"

    # Expand shell variables and tilde (~) safely
    file=$(eval printf '%s' "$file")
    file=$(printf '%s\n' "$file" | awk '{gsub(/^~/, ENVIRON["HOME"]); print $0}' 2>/dev/null)

    # Convert relative paths to absolute paths
    case "$file" in
    /*) : ;;                                              # Already absolute
    .) file="$(pwd)" ;;                                   # Convert "." to PWD
    ..) file="$(cd .. && pwd)" ;;                         # Convert ".." to absolute path
    ./*) file="$(pwd)/${file#./}" ;;                      # Handle "./file"
    ../*) file="$(cd "${file%/*}" && pwd)/${file##*/}" ;; # Handle "../file"
    *) file="$(pwd)/$file" ;;                             # Convert other relative paths
    esac

    # Normalize redundant slashes and remove `./` safely using POSIX awk
    file=$(printf '%s\n' "$file" | awk '{gsub(/\/+/, "/"); gsub(/\/\.$/, ""); gsub(/\/\.\//, "/"); print $0}' 2>/dev/null)

    # Remove trailing slashes (except root "/") and spaces
    file=$(printf '%s\n' "$file" | awk '{
        if (length($0) > 1) gsub(/\/+$/, ""); 
        gsub(/ *$/, ""); 
        print $0
    }' 2>/dev/null)

    # Ensure the root path is handled correctly, i.e., "/" should not be turned into ""
    if [[ "$file" == "/" ]]; then
        file="/"
    fi

    # If `check_base_existence` is true, verify the file or directory exists
    if [[ "$check_base_existence" == "true" ]]; then
        [ -e "$file" ] && printf '%s' "$file" || printf ''
    else
        printf '%s' "$file"
    fi
}

# Function: add_env_path
# Description: To robustly add new path to append
add_env_path() {
    local new_path=$(trim "$1")

    # Check if the argument is provided
    if [ -z "$new_path" ]; then
        error_log "No path provided to append."
        return 1
    fi

    # Check if the directory exists
    #s_dir "$new_path" || return 1

    # Convert to absolute path
    new_path=$(cd "$new_path" && pwd -P)

    # Check if the path is already in PATH to avoid duplicates
    if [[ ":$PATH:" != *":$new_path:"* ]]; then
        # Prepend colon if PATH is not empty to ensure correct parsing
        if [ -n "$PATH" ]; then
            PATH="$PATH:$new_path"
        else
            PATH="$new_path"
        fi
        export PATH
    fi
}

# Check if the input is numeric
is_numeric() {
    local num=$(trim "$1")
    [[ "$num" != "" ]] || return 1

    # Validate numeric format using awk
    printf '%s\n' "$num" | awk '
        BEGIN { status = 1 }
        /^0$|^(-?[1-9][0-9]*)$|^-?(0|[1-9][0-9]*)\.[0-9]+$/ { status = 0 }
        END { exit status }
    ' 2>/dev/null || return 1

    return 0
}

# positive numeric validator
is_posi_numeric() {
    local num=$(trim "$1")
    is_numeric "$num" || return 1
    [[ "$num" > 0 ]] || return 1
    return 0
}

# natural number validator
is_nn() {
    local num=$(trim "$1")
    is_numeric "$num" || return 1
    [[ "$num" > 0 || "$num" == 0 ]] || return 1
    return 0
}

# negative numeric validator
is_nega_numeric() {
    local num=$(trim "$1")
    is_numeric "$num" || return 1
    [[ "$num" < 0 ]] || return 1
    return 0
}

# get a number's absolute value
abs() {
    # Trim input and check for empty value
    local num=$(trim "$1")
    [[ "$num" != "" ]] || {
        printf ''
        return 1
    }

    # Validate numeric input
    printf '%s\n' "$num" | awk '
        BEGIN { status = 1 }
        /^-?0$|^-?[1-9][0-9]*$|^-?0\.[0-9]+$|^-?[1-9][0-9]*\.[0-9]+$/ { status = 0 }
        END { exit status }
    ' 2>/dev/null || {
        printf ''
        return 1
    }

    # Compute absolute value
    printf '%s\n' "$num" | awk '{ print ($1 < 0) ? -$1 : $1 }' 2>/dev/null
    return 0
}

# Check if it's int
is_int() {
    local num=$(trim "$1")
    [ -n "$num" ] || return 1
    [[ "$num" =~ ^(0|-?[1-9][0-9]*)$ ]] || return 1
    return 0
}

# positive int validator
is_posi_int() {
    local num=$(trim "$1")
    is_int "$num" || return 1
    [ "$num" -gt 0 ] || return 1
    return 0
}

# natural int validator
is_nn_int() {
    local num=$(trim "$1")
    is_int "$num" || return 1
    [ "$num" -ge 0 ] || return 1
    return 0
}

# negative int validator
is_nega_int() {
    local num=$(trim "$1")
    is_int "$num" || return 1
    [ "$num" -lt 0 ] || return 1
    return 0
}

# positive int validator
is_unsigned_int() {
    is_posi_int "$1" || return 1
    return 0
}

# Check if it's int
is_float() {
    local num=$(trim "$1")
    [ -n "$num" ] || return 1
    [[ "$num" =~ ^-?[1-9]?[0-9]*\.[0-9]+$ ]] || return 1
    return 0
}

# positive float validator
is_posi_float() {
    local num=$(trim "$1")
    is_float "$num" || return 1
    [ "$num" -gt 0 ] || return 1
    return 0
}

# natural float validator
is_nn_float() {
    local num=$(trim "$1")
    is_float "$num" || return 1
    [ "$num" -ge 0 ] || return 1
    return 0
}

# negative float validator
is_nega_float() {
    local num=$(trim "$1")
    is_float "$num" || return 1
    [ "$num" -lt 0 ] || return 1
    return 0
}

# positive float validator
is_unsigned_float() {
    is_posi_float "$1" || return 1
    return 0
}

# Increase a number to the next integer
ceil() {
    # Trim input using awk
    local input=$(trim "$1")
    local result

    # Validate input is numeric
    if ! is_numeric "$input"; then
        printf ''
        return 1
    fi

    # Compute ceiling using awk
    result=$(printf '%s\n' "$input" | awk '{
        if ($1 == int($1)) {
            print $1
        } else if ($1 > 0) {
            print int($1) + 1
        } else {
            print int($1)
        }
    }' 2>/dev/null)

    # Check for empty result
    if [ -z "$result" ]; then
        printf ''
        return 1
    fi

    printf '%s' "$result"
    return 0
}

# Decrease a number to the previous integer
floor() {
    # Trim input using awk
    local input=$(trim "$1")
    local result

    # Validate input is numeric
    if ! is_numeric "$input"; then
        printf ''
        return 1
    fi

    # Compute floor using awk
    result=$(printf '%s\n' "$input" | awk '{
        if ($1 == int($1)) {
            print $1
        } else if ($1 > 0) {
            print int($1)
        } else {
            print int($1) - 1
        }
    }' 2>/dev/null)

    # Check for empty result
    if [ -z "$result" ]; then
        printf ''
        return 1
    fi

    printf '%s' "$result"
    return 0
}

# Function: is_file
# Description: According to its naming
is_file() {
    local filepath=$(trim "$1")
    [[ -n "$filepath" && -f "$filepath" ]] || return 1
    return 0
}

# Function: is_dir
# Description: According to its naming
is_dir() {
    local dirpath=$(trim "$1")
    [[ -n "$dirpath" && -d "$dirpath" ]] || return 1
    return 0
}

# Check if a directory is empty, excluding '.' and '..', with robust handling
is_empty_dir() {
    local dirpath=$(trim "$1")
    is_dir "$dirpath" || return 1

    # Use find and awk with while IFS to check if directory is empty
    if ! find "$dirpath" -mindepth 1 -print | while IFS= read -r; do
        return 1
    done; then
        return 0
    fi
}

# Check if a folder is a sub-folder of another folder
is_sub_folder_of() {
    local sub_folder=$(trim "$1")
    local parent_folder=$(trim "$2")

    sub_folder=$(file_real_path "$sub_folder" "true")
    parent_folder=$(file_real_path "$parent_folder" "true")

    # Ensure both parent and sub folder are valid directories
    if [ -z "$sub_folder" ] || [ -z "$parent_folder" ]; then
        return 1
    fi

    # Check if the sub_folder starts with the parent_folder path
    if [[ "$sub_folder" != "$parent_folder"* ]]; then
        return 1
    fi

    return 0
}

# Function to check if a folder is a top-level folder
is_top_folder() {
    local dirpath=$(trim "$1")
    is_dir "$dirpath" || return 1

    dirpath=$(file_real_path "$dirpath" "true")
    [ -n "$dirpath" ] || return 1

    local parent_dir=$(dirname "$dirpath")
    [[ "$parent_dir" != "/" ]] || return 1

    return 0
}

# Function: file_exists
# Description: According to its naming
file_exists() {
    local filepath=$(trim "$1")
    if is_file "$filepath" || is_dir "$filepath"; then
        return 0
    fi
    return 1
}

# Get file's extension
fileext() {
    # Ensure the input is a valid filename
    local filename=$(trim "$1")

    # Check if the filename is empty
    if [ -z "$filename" ]; then
        printf ''
        return 1
    fi

    # Extract the file extension using POSIX awk
    local ext
    ext=$(printf '%s\n' "$filename" | awk -F. '{if (NF > 1) {print $NF}}' 2>/dev/null)
    ext=$(trim "$ext")

    # Output the extension, or an empty string if no extension is found
    if [ -z "$ext" ]; then
        printf ''
    fi

    printf '%s' "$ext"
    return 0
}

# Get file info
get_file_info() {
    local file=$(trim "$1")
    file=$(file_real_path "$file")
    if [ -z "$file" ]; then
        return 1
    fi

    dict_reset || return 1

    local filename=""
    local file_ext=""
    local file_path="$file"
    local file_dir=""
    local file_exists="false"
    local file_is_dir="false"
    local file_is_file="false"
    local file_has_ext="false"

    if [ -d "$file" ]; then
        file_is_dir="true"
        file_exists="true"
    elif [ -f "$file" ]; then
        file_is_file="true"
        file_exists="true"
    fi

    filename=$(basename "$file")
    file_dir=$(dirname "$file")
    file_ext=$(fileext "$file")

    if [ -n "$file_ext" ]; then
        file_has_ext="true"
    fi

    if [ "$file_has_ext" == "false" ]; then
        file_dir="$file_path"
        filename=""
    fi

    dict_set_val "FILE_NAME" "$filename"
    dict_set_val "FILE_EXT" "$file_ext"
    dict_set_val "FILE_PATH" "$file_path"
    dict_set_val "FILE_DIR" "$file_dir"
    dict_set_val "FILE_EXISTS" "$file_exists"
    dict_set_val "FILE_IS_DIR" "$file_is_dir"
    dict_set_val "FILE_IS_FILE" "$file_is_file"
    dict_set_val "FILE_HAS_EXT" "$file_has_ext"

    return 0
}

# files count
files_count() {
    local file_dir=$(trim "$1")
    local pattern=$(trim "$2")
    local files_count=$(find "$file_dir" -type p -name "*" 2>/dev/null | wc -l)
    files_count=$(trim "$files_count")
    is_nn_int "$files_count" || files_count=0
    printf '%s' "$files_count"
    return 0
}

# mkdir_p
mkdir_p() {
    local dir=$(trim "$1")
    dir=$(file_real_path "$dir")

    # Check if the directory exists, if not, create it
    if ! file_exists "$dir"; then
        bash -c "mkdir -p \"$dir\"" &>/dev/null || {
            error_log "Failed to mkdir: $dir"
            return 1
        }
        bash -c "chmod -R 755 \"$dir\"" &>/dev/null || {
            error_log "Failed to change permissions for $dir"
            return 1
        }
    fi

    return 0
}

# cp_p
cp_p() {
    local source_path=$(trim "$1")
    local target_path=$(trim "$2")
    local target_dir=""
    local force_override=$(trim "$3")
    in_array "${force_override}" "true" "false" || force_override="true"
    local keep_origin=$(trim "$4")
    in_array "${keep_origin}" "true" "false" || keep_origin="true"
    local source_is_file="false"
    local source_is_dir="false"
    local prepare_for_copy="false"
    local prepare_for_move="false"
    local command=""
    local failure_msg=""

    # Check if the source_path exists
    if [[ ! -e "$source_path" ]]; then
        error_log "Source $source_path does not exist."
        return 1
    fi

    get_file_info "$target_path"
    local filename=$(dict_get_val "FILE_NAME")
    local file_path=$(dict_get_val "FILE_PATH")
    local file_ext=$(dict_get_val "FILE_EXT")
    local file_dir=$(dict_get_val "FILE_DIR")
    local file_exists=$(dict_get_val "FILE_EXISTS")
    local file_is_dir=$(dict_get_val "FILE_IS_DIR")
    local file_is_file=$(dict_get_val "FILE_IS_FILE")
    local file_has_ext=$(dict_get_val "FILE_HAS_EXT")

    target_path="$file_path"
    target_dir="$file_dir"

    if [[ "$force_override" == "false" ]] && [ -e "$target_path" ]; then
        return 1
    fi

    if is_file "$source_path"; then
        source_is_file="true"
    fi

    if [[ "$keep_origin" == "true" ]]; then
        if [[ "$source_is_file" == "true" ]]; then
            command="cp -f \"$source_path\" \"$target_path\""
        else
            command="cp -rf \"$source_path\" \"$target_path\""
        fi
        failure_msg="Failed to copy file $source_path to $target_path"
    else
        command="mv \"$source_path\" \"$target_path\""
        failure_msg="Failed to move file $source_path to $target_path"
    fi

    mkdir_p "$target_dir" || return 1
    bash -c "$command" &>/dev/null || {
        error_log "$failure_msg"
        return 1
    }

    return 0
}

# Function: move_file
# Description: Moves any file to the specified target path.
# Arguments:
#   $1 - Source to move (source path).
#   $2 - Target path (destination directory).
#   $3 - Force override (optional), if set to "true", will overwrite the target file if it exists.
# Returns: 0 if successful, 1 if failure.
move_file() {
    local source_path=$(trim "$1")
    local target_path=$(trim "$2")
    local target_dir=""
    local force_override=$(trim "$3")
    in_array "${force_override}" "true" "false" || force_override="true"

    cp_p "$source_path" "$target_path" "$force_override" "false" || return 1

    return 0
}

# function to remove a target safely
saferm() {
    local path=$(trim "$1")
    local parent_dir=$(trim "$2")
    parent_dir=${parent_dir:-"$TMPDIR"}
    local timing=$(trim "$3")
    timing=${timing:-"immediately"}
    local rm_command=""

    path=$(file_real_path "$path" "true")
    parent_dir=$(file_real_path "$parent_dir" "true")

    if [ -z "$path" ] || [ -z "$parent_dir" ]; then
        return 1
    fi

    ! is_top_folder "$path" || return 1

    if is_sub_folder_of "$path" "$parent_dir"; then
        if is_file "$path"; then
            rm_command="rm -f"
        elif is_empty_dir "$path"; then
            rm_command="rm -r"
        fi
    else
        return 1
    fi
    rm_command="$rm_command \"$path\""

    case "$timing" in
    "immediately")
        exec_command "$rm_command" "true" || return 1
        ;;
    "when_quit")
        exec_when_quit "$rm_command" || return 1
        ;;
    *)
        return 1
        ;;
    esac

    return 0
}

# Function to check if a variable is an array
is_array() {
    local name=$(trim "$1")
    is_valid_var_name "$name" || return 1
    # Check if variable is declared as an array (indexed or associative)
    declare -p "$name" 2>/dev/null | grep -qE 'declare -a|declare -A' &>/dev/null || return 1
    return 0
}

# Function to check if an array is available
array_is_available() {
    local array_name=$(trim "$1")

    is_array "$array_name" || return 1

    [ -n "${array_name[*]}" ] || return 1

    return 0
}

# Function to sign an array based on its name
sign_array() {
    local array_name="$1"
    local array_contents
    local array_md5

    # To perform indirect referencing of the array by its name
    array_copy "$array_name" "array_contents" || {
        printf ''
        return 1
    }

    # Check if the array is empty
    if [ ${#array_contents[@]} -eq 0 ]; then
        printf ''
        return 1
    fi

    # Compute the MD5 hash of the array contents safely
    array_md5=$(printf '%s\n' "${array_contents[@]}" | awk '{ print $0 }' 2>/dev/null | md5sum | awk '{print $1}' 2>/dev/null)

    # Ensure the MD5 computation was successful
    if [ -z "$array_md5" ]; then
        printf ''
        return 1
    fi

    # Output the computed MD5 hash (array signature)
    printf '%s' "$array_md5"
    return 0
}

# Function to count an array's element number
array_count() {
    local array_name=$(trim "$1")

    is_array "$array_name" || {
        printf '%s' "0"
        return 1
    }

    local -n ref="$array_name" 2>/dev/null || {
        printf '%s' "0"
        return 1
    }

    local array_count=$(awk -v n="${#ref[@]}" 'BEGIN { print n }' 2>/dev/null) || {
        printf '%s' "0"
        return 1
    }

    is_nn_int "$array_count" || array_count=0

    printf '%s' "$array_count"
    return 0
}

# Function to check if a value is in an array
in_array() {
    # Ensure there are at least 2 arguments (needle and at least one haystack item)
    if [ $# -lt 2 ]; then
        return 1
    fi

    local needle="$1"
    shift

    # Ensure the needle is not empty
    if [ -z "$needle" ]; then
        return 1
    fi

    # Use awk to check if the needle exists in the arguments
    # We use awk's pattern matching to compare each argument to the needle
    printf '%s\n' "$@" | awk -v needle="$needle" '
        BEGIN { found = 0 }
        $0 == needle { found = 1; exit }
        END { exit found ? 0 : 1 }
    ' 2>/dev/null || return 1

    return 0
}

# dump an array's elements into string
array_dump() {
    local array_name=$(trim "$1")
    is_array "$array_name" || {
        printf ''
        return 1
    }

    # Stream array elements using mapfile + xargs only if it works, fallback to eval
    local -a temp_array=()
    if ! eval "mapfile -t temp_array < <(printf '%s\0' \"\${${array_name}[@]}\" 2>/dev/null | xargs -0 -n1 printf '%s\n' 2>/dev/null)"; then
        # Fallback safe to get array elements
        eval "temp_array=(\"\${${array_name}[@]}\")" &>/dev/null || {
            printf ''
            return 1
        }
    fi

    # Output quoted elements, streamed, avoid extra arrays
    local IFS=$' '
    # Use printf + awk for quoting in a streaming fashion
    printf '%s\n' "${temp_array[@]}" |
        awk '{
            # Escape single quotes inside element for safe POSIX shell quoting
            gsub(/'\''/, "'\''\\'\'''\''")
            # Print each element quoted with trailing space
            printf "'\''%s'\'' ", $0
        }
        END {
            # Replace last space with newline to trim trailing space precisely
            if (NR > 0) {
                printf "\n"
            }
        }' 2>/dev/null

    return 0
}

# Function: array_copy
# Description: to copy an array internally or globally
array_copy() {
    local array_name=$(trim "$1")
    local -n arr_ref="$array_name"
    local new_array_name=$(trim "$2")
    in_array "$domain" "local" "global" || domain="local"

    if ! is_array "$array_name" || ! is_valid_var_name "$new_array_name"; then
        return 1
    fi

    # Pass original array name, not nameref variable name, to array_dump
    eval "$new_array_name=($(array_dump "$array_name"))" &>/dev/null || {
        return 1
    }

    [[ "$domain" == "global" ]] && (declare -ga "$new_array_name" || return 1) &>/dev/null

    return 0
}

# Function: normalize_array
normalize_array() {
    array_splice "$1" 0 0 || return 1
    return 0
}

# Function: array_splice
# Description: To remove elements from an array
array_splice() {
    local array_name=$(trim "$1")
    local -n arr_ref="$array_name"
    local position
    local quantity
    local array_count=$(array_count "$array_name")

    if ! array_is_available "$array_name"; then
        return 1
    fi

    if [ $# -eq 2 ]; then
        quantity=$(trim "$2")
        position=0
    else
        position=$(trim "$2")
        quantity=$(trim "$3")
    fi

    if ! is_nn_int "$position" || ! is_nn_int "$quantity"; then
        eval "$array_name=()"
        return 1
    fi

    [ "$position" -ge "$array_count" ] && return 0

    [ $((position + quantity)) -gt "$array_count" ] && quantity=$((array_count - position))

    local new_array
    new_array=$(printf '%s\n' "${arr_ref[@]}" |
        awk -v pos="$position" -v qty="$quantity" 'NR < pos + 1 || NR > pos + qty { print }' 2>/dev/null) || {
        return 1
    }

    mapfile -t arr_ref <<<"$new_array" &>/dev/null
    return 0
}

# Set the specified values in either indexed or associative arrays
array_set() {
    local array_name=$(trim "$1")
    shift

    # Ensure array is valid
    is_array "$array_name" || return 1

    while [[ $# -gt 0 ]]; do
        local key=$(trim "$1")
        local value=$(trim "$2")
        shift 2

        [[ -z "$key" || -z "$value" ]] && continue
        eval "$array_name[\"\$key\"]=\"\$value\"" || return 1
    done

    return 0
}

# Get the specified value from an array
array_get() {
    local array_name=$(trim "$1")
    shift

    is_array "$array_name" || {
        printf ''
        return 0
    }

    local key val
    for key in "$@"; do
        [[ -z "$key" ]] && continue
        val=$(eval "printf '%s' \"\${$array_name[\"\$key\"]}\"")
        [[ -z "$val" ]] && continue
        printf '%s' "$val"
        return 0
    done

    return 1
}

# Function to add an element to a specified global array from the bottom
array_push() {
    local array_name=$(trim "$1")
    local new_value="$2"
    local value_type=$(trim "$3")
    value_type=${value_type:-"string"}
    local unique_values=$(trim "$4")
    unique_values=${unique_values:-"false"}

    # Validate the type parameter and input value
    case "$value_type" in
    int)
        if ! is_int "$new_value"; then
            error_log "Value must be an integer."
            return 1
        fi
        ;;
    float)
        if ! is_numeric "$new_value"; then
            error_log "Value must be a float."
            return 1
        fi
        ;;
    string)
        # No specific validation for STRING
        ;;
    *)
        error_log "Invalid type specified. Use string, int, or float."
        return 1
        ;;
    esac

    # Ensure the global array exists
    is_array "$array_name" || {
        error_log "Array $array_name does not exist."
        return 1
    }

    # Access the global array using indirect reference
    array_copy "$array_name" "array" || return 1

    # Check if the value is already in the array (for unique values check)
    for element in "${array[@]}"; do
        if [[ "$unique_values" == "true" && "$element" == "$new_value" ]]; then
            return 0
        fi
    done

    # Append the new value to the array using indirect reference to modify the global array
    eval "$array_name+=(\"$new_value\")"

    return 0
}

# Function to add an element to a specified global array from the bottom
array_unique_push() {
    local array_name="$1"
    local new_value="$2"
    local value_type="$3"

    array_push "$array_name" "$new_value" "$value_type" "true" || return 1

    return 0
}

# Function to add an element to a specified global array from the top
array_unshift() {
    local array_name=$(trim "$1")
    local new_value="$2"
    local value_type=$(trim "$3")
    value_type=${value_type:-"string"}
    local unique_values=$(trim "$4")
    in_array "$unique_values" "true" "false" || unique_values="false"

    case "$value_type" in
    int)
        if ! [[ "$new_value" =~ ^-?[0-9]+$ ]]; then
            error_log "Value must be an integer."
            return 1
        fi
        ;;
    float)
        if ! [[ "$new_value" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
            error_log "Value must be a float."
            return 1
        fi
        ;;
    string) ;;
    *)
        error_log "Invalid type specified. Use string, int, or float."
        return 1
        ;;
    esac

    # Ensure the global array exists
    is_array "$array_name" || {
        error_log "Array $array_name does not exist."
        return 1
    }

    # Access the global array using indirect reference
    array_copy "$array_name" "array" || return 1

    # Check if the value is already in the array (for unique values check)
    for element in "${array[@]}"; do
        if [[ "$unique_values" == "true" && "$element" == "$new_value" ]]; then
            return 0
        fi
    done

    # Prepend the new value
    eval "$array_name=(\"\$new_value\" \"\${$array_name[@]}\")"

    return 0
}

# Function to add an element to a specified global array from the top
array_unique_unshift() {
    local array_name="$1"
    local new_value="$2"
    local value_type="$3"

    array_unshift "$array_name" "$new_value" "$value_type" "true" || return 1

    return 0
}

# Function: array_merge
# Description: Function to merge 2 arrays into arg3, according to arg3's array name
array_merge() {
    local src1=$(trim "$1")
    local src2=$(trim "$2")
    local dest=$(trim "$3")

    if ! is_array "$src1" || ! is_array "$src2" || ! is_valid_var_name "$dest"; then
        return 1
    fi

    eval "printf '%s\n' \"\${$src1[@]}\" \"\${$src2[@]}\" \"\${$dest[@]}\"" |
        awk '!a[$0]++' | {
        readarray -t merged || return 1
        eval "$dest=(\"\${merged[@]}\")"
    } || return 1

    return 0
}

# Function: array_unique
# Description: To remove duplicates from a global array
array_unique() {
    local array_name=$(trim "$1")
    is_array "$array_name" || return 1

    if [[ $# -eq 1 ]]; then
        return 0
    fi

    eval "${array_name}=(\"\$(printf '%s\n' \"\${${array_name}[@]}\" | awk '!a[\$0]++' 2>/dev/null | tr '\n' ' ')\")" || return 1
    return 0
}

# Function: array_pop
# Accepts: $1 array_name, $2 external value reference
# Exits: 0 if success, 1 if failure (empty array)
array_pop() {
    local array_name=$(trim "$1")
    local val_ref="$2"
    local count=$(array_count "$array_name")

    if ! is_posi_int "$count"; then
        return 1
    fi

    local last_index=$((count - 1))
    local val=$(array_get "$array_name" "$last_index") || return 1

    array_splice "$array_name" "$last_index" 1 || {
        return 1
    }

    @set "$val_ref" "$val"
    return 0
}

# Function: array_shift
# Accepts: $1 array_name, $2 external value reference
# Exits: 0 if success, 1 if failure (empty array)
array_shift() {
    local array_name=$(trim "$1")
    local val_ref="$2"
    local count=$(array_count "$array_name")

    if ! is_posi_int "$count"; then
        return 1
    fi

    local val=$(array_get "$array_name" 0) || return 1

    array_splice "$array_name" 0 1 || {
        return 1
    }

    @set "$val_ref" "$val"
    return 0
}

# Function to dynamically set or update a key-value pair for the common array
dict_set_val() {
    local key=$(trim "$1")
    local value=$(trim "$2")

    if ! isset "$_CK" || ! is_array "$_CK"; then
        return 1
    fi

    if ! isset "$_CV" || ! is_array "$_CV"; then
        return 1
    fi
    [ -n "$key" ] || {
        return 1
    }

    # Type handling (preserve numbers and booleans correctly)
    case "$value" in
    "true" | "false") ;;                                                             # Keep booleans unchanged
    '' | [0-9]* | *[.][0-9]*) ;;                                                     # Keep numbers (integers & floats)
    *) value=$(printf '%s\n' "$value" | awk '{gsub(/"/, ""); print}' 2>/dev/null) ;; # Strip double quotes from strings
    esac

    local found=0
    local array_count=$(array_count "$_CK")

    if is_posi_int "$array_count"; then
        # Search for existing key and update if found
        for ((i = 0; i < $array_count; i++)); do
            if eval "[[ \${${_CK}[$i]} == \"$key\" ]]" &>/dev/null; then
                eval "${_CV}[$i]=\"$value\""
                found=1
                break
            fi
        done
    fi

    # Append new key-value pair if not found
    if [ "$found" -eq 0 ]; then
        eval "${_CK}+=(\"$key\")"
        eval "${_CV}+=(\"$value\")"
    fi

    return 0
}

# Function to access elements for the common associative array and looping search for the first populated value
dict_get_val() {
    local idx search_key

    if ! isset "$_CK" || ! is_array "$_CK"; then
        return 1
    fi

    if ! isset "$_CV" || ! is_array "$_CV"; then
        return 1
    fi

    for search_key in "$@"; do
        [ -z "$search_key" ] && continue

        idx=$(eval "printf '%s\\n' \"\${${_CK}[@]}\"" | awk -v key="$search_key" '$0 == key {print NR; exit}' 2>/dev/null)

        [ -z "$idx" ] && continue

        eval "printf '%s' \"\${${_CV}[\$((idx - 1))]}\""
        return 0
    done

    printf ''
    return 0
}

# Function to reset the common associative array
dict_reset() {
    if ! isset "$_CK" || ! is_array "$_CK"; then
        return 1
    fi
    if ! isset "$_CV" || ! is_array "$_CV"; then
        return 1
    fi

    # Clear the keys and values arrays
    eval "export ${_CK}=()" || return 1
    eval "export ${_CV}=()" || return 1

    return 0
}

# Convert JSON array to bash array
array_to_json() {
    local array_data=$(trim "$1")
    local use_private_array=$(trim "$2")
    in_array "${use_private_array}" "true" "false" || use_private_array="false"
    local array_name=$(trim "$3")

    # If use_private_array is true, we don't need a specific array name or array_data
    if [ "$use_private_array" == "true" ]; then
        array_name="_ASSOC_VALUES"
        array_data=""

        # Construct a default associative array using _ASSOC_KEYS and _ASSOC_VALUES
        for i in "${!_ASSOC_KEYS[@]}"; do
            array_data+="$array_name[\"${_ASSOC_KEYS[$i]}\"]=\"${_ASSOC_VALUES[$i]}\""$'\n'
        done
    else
        # If not using a private array, use the passed array_name or default it
        array_name=${array_name:-"_ASSOC_VALUES"}
    fi

    if ! is_array "$array_name"; then
        printf ''
        return 1
    fi

    # Initialize the result JSON object
    local result="{"
    local first=1

    # Process each line of array_data
    while IFS= read -r line; do
        # Skip comments and empty lines
        if [[ "$line" =~ \["([^\"]+)"\]\=\"([^\"]*)\" ]]; then
            continue
        fi

        # Skip array declaration line
        if [[ "$line" =~ declare\ -a\ "$array_name" ]]; then
            continue
        fi

        # Use awk for processing key-value pairs
        line=$(printf '%s\n' "$line" | awk -v arr="$array_name" '
            match($0, arr"\\[\"([^\"]+)\"\\]=\"([^\"]+)\"", m) {
                key = m[1]
                value = m[2]

                # Escape quotes in key and value
                gsub(/"/, "\\\"", key)
                gsub(/"/, "\\\"", value)

                # Return key-value pair in JSON format
                print "\"" key "\": \"" value "\""
            }
        ' 2>/dev/null)

        # If no match, continue to the next line
        if [ -z "$line" ]; then
            continue
        fi

        # Append the key-value pair to the result JSON
        if [ "$first" -eq 0 ]; then
            result+=","
        fi
        result+="$line"
        first=0
    done <<<"$array_data"

    # Close the JSON object and print the result
    result+="}"

    # Check if result ends with '}' (valid JSON), otherwise return empty
    string_ends_with "$result" "}" || {
        printf ''
        return 1
    }

    printf '%s' "$result"
    return 0
}

# Function: is_valid_version
# Description: Validates a version number in formats vX.Y.Z, X.Y.Z, X.Y, or X/Y/Z.
# Arguments:
# $1 - Version number to validate.
# Returns: 0 if valid, 1 if invalid.
is_valid_version() {
    local version
    version=$(trim "$1")

    # Check for valid version formats: optional leading space, optional 'v', followed by numbers and dots
    if ! [[ "$version" =~ ^[[:space:]]*v?[0-9]+(\.[0-9]+)*$ ]]; then
        return 1
    fi

    return 0
}

# Function: compare_version
# Purpose: Compares two version strings following Composer versioning rules, supporting complex constraints.
# Usage: compare_version <constraint> <version>
# Returns:
#   - 1 if version satisfies the constraint
#   - 0 if version does not satisfy the constraint
compare_version() {
    local constraint=$(trim "$1")
    local version=$(trim "$2")

    # Normalize version input (strip leading 'v' or spaces)
    version="${version//v/}" # Remove 'v' prefix if it exists
    version="${version// /}" # Remove any spaces

    # Extract operator and version part from constraint
    local operator="="
    if [[ "$constraint" =~ ^([<>!=~^]+)([0-9].*)$ ]]; then
        operator="${BASH_REMATCH[1]}"
        constraint="${BASH_REMATCH[2]}"
        constraint="${constraint//v/}" # Remove 'v' prefix if it exists
        constraint="${constraint// /}" # Remove any spaces
    fi

    # Function to compare two versions numerically
    compare_raw_versions() {
        local ver1="$1"
        local ver2="$2"

        declare -a version_labels
        # Define version labels for pre-release versions
        version_labels=(
            [dev]=-3 [alpha]=-2 [a]=-2 [beta]=-1 [b]=-1 [rc]=0 [RC]=0
            [stable]=1 [final]=1 [pl]=2 [p]=2 [snapshot]=3 [milestone]=4 [pre]=0
            [v]=0 [release]=5
        )

        # Normalize version parts (replace '~' with '0.' and remove '^' since they're not part of the actual version)
        ver1="${ver1//~/0.}"
        ver1="${ver1//^/}"
        ver2="${ver2//~/0.}"
        ver2="${ver2//^/}"

        # Split versions by '.' and '-'
        IFS='.-' read -ra v1 <<<"$ver1"
        IFS='.-' read -ra v2 <<<"$ver2"

        local i=0
        while [[ $i -lt ${#v1[@]} || $i -lt ${#v2[@]} ]]; do
            local s1="${v1[i]}"
            local s2="${v2[i]}"
            [ -z "$s1" ] && s1=0
            [ -z "$s2" ] && s2=0

            # Numeric comparison of each segment
            if [[ "$s1" =~ ^[0-9]+$ && "$s2" =~ ^[0-9]+$ ]]; then
                if ((10#$s1 > 10#$s2)); then
                    printf '%s' "1"
                    return
                fi
                if ((10#$s1 < 10#$s2)); then
                    printf '%s' "-1"
                    return
                fi
            else
                # Compare pre-release versions (like alpha, beta)
                s1=${version_labels[$s1]:-$s1}
                s2=${version_labels[$s2]:-$s2}

                if [[ "$s1" > "$s2" ]]; then
                    printf '%s' "1"
                    return
                fi
                if [[ "$s1" < "$s2" ]]; then
                    printf '%s' "-1"
                    return
                fi
            fi

            ((i++))
        done
        printf '%s' "0"
    }

    # Perform comparison based on operator
    local cmp_result=$(compare_raw_versions "$version" "$constraint")

    case "$operator" in
    "=")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -eq 0 ] && printf '%s' "1" || printf '%s' "0"
        else
            printf '%s' "0"
        fi
        ;;
    "!=")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -ne 0 ] && printf '%s' "1" || printf '%s' "0"
        else
            printf '%s' "0"
        fi
        ;;
    "<")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -lt 0 ] && printf '%s' "1" || printf '%s' "0"
        else
            printf '%s' "0"
        fi
        ;;
    "<=")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -le 0 ] && printf '%s' "1" || printf '%s' "0"
        else
            printf '%s' "0"
        fi
        ;;
    ">")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -gt 0 ] && printf '%s' "1" || printf '%s' "0"
        else
            printf '%s' "0"
        fi
        ;;
    ">=")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -ge 0 ] && printf '%s' "1" || printf '%s' "0"
        else
            printf '%s' "0"
        fi
        ;;
    "~" | "^")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            version_check=$(compare_raw_versions "$version" "${constraint%.*}.999")

            if [[ "$version_check" =~ ^-?[0-9]+$ ]]; then
                if [ "$cmp_result" -ge 0 ] && [ "$version_check" -le 0 ]; then
                    printf '%s' "1"
                else
                    printf '%s' "0"
                fi
            else
                printf '%s' "0"
            fi
        else
            printf '%s' "0"
        fi
        ;;
    *)
        printf '%s' "0"
        ;;
    esac
}

# Get bash version
bash_version() {
    # Get the first line of the Bash version string
    local version_string
    version_string=$(bash --version | head -n 1)

    # Use POSIX awk to extract the version number (e.g., 5.2.37)
    local version
    version=$(printf '%s\n' "$version_string" | awk '{print $4}' 2>/dev/null | cut -d'(' -f1)

    # Ensure it has a valid format (vX.X.X)
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Prefix with 'v' to match the desired format 'vX.X.X'
        printf '%s' "v$version"
    else
        error_exit "Bash version format not recognized"
    fi
}

# Function: check_bash_version
# Description: Verifies that the installed Bash version is greater than or equal to the specified required version.
check_bash_version() {
    if ! is_valid_version "$MINIMAL_BASH_VERSION"; then
        error_exit "Illegal version number of required Bash"
    fi

    local expr=">=$MINIMAL_BASH_VERSION"
    local bash_version=$(bash_version)

    local result=$(compare_version "$expr" "$bash_version")
    if [[ $result == 0 ]]; then
        error_exit "Bash version is not compatible with the minimal required version."
    fi
}

# Function: check_bisu_version
# Description: Verifies that the installed BISU version is greater than or equal to the specified required version.
check_bisu_version() {
    local expr="$THIS_REQUIRED_BISU_VERSION"
    local result=$(compare_version "$expr" "$BISU_VERSION")

    if [[ $result == 0 ]] && [[ $(current_filename) != $(bisu_filename) ]]; then
        error_exit "BISU version ($BISU_VERSION) is not as the satisfactory ($THIS_REQUIRED_BISU_VERSION)."
    fi
}

# Function: normalize_iso_datetime
normalize_iso_datetime() {
    local input=$(trim "$1")
    if [ -z "$input" ]; then
        printf '%s' "INVALID"
        return 1
    fi

    local formatted_time is_utc_time
    if string_ends_with "$input" "Z"; then
        is_utc_time="true"
    else
        is_utc_time="false"
    fi

    local raw="$(printf '%s' "$input" | tr -cd '[:alnum:]: T/.\-')" # only valid chars
    local digits_only="$(printf '%s' "$raw" | tr -cd '[:digit:]')"
    local time_part="$(printf '%s' "$raw" | grep -oE '[0-9]{2}:[0-9]{2}(:[0-9]{2})?' 2>/dev/null | head -n1)"

    # Time normalization
    if [ -n "$time_part" ]; then
        case "$time_part" in
        [0-9][0-9]:[0-9][0-9]) time_part="$time_part:00" ;;
        [0-9][0-9][0-9][0-9][0-9][0-9]) # e.g. 143000
            h=$(printf '%s' "$time_part" | cut -c1-2)
            m=$(printf '%s' "$time_part" | cut -c3-4)
            s=$(printf '%s' "$time_part" | cut -c5-6)
            time_part="$h:$m:$s"
            ;;
        esac
    fi

    # Format detection
    case "$raw" in
    # YYYY-MM-DD or YYYY/MM/DD or YYYY.MM.DD
    20[0-9][0-9][-/\.][0-1][0-9][-/\.][0-3][0-9]*)
        y=$(printf '%s' "$raw" | cut -c1-4)
        m=$(printf '%s' "$raw" | cut -c6-7)
        d=$(printf '%s' "$raw" | cut -c9-10)
        ;;
    # YYYYMMDD
    20[0-9][0-9][0-1][0-9][0-3][0-9]*)
        y=$(printf '%s' "$digits_only" | cut -c1-4)
        m=$(printf '%s' "$digits_only" | cut -c5-6)
        d=$(printf '%s' "$digits_only" | cut -c7-8)
        ;;
    # DD.MM.YYYY
    [0-3][0-9].[0-1][0-9].20[0-9][0-9]*)
        d=$(printf '%s' "$raw" | cut -d'.' -f1)
        m=$(printf '%s' "$raw" | cut -d'.' -f2)
        y=$(printf '%s' "$raw" | cut -d'.' -f3)
        ;;
    # MM-DD (assumes current year)
    [0-1][0-9][-/.][0-3][0-9]*)
        y=$(date +%Y)
        m=$(printf '%s' "$raw" | cut -c1-2)
        d=$(printf '%s' "$raw" | cut -c4-5)
        ;;
    *)
        printf '%s' "INVALID"
        return 1
        ;;
    esac

    if [ -z "$time_part" ]; then
        formatted_time="${y}-${m}-${d}T0:00:00"
    else
        formatted_time="${y}-${m}-${d}T${time_part}"
    fi

    if [[ "$is_utc_time" == "true" ]]; then
        formatted_time+="Z"
    fi

    printf '%s' "$formatted_time"
    return 0
}

# Function: is_valid_datetime
# Description: Check if the given string is a valid adaptive datetime
is_valid_datetime() {
    local datetime=$(normalize_iso_datetime "$1")

    [[ "$datetime" == "INVALID" ]] && return 1

    local y=$(printf '%s' "$datetime" | cut -d'-' -f1)
    local m=$(printf '%s' "$datetime" | cut -d'-' -f2)
    local rest=$(printf '%s' "$datetime" | cut -d'-' -f3)
    local d=$(printf '%s' "$rest" | cut -d'T' -f1)
    local h=$(printf '%s' "$rest" | cut -d'T' -f2 | cut -d':' -f1)
    local min=$(printf '%s' "$rest" | cut -d'T' -f2 | cut -d':' -f2)
    local s=$(printf '%s' "$rest" | cut -d'T' -f2 | cut -d':' -f3)

    # Range checks
    if [ "$y" -lt 1000 ] || [ "$y" -gt 9999 ]; then
        return 1
    fi
    if [ "$m" -lt 1 ] || [ "$m" -gt 12 ]; then
        return 1
    fi
    if [ "$d" -lt 1 ] || [ "$d" -gt 31 ]; then
        return 1
    fi
    if [ "$h" -lt 0 ] || [ "$h" -gt 23 ]; then
        return 1
    fi
    if [ "$min" -lt 0 ] || [ "$min" -gt 59 ]; then
        return 1
    fi
    if [ "$s" -lt 0 ] || [ "$s" -gt 59 ]; then
        return 1
    fi

    # Month-specific day checks
    case "$m" in
    04 | 06 | 09 | 11)
        [ "$d" -gt 30 ] && return 1
        ;;
    02)
        if ([ $((y % 4)) -eq 0 ] && [ $((y % 100)) -ne 0 ]) || [ $((y % 400)) -eq 0 ]; then
            [ "$d" -gt 29 ] && return 1
        else
            [ "$d" -gt 28 ] && return 1
        fi
        ;;
    esac

    return 0
}

# Function: gdate
# Description: function for converting ISO8601 time format to natural language format
gdate() {
    local input=$(normalize_iso_datetime "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    local fmt=$(trim "$2")
    fmt="${fmt:-+%a %b %-e %H:%M:%S %Z %Y}"
    local compact=$(trim "$3")
    in_array "$compact" "true" "false" || compact="true"

    # Process date components
    clean=$(printf '%s\n' "$input" | awk -v C="$compact" '
        BEGIN{FS="[T ]"}
        {
            split($1,d,"-")
            if (length(d[1])!=4 || length(d[2])!=2 || length(d[3])!=2) exit
            t = (NF>1 ? $2 : "")
            sub(/[+-].*|Z$/, "", t)
            split(t,tokens,":")
            h = (tokens[1]=="" ? "00" : tokens[1])
            m = (tokens[2]=="" ? "00" : tokens[2])
            s = (tokens[3]=="" ? "00" : tokens[3])
            if (C=="true" && h=="00" && m=="00" && s=="00") {
                printf "%04d-%02d-%02d\n", d[1], d[2], d[3]
            } else {
                printf "%04d-%02d-%02d %02d:%02d:%02d\n", d[1], d[2], d[3], h, m, s
            }
        }' 2>/dev/null)

    [ -z "$clean" ] && {
        printf ''
        return 1
    }

    # Convert date to timestamp
    ts=$(date -j -u -f "%Y-%m-%d %H:%M:%S" "$clean 00:00:00" "+%s" 2>/dev/null || date -u -d "$clean" "+%s" 2>/dev/null) || {
        printf ''
        return 1
    }

    # Format the output
    out=$(date -u -r "$ts" "$fmt" 2>/dev/null || date -u -d "@$ts" "$fmt" 2>/dev/null) || {
        printf ''
        return 1
    }

    # Remove extra parts
    printf '%s\n' "$out" | awk -v C="$compact" '{ if (C=="true") gsub("00:00:00", ""); print }' 2>/dev/null | tr -s ' '
    return 0
}

# Function to check if a filename is valid
is_valid_filename() {
    local filename=$(trim "$1")
    local max_length=255 # Typical POSIX filename length limit

    # Check if input is empty
    if [ -z "$filename" ]; then
        return 1
    fi

    # Check length using awk instead of wc
    local length
    length=$(printf '%s\n' "$filename" | awk '{print length($0)}' 2>/dev/null) || {
        return 1
    }
    [ "$length" -gt "$max_length" ] && {
        return 1
    }

    # Check for invalid characters using awk with while IFS
    local invalid_chars
    invalid_chars=$(printf '%s\n' "$filename" | awk '
        BEGIN { FS="" }
        {
            while (i++ < NF) {
                if ($i == "/" || $i == "\0") {
                    print $i
                    exit 1
                }
            }
        }
    ' 2>/dev/null) || return 1

    if [ -n "$invalid_chars" ]; then
        return 1
    fi

    # Check if filename is a reserved name (like . or ..)
    case "$filename" in
    . | ..)
        return 1
        ;;
    esac

    # Success
    return 0
}

# Returns OS info in format: {name} v{major.minor.patch}
get_os_info() {
    local os_info="$OS_INFO"
    [ -n "$os_info" ] && {
        printf '%s' "$os_info"
        return 0
    }

    local uname_s uname_o kernel_str uname_s_lc os_name='' os_version=''

    uname_s=$(command uname -s 2>/dev/null || :) || return 1
    uname_o=$(command uname -o 2>/dev/null || :) || :
    uname_s_lc=$(strtolower "$uname_s" || :) || return 1
    kernel_str=$(command uname -r 2>/dev/null || :) || return 1

    case "$uname_s_lc" in
    linux)
        if printf '%s\n' "$kernel_str" | awk 'BEGIN{IGNORECASE=1} /microsoft/ {exit 0} {exit 1}' 2>/dev/null; then
            os_name="wsl"
        elif [ -n "$uname_o" ]; then
            os_name=$(printf '%s' "$uname_o" | awk '{print tolower($0)}' 2>/dev/null || printf "linux")
        elif [ -r /etc/os-release ]; then
            . /etc/os-release
            case "${ID:-}" in
            ubuntu) os_name="ubuntu" ;;
            rhel | redhat | redhatenterpriseserver) os_name="redhat" ;;
            fedora) os_name="fedora" ;;
            *) os_name="linux" ;;
            esac
        elif [ -d "/data/data/com.termux" ] || grep -qi "android" "/proc/version" 2>/dev/null; then
            os_name="android"
        else
            os_name="linux"
        fi
        ;;
    darwin) os_name="darwin" ;;
    freebsd) os_name="freebsd" ;;
    openbsd) os_name="openbsd" ;;
    *bsd) os_name="bsd" ;;
    *) os_name="unknown" ;;
    esac

    os_version=$(printf '%s' "$kernel_str" |
        awk '{
            match($0, /[0-9]+(\.[0-9]+){0,2}/);
            if (RSTART > 0) {
                ver = substr($0, RSTART, RLENGTH);
                split(ver, p, ".");
                for (i = length(p) + 1; i <= 3; i++) p[i] = 0;
                for (i = 1; i <= 3; i++) if (p[i] !~ /^[0-9]+$/) exit 1;
                printf "v%d.%d.%d", p[1], p[2], p[3];
                exit 0;
            }
            exit 1;
        }' 2>/dev/null || :) || return 1

    os_info="$(printf "%s %s" "$os_name" "$os_version")"
    OS_INFO="$os_info"
    printf '%s' "$os_info"
    return 0
}

# get_os_name
get_os_name() {
    local os_info=$(get_os_info)
    string_to_array "$os_info" "os_info"
    local os_name=$(array_get "os_info" 0)
    printf '%s' "$os_name"
}

# get_os_version
get_os_version() {
    local os_info=$(get_os_info)
    string_to_array "$os_info" "os_info"
    local os_version=$(array_get "os_info" 1)
    printf '%s' "$os_version"
}

# Returns kernel info in format: {name} v{major.minor.patch}
get_kernel_info() {
    local kernel_info="$KERNEL_INFO"
    [ -n "$kernel_info" ] && {
        printf '%s' "$kernel_info"
        return 0
    }

    local kernname kernversion version_str

    kernname=$(uname -s 2>/dev/null || printf '')
    kernversion=$(uname -r 2>/dev/null || printf '')
    kernname=$(strtolower "$kernname")

    if [ -z "$kernname" ] || [ -z "$kernversion" ]; then
        printf ''
        return 0
    fi

    version_str=$(printf '%s\n' "$kernversion" | awk '
        {
            if (match($0, /^[0-9]+\.[0-9]+\.[0-9]+/)) {
                print substr($0, RSTART, RLENGTH)
                exit
            } else if (match($0, /^[0-9]+\.[0-9]+/)) {
                print substr($0, RSTART, RLENGTH) ".0"
                exit
            }
        }' 2>/dev/null)

    if [ -z "$version_str" ]; then
        printf ''
        return 1
    fi

    kernel_info="$(printf "%s v%s" "$kernname" "$version_str")"
    KERNEL_INFO="$kernel_info"
    printf '%s' "$kernel_info"
    return 0
}

# get_os_name
get_kernel_name() {
    local kernel_info=$(get_kernel_info)
    string_to_array "$kernel_info" "kernel_info"
    local kernel_name=$(array_get "kernel_info" 0)
    printf '%s' "$kernel_name"
}

# get_os_version
get_kernel_version() {
    local kernel_info=$(get_kernel_info)
    string_to_array "$kernel_info" "kernel_info"
    local kernel_version=$(array_get "kernel_info" 1)
    printf '%s' "$kernel_version"
}

# ipv4 validator
is_valid_ipv4() {
    local ip=$(trim "$1")
    # Return empty string if no argument or empty input
    [ -n "$ip" ] || return 1

    # Local variables for strict scope
    local num parts i
    local IFS='.'

    # Split into array using IFS and check basic format
    read -r -a parts <<<"$ip"

    # Must have exactly 4 octets
    [ "${#parts[@]}" -ne 4 ] && return 1

    # Process each octet with strict validation
    i=0
    while [ $i -lt 4 ]; do
        num="${parts[$i]}"

        # Check for empty octet, leading zeros, or non-numeric
        case "$num" in
        '' | 0[0-9]* | [!0-9]*)
            return 1
            ;;
        esac

        # Use awk for efficient numeric range check
        if ! printf '%s\n' "$num" | awk '
            BEGIN { status = 1 }
            ($1 >= 0 && $1 <= 255) { status = 0 }
            END { exit status }
        ' 2>/dev/null; then
            return 1
        fi

        i=$((i + 1))
    done

    return 0
}

# ipv6 validator
is_valid_ipv6() {
    local ip=$(trim "$1")
    # Check for no/empty input
    [ -n "$ip" ] || return 1

    local parts count doubleslash i hex
    local IFS=':'

    # Check for multiple '::'
    case "$ip" in
    *::*::*) return 1 ;;
    esac

    # Split into parts
    read -r -a parts <<<"$ip"
    count=${#parts[@]}

    # Basic count validation (2-8 segments)
    [ "$count" -lt 2 ] || [ "$count" -gt 8 ] && return 1

    # Count empty segments (from ::)
    doubleslash=0
    i=0
    while [ $i -lt "$count" ]; do
        [ -z "${parts[$i]}" ] && doubleslash=$((doubleslash + 1))
        i=$((i + 1))
    done

    # Validate segment count with compression
    if [ "$doubleslash" -gt 1 ]; then
        return 1
    elif [ "$doubleslash" -eq 1 ]; then
        [ $((8 - count + 1)) -lt 0 ] && return 1
    else
        [ "$count" -ne 8 ] && return 1
    fi

    # Validate each segment
    i=0
    while [ $i -lt "$count" ]; do
        hex="${parts[$i]}"

        # Skip empty segment from ::
        [ -z "$hex" ] && {
            i=$((i + 1))
            continue
        }

        # Check length (1-4 chars) and valid hex
        if ! printf '%s\n' "$hex" | awk '
            BEGIN { status = 1 }
            length($1) > 0 && length($1) <= 4 && $1 ~ /^[0-9A-Fa-f]+$/ { status = 0 }
            END { exit status }
        ' 2>/dev/null; then
            return 1
        fi

        i=$((i + 1))
    done

    return 0
}

# Universal function to validate IP address
is_valid_ip() {
    ! is_valid_ipv4 && ! is_valid_ipv6 || return 1
    return 0
}

# Universal function to validate port number
is_valid_port() {
    local port=$(trim "$1")

    # Validate the port range: Must be a number between 0 and 65535
    if [[ ! "$port" =~ ^[0-9]+$ ]] || [[ "$port" -lt 0 || "$port" -gt 65535 ]]; then
        return 1
    fi

    return 0
}

# Domain name validator
is_valid_domain() {
    local url=$(trim "$1")
    local remaining_url="${url#*://}"
    local domain="${remaining_url%%/*}"

    if [[ ! "$domain" =~ ^([a-zA-Z0-9-.])+(\.[a-zA-Z]{2,16})$ ]] || [[ "$domain" =~ -- || "$domain" =~ ^[-.] ||
        "$domain" =~ [-.]$ || "$domain" =~ \.\. ]]; then
        return 1
    fi

    return 0
}

# Email address validator
is_valid_email() {
    local email=$(trim "$1")
    local local_part="${email%%@*}"
    local domain_part="${email#*@}"

    # Validate the local part: Alphanumeric + . _ -, no consecutive dots or invalid start/end
    if [[ ! "$local_part" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*[A-Za-z0-9]$ ]] || [[ "$local_part" =~ \.\. ]] ||
        [[ "$local_part" =~ ^[._-] ]] || [[ "$local_part" =~ [._-]$ ]]; then
        return 1
    fi

    # Validate the domain part: Alphanumeric, dot separator, valid TLD (2-16 chars)
    if [[ ! "$domain_part" =~ ^[A-Za-z0-9][-A-Za-z0-9.]*[A-Za-z0-9]\.[A-Za-z]{2,16}$ ]] || [[ "$domain_part" =~ \.\. ]] ||
        [[ "$domain_part" =~ -- ]] || [[ "$domain_part" =~ ^[-.] ]] || [[ "$domain_part" =~ [-.]$ ]]; then
        return 1
    fi

    return 0
}

# Json validator
is_valid_json() {
    local input=$(trim "$1")

    # Use awk to validate JSON structure
    printf '%s\n' "$input" | awk '
        BEGIN {
            # Set flags for valid structure
            inside_object = 0;
            inside_array = 0;
            valid = 1;
        }
        
        # Detect opening of JSON object or array
        /^[[:space:]]*\{/ { inside_object = 1; next }
        /^[[:space:]]*\[/ { inside_array = 1; next }
        
        # Detect closing of JSON object or array
        /^[[:space:]]*\}/ { if (!inside_object) { valid = 0; exit }; inside_object = 0; next }
        /^[[:space:]]*\]/ { if (!inside_array) { valid = 0; exit }; inside_array = 0; next }

        # Detect key-value pairs for objects
        /^[[:space:]]*"[^"]*"[[:space:]]*:[[:space:]]*"/ {
            # Check if key and value are in the expected format
            if ($0 !~ /"[[:alnum:]_]+":/) {
                valid = 0;
                exit
            }
            next
        }

        # Detect values for arrays
        /^[[:space:]]*[^,]*[[:space:]]*$/ {
            next
        }

        END {
            if (inside_object || inside_array) {
                valid = 0;  # Ensures the structure ends properly
            }
            exit valid;
        }
    ' 2>/dev/null || return 1

    return 0
}

# Function to convert YAML to JSON
yaml_to_json() {
    local yaml=$(trim "$1")

    [ -n "$yaml" ] || {
        printf ''
        return 1
    }

    # Convert YAML to JSON using AWK + while IFS
    printf '%s\n' "$yaml" | awk '
    BEGIN {
        indent_level = 0;
        print "{";
    }
    /^[[:space:]]*#/ { next }  # Skip comments
    /^[[:space:]]*$/ { next }  # Skip empty lines
    /^[[:space:]]*[^[:space:]:]+:/ {
        gsub(/^[[:space:]]+/, "", $0);  # Trim leading spaces
        key_value=$0;
        split(key_value, pair, ": ");
        key = pair[1];
        value = (length(pair) > 1) ? pair[2] : "";  # Handle empty values
        gsub(/"/, "\\\"", key);  # Escape double quotes in key
        gsub(/"/, "\\\"", value);  # Escape double quotes in value
        if (NR > 1) { print ","; }
        printf "  \"%s\": \"%s\"", key, value;
    }
    END { print "\n}"; }
    ' 2>/dev/null || {
        printf ''
        return 1
    }

    return 0
}

# Convert plaintext YAML-like key:value pairs into global variables simulating an associative array
yaml_to_array() {
    local input key value
    # If no argument is passed, read from stdin, otherwise handle the passed argument
    if [ $# -eq 0 ]; then
        input=$(cat)
    else
        input=$(trim "$1")
    fi

    # Reset the array first
    dict_reset || return 1

    # Read the input line by line
    while IFS=':' read -r key value; do
        # Trim spaces and remove quotes from key and value using POSIX awk
        key=$(printf '%s\n' "$key" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); gsub(/"/, ""); gsub(/'\''/, ""); print}' 2>/dev/null)
        value=$(printf '%s\n' "$value" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); gsub(/"/, ""); gsub(/'\''/, ""); print}' 2>/dev/null)

        # Skip if the key is empty (or invalid)
        [ -z "$key" ] && continue

        # Set the key-value pair
        dict_set_val "$key" "$value" || return 1
    done <<<"$input" || return 1

    return 0
}

# Parse JSON into array
json_to_array() {
    local input key value
    # If no argument is passed, read from stdin, otherwise handle the passed argument
    if [ $# -eq 0 ]; then
        input=$(cat)
    else
        input=$(trim "$1")
    fi

    # Reset the array first
    dict_reset || return 1

    # Read the input line by line
    while IFS= read -r line; do
        # Trim spaces around the line
        line=$(printf '%s\n' "$line" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print}' 2>/dev/null)

        # Skip empty lines and braces (starting or ending JSON object)
        if [[ -z "$line" || "$line" =~ ^[\{\}]$ ]]; then
            continue
        fi

        # Handle key-value pairs
        if [[ "$line" =~ ^\"([^\"]+)\"\:\s*\"([^\"]+)\"$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"

            # Remove quotes from key and value using POSIX awk
            key=$(printf '%s\n' "$key" | awk '{gsub(/"/, ""); print}' 2>/dev/null)
            value=$(printf '%s\n' "$value" | awk '{gsub(/"/, ""); print}' 2>/dev/null)

            # Skip if the key is empty (or invalid)
            [ -z "$key" ] && continue

            # Set the key-value pair
            dict_set_val "$key" "$value" || return 1
        fi
    done <<<"$input" || return

    return 0
}

# urlencode
urlencode() {
    local str=$(trim "$1")

    [ -n "$str" ] || {
        printf ''
        return 1
    } # Empty input -> return empty string

    printf '%s\n' "$str" | awk '
    BEGIN {
        # Define safe characters in an associative array for O(1) lookup
        split("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_.~", safe_chars, "");
        for (i in safe_chars) safe_map[safe_chars[i]] = 1;
    }
    {
        output = "";
        while (length($0) > 0) {
            c = substr($0, 1, 1);
            ascii = ord(c);
            $0 = substr($0, 2);  # Remove first character

            if (ascii < 0 || ascii > 127) {
                print ""; exit 1;  # Reject non-ASCII input safely
            }

            if (c in safe_map) {
                output = output c;  # Safe character, append directly
            } else {
                output = output "%" sprintf("%02X", ascii);  # Percent-encoded
            }
        }
        print output;
    }
    function ord(c) {
        return sprintf("%d", c);  # Efficient ASCII conversion
    }' 2>/dev/null

    return 0
}

# Decode URL-encoded string
urldecode() {
    local str=$(trim "$1")
    [ -n "$str" ] || {
        printf ''
        return 1
    } # Return empty string if input is empty

    printf '%s\n' "$str" | awk '
    BEGIN { output = "" }
    {
        while (length($0) > 0) {
            c = substr($0, 1, 1);
            if (c == "%") {
                hex = substr($0, 2, 2);
                if (hex ~ /^[0-9A-Fa-f]{2}$/) {
                    output = output sprintf("%c", strtonum("0x" hex));  # Decode hex
                    $0 = substr($0, 4);  # Skip %XX
                } else {
                    print ""; exit 1;  # Invalid encoding, fail safely
                }
            } else {
                output = output c;  # Append safe characters directly
                $0 = substr($0, 2);
            }
        }
        print output;
    }' 2>/dev/null

    return 0
}

# Check if a URL is encoded
url_is_encoded() {
    local segment=$(trim "$1")

    [ -n "$segment" ] || {
        printf '%s' "Segment is empty"
        return 1
    } # Handle empty input safely

    # Check for correctly formatted percent-encoded sequences
    if ! printf '%s\n' "$segment" | awk 'BEGIN { valid=1 } /%[0-9A-Fa-f]{2}/ { if (!match($0, /%[0-9A-Fa-f]{2}/)) valid=0 } END { exit !valid }' 2>/dev/null; then
        return 1 # False, it's not encoded
    fi

    return 0 # True, it's encoded
}

# Normalize a URL and analyze its info
get_url_info() {
    local url=$(trim "$1")

    # Step 1: Check if URL has a scheme and extract components using awk
    local scheme="http"
    local domain=""
    local path=""
    local url_is_encoded=""
    local unencoded_url=""
    local unencoded_req_path=""
    local encoded_url=""
    local encoded_req_path=""

    # Check if scheme exists and extract scheme and remaining URL
    if printf '%s\n' "$url" | awk -F "://" '{if (NF > 1) print $1}' | grep -q '[a-zA-Z]' 2>/dev/null; then
        # Extract scheme and remaining URL
        scheme=$(printf '%s\n' "$url" | awk -F "://" '{print $1}' 2>/dev/null)
        remaining_url=$(printf '%s\n' "$url" | awk -F "://" '{print $2}' 2>/dev/null)
    else
        remaining_url="$url"
    fi

    # Step 2: Use awk to extract domain and path from the remaining URL
    while IFS="/" read -r domain_part rest; do
        domain="$domain_part"
        path="/$rest"
    done <<<"$remaining_url"

    # Step 3: Validate scheme (if scheme is present)
    if [[ -n "$scheme" && ! "$scheme" =~ ^(http|https|ftp)$ ]]; then
        printf ''
        return 1
    fi

    # Step 4: Validate domain (basic check for alphanumeric and dots/hyphens)
    if [[ -z "$domain" || ! "$domain" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        printf ''
        return 1
    fi

    # Step 5: Normalize the path (handle multiple '?' and missing root '/')
    path=$(printf '%s\n' "$path" | awk '{gsub(/\?/, "&"); print}' 2>/dev/null)

    # If the path is empty or doesn't start with '/', add the root '/'
    if [ -z "$path" ] || ! string_starts_with "$path" "/"; then
        path="/$path"
    fi

    # Remove extra '?' in the path (only keep the first one)
    path=$(printf '%s\n' "$path" | awk '{if (match($0, /\?.*\?/)) sub(/\?.*/, "?"); print}' 2>/dev/null)

    # Step 6: Output the normalized URL
    normalized_url="$scheme://$domain$path"
    if url_is_encoded "$path"; then
        url_is_encoded="true"
        encoded_req_path="$path"
        encoded_url="$normalized_url"
        unencoded_req_path=$(urldecode "$path")
        unencoded_url="$scheme://$domain$unencoded_req_path"
    else
        url_is_encoded="false"
        unencoded_req_path="$path"
        unencoded_url="$normalized_url"
        encoded_req_path=$(urlencode "$path")
        encoded_url="$scheme://$domain$encoded_req_path"
    fi

    dict_reset || return 1
    dict_set_val "URL_SCHEME" "$scheme"
    dict_set_val "URL_DOMAIN" "$domain"
    dict_set_val "UNENCODED_REQ_PATH" "$unencoded_req_path"
    dict_set_val "UNENCODED_URL" "$unencoded_url"
    dict_set_val "ENCODED_REQ_PATH" "$encoded_req_path"
    dict_set_val "ENCODED_URL" "$encoded_url"

    return 0
}

# Url params to json conversion
urlparams_to_json() {
    local str=$(trim "$1")
    string_starts_with "$str" "/" && {
        str=$(substr "$str" 1)
    }

    [ -n "$str" ] || {
        printf '%s' "{}"
        return 1
    } # Return empty JSON if input is empty

    printf '%s\n' "$str" | awk -F '&' '
    BEGIN { print "{"; first = 1 }
    {
        for (i = 1; i <= NF; i++) {
            split($i, kv, "=");
            key = kv[1];
            value = (length(kv) > 1) ? kv[2] : "";  # Handle key-only params

            # Print comma separator except for first entry
            if (!first) printf(", ");
            first = 0;

            # Print key-value pair safely
            printf("\"%s\": \"%s\"", key, value);
        }
    }
    END { print "}" }' 2>/dev/null || {
        printf ''
        return 1
    }

    return 0
}

# Convert JSON to URL parameters
json_to_urlparams() {
    local str=$(trim "$1")
    [ -n "$str" ] || {
        printf ''
        return 1
    } # Return empty string if input is empty

    printf '%s\n' "$str" | awk '
    BEGIN { RS=","; gsub(/[{\"}]/, ""); first = 1 }
    {
        split($0, kv, ":");
        key = trim(kv[1]);
        value = (length(kv) > 1) ? trim(kv[2]) : "";

        # Print separator except for first entry
        if (!first) printf("&");
        first = 0;

        # Print key-value pair safely
        printf("%s=%s", key, value);
    }' 2>/dev/null || {
        printf ''
        return 1
    }

    return 0
}

# Reliable curl with retries, POSIX-compliant
reliable_curl() {
    local url=$(trim "$1")
    local method=$(trim "$2")
    local output_file=$(trim "$3")
    local data=$(trim "$4")
    local retries=$(trim "$5")
    retries=${retries:-3}
    local retry_interval=$(trim "$6")
    retry_interval=${retry_interval:-3}

    local status=1
    local save_option=""
    local info_option=""

    # Validate inputs
    if [ -z "$url" ]; then
        output "URL is required."
        return 1
    fi

    if ! is_numeric "$retries"; then
        output "Invalid retries value."
        return 1
    fi

    if [ -n "$output_file" ]; then
        output_file=$(file_real_path "$output_file")
        save_option="-o '$output_file'"
    else
        save_option="-O"
    fi

    get_url_info "$url"
    url=$(dict_get_val "ENCODED_URL")
    local unencoded_req_path=$(dict_get_val "UNENCODED_REQ_PATH")
    local unencoded_url=$(dict_get_val "UNENCODED_URL")
    local encoded_req_path=$(dict_get_val "ENCODED_REQ_PATH")
    local encoded_url=$(dict_get_val "ENCODED_URL")
    local url_params="$unencoded_req_path"
    local url_params_json=$(urlparams_to_json "$url_params")

    if [[ "$DEBUG_MODE" == "true" ]]; then
        info_option="-SL"
    else
        info_option="-sL"
    fi

    local ua="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/130.0.6479.47 Safari/537.36 Edg/130.0.2716.102"

    while [ "$retries" -gt 0 ]; do
        case "$method" in
        GET)
            exec_command "curl $info_option -X GET '$url' -H '$ua' -H 'Content-Type: text/plain' -d '$url_params_json' $save_option --retry-delay $retry_interval" || return 1
            ;;
        POST)
            exec_command "curl $info_option -X POST '$url' -H '$ua' -H 'Content-Type: text/plain' -d '$url_params_json' $save_option --retry-delay $retry_interval" || return 1
            ;;
        *)
            output "Unsupported method '$method'."
            return 1
            ;;
        esac
        status=$?
        if [ "$status" -eq 0 ]; then
            return 0
        fi
        retries=$((retries - 1))
        if [ "$retries" -gt 0 ]; then
            output "Last request has failed, retrying... ($retries retries left)"
        fi
    done

    return "$status"
}

# HTTP GET with resume support
http_get() {
    # Ensure local variables
    local url=$(trim "$1")
    local output_file=$(trim "$2")
    local retries=$(trim "$3")
    retries=${retries:-3}

    # Input validation
    if [ -z "$url" ] || [ -z "$output_file" ]; then
        output "URL and output file are required."
        return 1
    fi

    if ! reliable_curl "$url" "GET" "$output_file" "" "$retries"; then
        output "Request failed."
        return 1
    fi

    return 0
}

# HTTP POST with retries
http_post() {
    # Ensure local variables
    local url=$(trim "$1")
    local output_file=$(trim "$2")
    local data=$(trim "$3")
    local retries=$(trim "$4")
    retries=${retries:-3}

    # Input validation
    if [ -z "$url" ] || [ -z "$output_file" ]; then
        output "URL and output file are required."
        return 1
    fi

    if ! reliable_curl "$url" "POST" "$output_file" "$data" "$retries"; then
        output "Request failed."
        return 1
    fi

    return 0
}

# Generate a regular nanoid
nanoid() {
    local length
    local having_dash
    local case_mode="mixed"
    local alphabet
    local alpha_len
    local result=""
    local i=0
    local rand byte

    # Parse args: length, having_dash (true|false), case_mode (lowercase|uppercase|mixed)
    [ "$1" ] && length=$(trim "$1")
    is_posi_int "$length" || length=21
    [ "$2" ] && case_mode=$(trim "$2")
    in_array "$case_mode" "lowercase" "uppercase" "mixed" || case_mode="mixed"
    [ "$3" ] && having_dash=$(trim "$3")
    in_array "$having_dash" "true" "false" || having_dash="false"

    # Define alphabet
    alphabet='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_'
    [[ "$having_dash" == "true" ]] && alphabet="-${alphabet}"
    case "$case_mode" in
    lowercase) alphabet=$(printf '%s' "$alphabet" | tr 'A-Z' 'a-z') ;;
    uppercase) alphabet=$(printf '%s' "$alphabet" | tr 'a-z' 'A-Z') ;;
    esac

    alpha_len=${#alphabet}

    while [ "$i" -lt "$length" ]; do
        byte=$(dd if=/dev/urandom bs=1 count=1 2>/dev/null | od -An -tu1 2>/dev/null)
        byte=$(trim "$byte")
        [ "$byte" ] && [ "$byte" -lt "$alpha_len" ] &&
            result+="${alphabet:byte:1}" &&
            i=$((i + 1))
    done

    printf '%s\n' "$result"
}

# Generate a secure random UUIDv4 (128 bits)
uuidv4() {
    local uuidv4=""
    # Use /dev/urandom to generate random data and format as hex
    uuidv4=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | awk '{print tolower($0)}' 2>/dev/null)
    uuidv4=$(trim "$uuidv4")

    if [ -z "$uuidv4" ]; then
        uuidv4=$(uuidgen | tr -d '-' | awk '{print tolower($0)}' 2>/dev/null) || {
            printf ''
            return 1
        }
    fi

    printf '%s' "$uuidv4"
    return 0
}

# Function to convert hex to string
hex2str() {
    local hex_string=$(trim "$1")
    printf '%s' "$hex_string" | tr -d '[:space:]' | xxd -r -p || printf ''
}

# Function to convert string to hex
str2hex() {
    local input_string=$(trim "$1")
    local having_space=$(trim "$2")
    in_array "$having_space" "true" "false" || having_space="true"

    local result=""

    result=$(printf '%s' "$input_string" | xxd -p | tr -d '[:space:]' || printf '') || {
        printf ''
        return 1
    }
    if [[ "$having_space" == "true" ]] && [ -n "$result" ]; then
        result=$(printf '%s\n' "$result" | awk '{ gsub(/(..)/, "& "); print }' 2>/dev/null) || {
            printf ''
            return 1
        }
    fi

    printf '%s' "$result"
    return 0
}

# Encode a string to Base10
base10_encode() {
    local input=$(trim "$1")
    local result=""
    [ -n "$input" ] || {
        printf ''
        return 1
    }
    while IFS= read -r -n1 char; do
        ascii=$(printf "%d" "'$char")
        result+="$ascii"
    done <<<"$input" || {
        printf ''
        return 1
    }
    printf '%s' "$result"
    return 0
}

# Decode from base10 to original string
base10_decode() {
    local input=$(trim "$1")
    local result=""
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    # Loop through the input string and decode in chunks (ASCII values)
    while [ -n "$input" ]; do
        # Extract the next 3 digits (ASCII value length)
        ascii_value="${input:0:3}"
        input="${input:3}"

        # Convert ASCII value to character
        char=$(printf "\\$(printf '%03o' "$ascii_value")")
        result+="$char"
    done || {
        printf ''
        return 1
    }

    printf '%s' "$result"
    return 0
}

# Encode a string to Base26
base26_encode() {
    local input=$(trim "$1")
    local result=""
    [ -n "$input" ] || {
        printf ''
        return 1
    }
    while IFS= read -r -n1 char; do
        ascii=$(printf "%d" "'$char")
        base26=$(((ascii - 65 + 26) % 26 + 65))
        result+=$(printf "\\$(printf '%03o' "$base26")")
        result=$(strtolower "$result")
    done <<<"$input" || {
        printf ''
        return 1
    }
    printf '%s' "$result"
    return 0
}

# Decode from base26 to original string
base26_decode() {
    local input=$(trim "$1")
    local result=""
    [ -n "$input" ] || {
        printf ''
        return 1
    }
    while IFS= read -r -n1 char; do
        ascii=$(printf "%d" "'$char")
        # Reverse the base26 encoding
        original_ascii=$(((ascii - 65 - 26) % 26 + 65))
        result+=$(printf "\\$(printf '%03o' "$original_ascii")")
        result=$(strtolower "$result")
    done <<<"$input" || {
        printf ''
        return 1
    }
    printf '%s' "$result"
    return 0
}

# Encode a string to Base36
base36_encode() {
    local input dec hex rem base36=""
    input=$(trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    # Convert input string to hex string
    for ((i = 0; i < ${#input}; i++)); do
        hex+=$(printf '%02x' "'${input:i:1}")
    done

    # Convert hex to decimal
    dec=$(printf '%s' "ibase=16; $hex" | bc 2>/dev/null)
    [ -n "$dec" ] || {
        printf ''
        return 1
    }

    # Convert decimal to base36
    while [ "$dec" != "0" ]; do
        rem=$(printf '%s' "$dec % 36" | bc)
        dec=$(printf '%s' "$dec / 36" | bc)
        if ((rem < 10)); then
            base36="${rem}${base36}"
        else
            base36="$(printf '\\x%x' $((87 + rem)))$base36"
        fi
    done

    # Handle zero input case
    [ -z "$base36" ] && base36="0"

    printf '%b' "$base36"
    return 0
}

# Decode from base36 to original string
base36_decode() {
    local input dec=0 len i c ascii val hex="" result=""
    input=$(trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }
    if ! printf '%s' "$input" | grep -qE '^[0-9a-z]+$'; then
        printf ''
        return 1
    fi

    len=${#input}
    for ((i = 0; i < len; i++)); do
        c=${input:i:1}
        ascii=$(printf '%d' "'$c")
        if ((ascii >= 48 && ascii <= 57)); then
            val=$((ascii - 48))
        elif ((ascii >= 97 && ascii <= 122)); then
            val=$((ascii - 87))
        else
            printf ''
            return 1
        fi
        dec=$(printf '%s' "$dec * 36 + $val" | bc)
    done

    if [ "$dec" = "0" ]; then
        printf '\0'
        return 0
    fi

    while [ "$dec" != "0" ]; do
        rem=$(printf '%s' "$dec % 16" | bc)
        dec=$(printf '%s' "$dec / 16" | bc)
        hex="$(printf '%x' "$rem")$hex"
    done

    ((${#hex} % 2)) && hex="0$hex"

    for ((i = 0; i < ${#hex}; i += 2)); do
        result+=$(printf '\\x%03o' $((16#${hex:i:2})))
    done

    printf '%b' "$result"
    return 0
}

# Encode a string to Base64
base64_encode() {
    local input=$(trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }
    printf '%s' "$input" | base64 || {
        printf ''
        return 1
    }
    return 0
}

# Decode from base64 to original string
base64_decode() {
    local input=$(trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }
    printf '%s' "$input" | base64 --decode || {
        printf ''
        return 1
    }
    return 0
}

# Generate random string based on uuidv4
random_string() {
    local byte_length=$(trim "$1")
    byte_length=${byte_length:-20}
    local type=$(trim "$2")
    type=${type:-"base10"}
    local needle=""
    local uuid=""
    local result=""

    # Validate byte_length
    if ! is_posi_int "$byte_length"; then
        printf ''
        return 1
    fi

    local uuid_rounds=$(printf '%s' "$byte_length / 32" | bc -l)
    uuid_rounds=$(normalize_number "$uuid_rounds")
    uuid_rounds=$(ceil "$uuid_rounds")
    is_posi_int "$uuid_rounds" || {
        printf ''
        return 1
    }

    for ((i = 0; i < uuid_rounds; i++)); do
        uuid=$(uuidv4)
        needle="$needle$uuid"
    done

    # Enforce limits based on type
    case "$type" in
    "base10")
        result=$(base10_encode "$needle")
        result=$(substr "$result" 0 "$byte_length")
        ;;
    "base26")
        result=$(base26_encode "$needle")
        result=$(substr "$result" 0 "$byte_length")
        ;;
    "base36")
        result=$(base36_encode "$needle")
        result=$(substr "$result" 0 "$byte_length")
        ;;
    "base64")
        result=$(base64_encode "$needle")
        result=$(substr "$result" 0 "$byte_length")
        ;;
    *)
        printf ''
        return 1
        ;;
    esac

    printf '%s' "$result"
    return 0
}

# Function to check existence of external commands
check_commands_list() {
    local invalid_commands_count=0
    local invalid_commands=""

    is_array "BISU_REQUIRED_EXTERNAL_COMMANDS" || error_exit "Invalid array of BISU_REQUIRED_EXTERNAL_COMMANDS."

    for val in "${BISU_REQUIRED_EXTERNAL_COMMANDS[@]}"; do
        # Check if the command exists
        if ! command_exists "$val"; then
            ((invalid_commands_count++))
            invalid_commands+=", '$val'"
            continue
        fi
    done

    # Report the invalid commandString if any
    if [[ $invalid_commands_count -gt 0 ]]; then
        invalid_commands=${invalid_commands:1}
        error_exit "Missing $invalid_commands_count command(s):$invalid_commands"
    fi
}

# Function: hanging_process
# Return: process status value
hanging_process() {
    local pid=$(trim "$1")
    is_posi_int "$pid" || {
        return 1
    }

    wait "$pid" &>/dev/null
    local status=$?
    is_nn_int "$status" || {
        return 1
    }

    [[ "$status" == 0 ]] || return 1
    quit 0 "$pid" || return 1
    return 0
}

# Function to clean files when exit
exit_with_commands() {
    if ! is_array "BISU_EXIT_WITH_COMMANDS"; then
        error_exit "Invalid array name 'BISU_EXIT_WITH_COMMANDS' provided."
    fi

    local utility_name=$(current_utility_name)
    log_msg "🕒 ${utility_name}: Cleaning up..." "true"
    for val in "${BISU_EXIT_WITH_COMMANDS[@]}"; do
        val=$(trim "$val")
        if [ -z "$val" ]; then
            continue
        fi
        {
            eval "$val" | tee -a -- "$(current_log_file)" &
            disown %+ &>/dev/null
        } &
        &>/dev/null
        disown %+ &>/dev/null
    done

    log_msg "⌛️ ${utility_name}: Quitting..." "true"
    quit
}

# Function for atomic mutex lock fast check
atomic_mutex_lock() {
    local atomic_mutex_lock=$(trim "$ATOMIC_MUTEX_LOCK")

    if in_array "$CURRENT_ACTION" $(printf '%s ' "${BISU_ACTIONS_RO[@]}"); then
        atomic_mutex_lock="false"
    fi

    in_array "$atomic_mutex_lock" "true" "false" || atomic_mutex_lock="false"
    [[ "$atomic_mutex_lock" == "true" ]] || return 1

    return 0
}

# set lock flag for flock
lock_held() {
    [ "$LOCK_HELD" -eq 1 ] || LOCK_HELD=1
    return 0
}

# Function to acquire a lock to prevent multiple instances
acquire_lock() {
    local lock_file=$(current_lock_file)
    [ -n "$lock_file" ] || error_exit "❗️ Failed to acquire 🔒 lock."
    exec 200>"$lock_file" || error_exit "❗️ Cannot open 🔒 lock file: $lock_file"
    flock -n 200 || {
        lock_held
        error_exit "🔒 An instance is running: $lock_file"
    }
}

# Function to release the lock
release_lock() {
    [ "$LOCK_HELD" -eq 0 ] || return 0

    local lock_file=$(current_lock_file)
    is_file "$lock_file" || {
        return 0
    }

    flock -u 200 && saferm "$lock_file" || {
        log_msg "❗️ Failed to remove lock file: ${lock_file}" "true"
        return 1
    }

    log_msg "✅ Released 🔒 lock_file: ${lock_file}" "true"
    return 0
}

# Function: set_title
# Purpose: Sets the terminal title safely and robustly
# Arguments: $1 - Title string
# Returns: 0 on success, 1 on invalid input, 2 on unsupported terminal
set_title() {
    local title=$(trim "$1")

    [ -n "$title" ] || return 1
    # Replace any non-alphanumeric character check and clean

    title=$(printf '%s\n' "$title" | awk '!/[^a-zA-Z0-9\-\(\)\#\@ ]/ { print $0 }' 2>/dev/null) || return 1
    # Set terminal title (in a POSIX-compliant way)
    exec 3>/dev/tty || return 1
    printf '\033]2;%s\007' "$title" >&3 2>/dev/null

    return 0
}

# Function to revert the terminal title
revert_title() {
    set_title "$DEFAULT_TITLE"
    return 0
}

# Add new element to pending to load script list, param 1 as the to load script file
import_script() {
    local script=$(trim "$1")
    if ! is_file "$script"; then
        error_exit "Failed to import script: $script"
    fi
    source "$script" &>/dev/null || { error_exit "Failed to import script: $script"; }
}

# Automatically import required scripts
load_required_scripts() {
    array_unique "BISU_REQUIRED_SCRIPTS"
    if ! is_array "BISU_REQUIRED_SCRIPTS"; then
        error_exit "Invalid BISU_REQUIRED_SCRIPTS array."
    fi

    for script in "${BISU_REQUIRED_SCRIPTS[@]}"; do
        import_script "$script"
    done

    return 0
}

# Execute a command when quit
exec_when_quit() {
    local command=$(trim "$1")
    array_unique_push "BISU_EXIT_WITH_COMMANDS" "$command" || {
        return 1
    }
    return 0
}

# Execute a command when quit
separate_command() {
    local input=$(printf '%s ' "$@") # Full input string
    local cmd
    local args
    local params=""

    # Step 1: Extract command and parameters using `awk` + `while IFS` to handle space and empty string
    while IFS= read -r word; do
        if [ -z "$cmd" ]; then
            cmd="$word" # First word is the command
        else
            params="$params $word" # Everything after is considered a parameter
        fi
    done <<<"$(printf '%s\n' "$input" | awk '{for(i=1;i<=NF;i++) print $i}')" 2>/dev/null || return 0

    if [ -z "$cmd" ]; then
        return 1
    fi

    dict_reset || return 1

    dict_set_val "CURRENT_COMMAND" "$cmd"
    dict_set_val "CURRENT_ARGS" "$params"

    return 0
}

# Register the current command
register_current_command() {
    CURRENT_PID="$$"
    local args=($(printf '%s\n' "$@"))
    local current_file_path=""
    local current_args=""

    for arg in "${args[@]}"; do
        if [ -z "$current_file_path" ]; then
            current_file_path="$arg"
        else
            current_args+=" $arg"
        fi
    done

    # normalization of arrays allowed to manually modify them
    normalize_array "BISU_REQUIRED_EXTERNAL_COMMANDS"
    normalize_array "REQUIRED_EXTERNAL_COMMANDS"
    array_merge "BISU_REQUIRED_EXTERNAL_COMMANDS" "REQUIRED_EXTERNAL_COMMANDS" "BISU_REQUIRED_EXTERNAL_COMMANDS"
    array_unique "BISU_REQUIRED_EXTERNAL_COMMANDS"

    normalize_array "BISU_REQUIRED_SCRIPTS"
    normalize_array "REQUIRED_SCRIPTS"
    array_merge "BISU_REQUIRED_SCRIPTS" "REQUIRED_SCRIPTS" "BISU_REQUIRED_SCRIPTS"
    array_unique "BISU_REQUIRED_SCRIPTS"

    normalize_array "BISU_ACTIONS_RO"
    normalize_array "ACTIONS_RO"
    array_merge "BISU_ACTIONS_RO" "ACTIONS_RO" "BISU_ACTIONS_RO"
    array_unique "BISU_ACTIONS_RO"

    normalize_array "BISU_AUTORUN"
    normalize_array "AUTORUN"
    array_merge "BISU_AUTORUN" "AUTORUN" "BISU_AUTORUN"
    array_unique "BISU_AUTORUN"

    normalize_array "BISU_EXIT_WITH_COMMANDS"
    normalize_array "EXIT_WITH_COMMANDS"
    array_merge "BISU_EXIT_WITH_COMMANDS" "EXIT_WITH_COMMANDS" "BISU_EXIT_WITH_COMMANDS"
    array_unique "BISU_EXIT_WITH_COMMANDS"

    UNIX_USERNAME=$(whoami)
    UNIX_HOSTNAME=$(hostname)
    CURRENT_FILE_PATH=$(normalize_string "$current_file_path")
    CURRENT_COMMAND="$CURRENT_FILE_PATH"
    CURRENT_FILE_NAME=$(basename "$CURRENT_FILE_PATH")
    CURRENT_ARGS=$(trim "$current_args")
    [ -n "$CURRENT_ARGS" ] && {
        CURRENT_COMMAND="$CURRENT_COMMAND $CURRENT_ARGS"
    }
    [ -n "$CURRENT_FILE_NAME" ] && {
        USER_CONF_DIR="${HOME}/.local/config/${CURRENT_FILE_NAME}"
    }

    array_unique_push "BISU_EXIT_WITH_COMMANDS" '\"@class.gc\"'
}

# Get args and store them in an associative array
get_args() {
    local key value param pos_index=0
    local emptyExpr="$EMPTY_EXPR" # Assign with 0x00 to distinguish empty from null
    local args="$(current_args)"

    eval "set -- $(printf '%s ' "$args")" 2>/dev/null || return 1

    # Reset associative array or fail if no args
    [ $# -gt 0 ] && dict_reset || return 1

    while [ $# -gt 0 ]; do
        param="$1"

        case "$param" in
        # Short options: -a value, -yf
        -[a-zA-Z0-9]*)
            key="${param#-}"

            # Multiple short options (-yf -> -y + -f)
            while [ -n "$key" ]; do
                single_opt="${key:0:1}"
                dict_set_val "$single_opt" "$emptyExpr"
                key="${key:1}"
            done
            ;;

        # Long options: --option1 value
        --[a-zA-Z0-9][a-zA-Z0-9-_]*)
            key="${param#--}"

            # Handle "--option value" (space-separated value)
            if [ -n "$2" ] && [[ ! "$2" =~ ^- ]]; then
                value="$2"
                shift
            else
                value="$emptyExpr"
            fi
            dict_set_val "$key" "$value"
            ;;

        # Explicit separator "--"
        --)
            shift
            break
            ;;

        # Positional arguments
        *)
            pos_index=$((pos_index + 1))
            dict_set_val "$pos_index" "$param"
            ;;
        esac

        shift
    done

    dict_set_val "_arg${pos_index}" "$param"

    return 0
}

# define current action
set_action() {
    local action=$(trim "$1")
    CURRENT_ACTION="$action"
    return 0
}

# Strict-safe adaptive function executor
safe_callfunc() {
    (
        local fn_name=$(trim "$1")
        is_valid_var_name "$fn_name" || {
            printf ''
            return 1
        }
        shift || {
            printf ''
            return 1
        }

        # Check function existence
        if is_func "$fn_name"; then
            # Call function and capture exit
            printf '%s' "$(eval "${fn_name} $(printf '%q ' "$@")")" || {
                printf ''
                return 1
            }
        else
            printf ''
            return 1
        fi

        return 0
    )
}

# safe fork method
# return $pid
safe_fork() {
    local phrase=$(trim "$1")
    string_to_array "$phrase" "phrase"
    normalize_array "phrase"
    local cmd=$(array_get "phrase" 0)
    array_splice "phrase" 0 1
    local args=""
    args=$(trim "$(printf '%s ' "${phrase[@]}")")
    phrase="$(printf '%s ' "${cmd} ${args}")"

    is_executable "$cmd" || {
        printf ''
        return 1
    }

    local logging=$(trim "$2")
    in_array "${logging}" "true" "false" || logging="true"

    local max_forks="$SAFE_FORK_LIMIT"
    is_posi_int "$max_forks" || max_forks=16

    local processes_count=$(processes_count "$phrase")
    if [ "$processes_count" -ge "$max_forks" ]; then
        printf ''
        exit
    fi

    if is_func "$cmd"; then
        {
            if debug_mode_on; then
                exec 0</dev/tty 1>/dev/tty 2>/dev/tty
            else
                exec 0</dev/tty 1>/dev/tty 2>/dev/null
            fi

            if [[ "$logging" == "true" ]]; then
                eval "$(printf '%s' "$phrase")" | tee -a -- "$(current_log_file)"
            else
                eval "$(printf '%s' "$phrase")"
            fi
        } &
    elif command_exists "$cmd"; then
        {
            if debug_mode_on; then
                exec 0</dev/tty 1>/dev/tty 2>/dev/tty
            else
                exec 0</dev/tty 1>/dev/tty 2>/dev/null
            fi

            if [[ "$logging" == "true" ]]; then
                bash -c "$(printf '%s' "$phrase")" | tee -a -- "$(current_log_file)"
            else
                bash -c "$(printf '%s' "$phrase")"
            fi
        } &
    fi

    local pid=$!
    disown %+ &>/dev/null

    is_posi_int "$pid" || {
        printf ''
        return 1
    }

    in_array "$fifo_exists" "true" "false" || fifo_exists="false"
    [[ "$fifo_exists" == "true" ]] && printf '\n' >&3
    printf '%s' "$pid"
    return 0
}

# Function: continuous_exec
continuous_exec() {
    local phrase=$(trim "$1")
    local sleep_time=$(trim "$2")
    local timeout=$(trim "$3")
    local max_retries=$(trim "$4")
    local op_name=$(trim "$5")

    # while preparation
    is_posi_numeric "$sleep_time" || sleep_time=3
    if [[ "$timeout" != "-1" ]] && ! is_posi_int "$timeout"; then
        timeout=15
    fi
    if [[ "$max_retries" != "-1" ]] && ! is_posi_int "$max_retries"; then
        max_retries=2
    fi

    local count=0
    local pid
    local status
    local now
    local elapsed
    local check_over_retry_needed="true"
    local over_retry="false"
    local result
    if [ "$timeout" -eq -1 ] && [ "$max_retries" -eq -1 ]; then
        check_over_retry_needed="false"
    fi
    # while start
    while [ 0 ]; do
        local start_time=$(date +%s)

        if [ "$count" -gt "$max_retries" ]; then
            over_retry="true"
            break
        fi

        if [ "$timeout" -gt -1 ]; then
            if [ "$timeout" -eq 0 ]; then
                over_retry="true"
                break
            fi

            now=$(date +%s)
            elapsed=$((now - start_time))
            elapsed=$(normalize_number "$elapsed")
            is_posi_int "$elapsed" || elapsed=0

            if [ "$elapsed" -ge "$timeout" ]; then
                over_retry="true"
                break
            fi
        fi

        [ -n "$op_name" ] && [ "$count" -gt 0 ] && {
            log_msg "The operation [$op_name] has been failed. Attempting retry $count..."
        }

        pid=$(safe_fork "$phrase") || return 1
        count=$((count + 1))

        while process_is_running "$pid"; do
            if [[ "$check_over_retry_needed" == "false" ]]; then
                break
            fi

            if [[ "$over_retry" == "true" ]]; then
                break
            fi

            sleep $sleep_time
        done

        if hanging_process "$pid"; then
            return 0
        fi

        if [[ "$over_retry" == "true" ]]; then
            quit 1 "$pid" "true" "true"
            break
        fi
    done
    # while end

    return 1
}

# exit signal event
on_signal_exit() {
    local exit_code=$?
    is_nn_int "$exit_code" || exit_code=1
    revert_title &
    disown %+ &>/dev/null

    if [[ "$LOCK_HELD" -eq 0 ]]; then
        exit_with_commands &
        disown %+ &>/dev/null
    fi

    exit $exit_code
}

# The End Point sign of the utility
@end() {
    local action_method
    if [ -n "$CURRENT_ACTION" ]; then
        action_method="action_${CURRENT_ACTION}"
        action_method=$(str_replace "$action_method" "-" "_")
    else
        action_method="action_default"
    fi

    is_func "__initialize" && {
        __initialize $(printf '%s ' "$(current_args)") 2>/dev/null
    }

    is_func "$action_method" || {
        error_exit "Unintelligible action '$CURRENT_ACTION'; Please type 'help' for more info."
    }

    $action_method $(printf '%s ' "$(current_args)")
    quit
}

# check dependencies
check_dependencies() {
    check_bash_version
    check_bisu_version
    check_commands_list
    load_required_scripts
}

# Set bash signals
set_signals() {
    local utility_name=$(current_utility_name)
    log_msg "🕒 ${utility_name}: Initializing..." "true"
    trap 'wait' SIGCHLD
    trap 'on_signal_exit' EXIT SIGINT SIGTERM SIGHUP SIGQUIT
}

# Start autorun list
autorun_start() {
    if ! is_array "BISU_AUTORUN"; then
        error_exit "Invalid BISU_AUTORUN array."
    fi

    set_signals

    if atomic_mutex_lock; then
        acquire_lock
        array_unique_push "BISU_EXIT_WITH_COMMANDS" '\"release_lock\"'
        log_msg "🔒 Lock set." "true"
    fi

    {
        for command in "${BISU_AUTORUN[@]}"; do
            log_msg "🕒 Autorun command executing: $command" "true"

            {
                safe_fork "$(printf '%s ' "$command")" || {
                    log_msg "❗️ Last execution failure was from: $command (Initialization Task)" "true"
                    continue
                }
            } &
            disown %+ &>/dev/null

            log_msg "✅ Autorun command done: $command" "true"
        done
    } &
    disown %+ &>/dev/null

    return 0
}

# Function to initialize BISU
initialize() {
    # order#1 register current command
    register_current_command $(printf '%s ' "$@")
    # order#2 check dependencies
    check_dependencies
    # order#3 integrate operations
    integrate_ops $(printf '%s ' "$@")
}

# Execute a command when quit
callfunc() {
    local current_args
    string_to_array "$(current_args)" "current_args"
    normalize_array "current_args"

    local action=$(array_get "current_args" 0)
    action=$(normalize_string "$action")
    [[ "$action" == "callfunc" ]] || quit

    local func=$(array_get "current_args" 1)
    func=$(normalize_string "$func")

    local argc=$(array_count "current_args")
    is_posi_int "$argc" || {
        error_exit "Failed to pharse args."
    }

    is_func "$func" || {
        error_exit "Function '$func' does not exist."
    }
    array_splice "current_args" 0 2
    local params=$(string_join "current_args" ' ')
    local result="$(safe_callfunc "$func" $(printf '%s ' "$params"))" || error_exit "Function '$func' does not exist."
    result="$(trim "$result")"
    if [ -n "$result" ]; then
        printf '%s\n' "$(printf '%s' "$result")"
    else
        printf '%s\n' "(empty result)"
    fi
}

# get the current utility's name.
current_utility_name() {
    local utility_name=$(trim "$UTILITY_NAME")
    printf '%s' "$utility_name"
}

# Get the current utility's version.
current_utility_version() {
    local version=$(trim "$UTILITY_VERSION")
    is_valid_version "$version" || error_exit "Invalid version number definition for \$UTILITY_VERSION: '$version'"
    printf '%s' "$version"
}

# Get extra info URI of the current utility.
current_utility_info_uri() {
    local doc_uri=$(trim "$UTILITY_INFO_URI")
    printf '%s' "$doc_uri"
}

# Get the current utility's last release date
last_release_date() {
    local last_release_date=$(trim "$LAST_RELEASE_DATE")
    last_release_date=$(normalize_iso_datetime "$last_release_date")
    printf '%s' "$last_release_date"
}

# Integrate operations
integrate_ops() {
    get_args
    local parg1=$(dict_get_val 1)

    local action="$parg1"
    if [ -z "$action" ]; then
        local parg1=$(trim "$2")
        if string_starts_with "$parg1" "--"; then
            parg1=$(substr "$parg1" 2)
        elif string_starts_with "$parg1" "-"; then
            parg1=$(substr "$parg1" 1 1)
        fi
        # recheck to ensure the param
        if [ -n "$parg1" ] && [ -n parg1=$(dict_get_val "$parg1") ]; then
            action="$parg1"
        fi
        [[ "$action" == "$EMPTY_EXPR" ]] && action=""
    fi

    set_action "$action"
    autorun_start

    local option_force=$(dict_get_val "f" "force")
    local option_yes=$(dict_get_val "y" "yes")
    local option_version=$(dict_get_val "v" "version")
    local current_file=$(current_file)
    local current_filename=$(current_filename)
    local target_path=$(target_path)
    local is_matched_action="true"

    case "$CURRENT_ACTION" in
    "v" | "version")
        local version current_utility_name last_release_date
        current_utility_name="$(current_utility_name)"
        [ -n "$current_utility_name" ] || current_utility_name="$(current_filename)"
        version="$current_utility_name v$(current_utility_version)"
        last_release_date="$(last_release_date)"
        [ -n "$last_release_date" ] && {
            last_release_date="$(gdate "$last_release_date")"
            version+=" released on ${last_release_date}"
        }
        [[ "$(current_filename)" == "bisu" ]] || {
            version+="; using bisu framework v${BISU_VERSION}"
        }
        [ -n "$(current_utility_info_uri)" ] && {
            version+="; for more info please visit $(current_utility_info_uri)"
        }
        output "${version}"
        ;;
    "info")
        log_msg "For more info please visit $(current_utility_info_uri)"
        ;;
    "installed")
        printf '%s\n' "true"
        ;;
    "install")
        [[ "$current_file" != "$target_path" ]] || {
            error_exit "Duplicated paths. Aborted."
        }

        local confirm_msg="Are you sure to install $current_filename?"
        local choice="y"
        local force="false"
        local confirmed="false"

        in_array "$option_force" "install" "$EMPTY_EXPR" && force="true"
        in_array "$option_yes" "install" "$EMPTY_EXPR" && confirmed="true"

        if is_installed; then
            choice="n"
            confirm_msg="$current_filename has already been installed at: $target_path. Do you want to reinstall it?"

            if [[ "$force" == "false" ]]; then
                error_exit "$current_filename has already been installed at: $target_path, \
                please use -f if you want to forcefully override it."
            fi
        fi

        if [[ "$confirmed" == "false" ]] && ! confirm "$confirm_msg" "$choice"; then
            error_exit "Aborted."
        fi

        install_script
        ;;
    "view-log")
        vi "$(current_log_file)" 2>/dev/null
        ;;
    "callfunc")
        callfunc $(printf '%s ' "$@")
        ;;
    *)
        is_matched_action="false"
        ;;
    esac

    if [[ "$is_matched_action" == "true" ]]; then
        quit
    fi
}

# Function to check if BISU is installed
is_installed() {
    local target_path=$(target_path)
    is_file "$target_path" || return 1
    return 0
}

# Function: install_script
install_script() {
    if is_installed; then
        log_msg "Detected existing installation, backup will be created."
        local date_str=$(date +'%Y%m')
        local uuid=$(uuidv4)
        local target_path=$(target_path)
        local current_file=$(current_file)
        local current_filename=$(current_filename)
        local backup_dir="$(user_backup_dir)/$date_str"
        local current_utility_version="$(exec_command "${target_path} callfunc current_utility_version")"
        current_utility_version=$(strtolower "$current_utility_version")
        string_starts_with "$current_utility_version" "v" || current_utility_version="v$current_utility_version"
        local backup_path="${backup_dir}/${current_filename}.${current_utility_version}_${uuid}"
        log_msg "Moving $target_path to path: $backup_path"
        mkdir_p "$backup_dir"
        move_file "$target_path" "$backup_path"
        log_msg "Your previous installation has been backed up to: $backup_path"
    fi

    log_msg "Moving $current_filename to path: $target_path"
    exec_command "mv \"$current_file\" \"$target_path\"" || error_exit "Failed to install $current_filename"
    log_msg "Done."
}

# Initialization
initialize $(printf '%s ' "$0" "$@")
########################################################################### BISU_END ###########################################################################
