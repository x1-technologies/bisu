#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
# shellcheck disable=SC2170,SC2219,SC2090,SC2190,SC2145,SC2294,SC2124,SC2139,SC2163,SC2043
########################################################## BISU_START: Bash Internal Simple Utils ##############################################################
## Official Web Site: https://bisu.x1.autos
## Recommended BISU PATH: /usr/local/bin/bisu
## Have a fresh installation of BISU by copying and pasting the command below
## curl -sL https://g.x1.autos/bisu-file -o ./bisu && chmod +x ./bisu && sudo ./bisu -f install
# Define BISU VERSION
readonly BISU_VERSION="11.0.7"
export BISU_VERSION
# Set BISU's last release date
readonly BISU_LAST_RELEASE_DATE="2025-10-20Z"
export BISU_LAST_RELEASE_DATE
# Minimal Bash Version
readonly BISU_MINIMAL_BASH_VERSION="5.0.0"
export BISU_MINIMAL_BASH_VERSION
# BISU info uri
readonly BISU_INFO_URI="https://bisu.x1.autos"
export BISU_INFO_URI
# Default title
export BISU_DEFAULT_TITLE="-bash"
# Auto line-break length
export BISU_LINE_BREAK_LENGTH=240
# Required external commands list
export BISU_REQUIRED_EXTERNAL_COMMANDS=(
    'bash' 'awk' 'sed' 'grep' 'head' 'cut' 'tr' 'od' 'xxd' 'bc' 'uuidgen' 'md5sum' 'tee' 'sort' 'uniq' 'date' 'whoami' 'hostname' 'gpg'
)
# Read-only actions avoiding AML lock
export BISU_ACTIONS_RO=(
    'version' 'v' 'info' 'usage' 'doc' 'help' 'h' 'callfunc' 'installed'
)
# Auto run commands
export BISU_AUTORUN=()
# Required scripts
export BISU_REQUIRED_SCRIPTS=()
# Exit with commands
export BISU_EXIT_WITH_COMMANDS=()
# fork limit for per process
export BISU_SAFE_FORK_LIMIT=16
# BISU Signature verification switch
export BISU_VERIFY_SIG=${BISU_VERIFY_SIG:-"true"}
# Specific Empty Expression
readonly BISU_EMPTY_EXPR="0x00"
export BISU_EMPTY_EXPR
# Set a critical point for adopting awk to Bisu::trim
export BISU_TRIM_CRITICAL_POINT=102400
# Error message prefix
export BISU_ERROR_MSG_PREFIX="[<fg_orange>Error</fg_orange>] "
# BISU File URL
readonly BISU_FILE_URL="https://g.x1.autos/bisu-file"
export BISU_FILE_URL
# BISU ASC File URL
readonly BISU_ASC_FILE_URL="https://g.x1.autos/bisu-asc-file"
export BISU_ASC_FILE_URL
# Global Variables
TMPDIR="/tmp" && [ -w "$TMPDIR" ] || TMPDIR="$(dirname $(mktemp -d))" && export TMPDIR
HOME=${HOME:-$(getent passwd $(id -u) 2>/dev/null | cut -d: -f6)} && export HOME
export PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export BISU_CURRENT_LOG_FILE_DIR=""                                         # Current Log file dir
export BISU_ROOT_LOG_FILE_DIR="/var/log"                                    # Root Log file dir
export BISU_USER_LOG_FILE_DIR="$HOME/.local/var/log"                        # User Log file dir
export BISU_TARGET_PATH_PREFIX="/usr/local/bin"                             # Default target path for moving scripts
export BISU_TERMUX_TARGET_PATH_PREFIX="/data/data/com.termux/files/usr/bin" # Android Termux target path for moving scripts
export BISU_ROOT_LOCK_FILE_DIR="/var/run"
export BISU_USER_LOCK_FILE_DIR="$HOME/.local/var/run"
export BISU_LOCK_FILE_DIR="$TMPDIR"
export BISU_LOCK_ID=""
export BISU_LOCK_FILE=""
export BISU_FIFO_DIR="$TMPDIR/bisu_fifo"
export BISU_KERNEL_INFO=""
export BISU_OS_INFO=""
export BISU_LOG_BUFFER=()
export BISU_START_TIME="$EPOCHREALTIME"
# BISU path
readonly BISU_FILE_PATH="${BASH_SOURCE[0]}"
export BISU_FILE_PATH
# The user's config dir
export BISU_USER_CONF_DIR=""
# BISU start flag
export BISU_START_FLAG=0
# Lock held
export BISU_LOCK_HELD=0
# Machine's current username
export BISU_UNIX_USERNAME=""
# Machine's hostname
export BISU_UNIX_HOSTNAME=""
# The current process id
readonly BISU_CURRENT_UTIL_PID=$$
export BISU_CURRENT_UTIL_PID
# The current file path
readonly BISU_CURRENT_UTIL_FILE_PATH=$(eval printf '%s' "$0")
export BISU_CURRENT_UTIL_FILE_PATH
# The current file name
readonly BISU_CURRENT_UTIL_FILE_NAME=$(basename "$BISU_CURRENT_UTIL_FILE_PATH")
export BISU_CURRENT_UTIL_FILE_NAME
# The current args by the actual script
readonly BISU_CURRENT_UTIL_ARGS=("$@")
export BISU_CURRENT_UTIL_ARGS
# The current command by the actual script
export BISU_CURRENT_UTIL_COMMAND=""
# The action currently specified
export BISU_CURRENT_UTIL_ACTION=""
# Required external commands list
BISU_CURRENT_UTIL_REQUIRED_COMMANDS=(${BISU_CURRENT_UTIL_REQUIRED_COMMANDS[@]:-})
# Read-only actions avoiding AML lock for user definitions
BISU_CURRENT_UTIL_ACTIONS_RO=(${BISU_CURRENT_UTIL_ACTIONS_RO[@]:-})
# Auto run commands
BISU_CURRENT_UTIL_AUTORUN_COMMANDS=(${BISU_CURRENT_UTIL_AUTORUN_COMMANDS[@]:-})
# Required scripts
BISU_CURRENT_UTIL_REQUIRED_SCRIPTS=(${BISU_CURRENT_UTIL_REQUIRED_SCRIPTS[@]:-})
# Exit with commands
BISU_CURRENT_UTIL_EXIT_WITH_COMMANDS=(${BISU_CURRENT_UTIL_EXIT_WITH_COMMANDS[@]:-})
# Set this utility's name
BISU_CURRENT_UTIL_NAME=${BISU_CURRENT_UTIL_NAME:-}
# Set this utility's version number
BISU_CURRENT_UTIL_VERSION=${BISU_CURRENT_UTIL_VERSION:-"1.0"}
# Set this utility's last release date
BISU_CURRENT_UTIL_LAST_RELEASE_DATE=${BISU_CURRENT_UTIL_LAST_RELEASE_DATE:-}
# Set this utility's doc URI
BISU_CURRENT_UTIL_INFO_URI=${BISU_CURRENT_UTIL_INFO_URI:-}
# Set this utility's asc sig file URL
BISU_CURRENT_UTIL_ASC_FILE_URL=${BISU_CURRENT_UTIL_ASC_FILE_URL:-}
# Signature verification switch
BISU_CURRENT_UTIL_VERIFY_SIG=${BISU_CURRENT_UTIL_VERIFY_SIG:-"false"}
# GPG Signature algorithm set
BISU_CURRENT_UTIL_GPG_SIG_ALGO=${BISU_CURRENT_UTIL_GPG_SIG_ALGO:-"sha256"}
# Installation target dir
BISU_CURRENT_UTIL_TARGET_DIR=${BISU_CURRENT_UTIL_TARGET_DIR:-}
# Atomic mutex lock switch for single-threaded utilities
BISU_USE_AML_LOCK=${BISU_USE_AML_LOCK:-"true"}
# Style code injection function
BISU_STYLE_CODE_INJECTION_FUNC=${BISU_STYLE_CODE_INJECTION_FUNC:-"__style_code_injection"}
# Debug Switch
BISU_DEBUG_MODE=${BISU_DEBUG_MODE:-"false"}

# Robust and POSIX-compliant isset function
Bisu::isset() {
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
            pattern='\["?'"$index"'"]='
            if ! [[ $(declare -p "$name" 2>/dev/null) =~ $pattern ]]; then
                return 1
            fi
        fi
    done
    return 0
}

# Adaptive, POSIX-aware trim function (UTF-8 friendly, high-performance)
# Usage: Bisu::trim "string" [chars] [case_insensitive]
#   chars: characters to trim (default: POSIX space class)
#   case_insensitive: "true"|"false"
# Behavior: adaptive threshold controlled by BISU_TRIM_CRITICAL_POINT (non-negative int, default 4096).
#           For inputs >= threshold the function uses awk (robust for large/UTF-8 data).
#           For smaller inputs it uses pure-Bash paths for best performance.
Bisu::trim() {
    local str="$1"
    local chars="${2:-}"
    local raw_ci="${3:-false}"
    local endpoints="${4:-3}"
    local critical_point len use_awk ci

    # Validate and normalize parameters
    [[ "$raw_ci" =~ ^(true|false)$ ]] || raw_ci="false"
    ci=$([[ "$raw_ci" == "true" ]] && echo 1 || echo 0)
    [[ "$endpoints" =~ ^[123]$ ]] || endpoints=3

    # Read from stdin if no arguments
    [[ $# -eq 0 ]] && str=$(cat)

    # Threshold for adaptive path
    critical_point="${BISU_TRIM_CRITICAL_POINT:-4096}"
    [[ "$critical_point" =~ ^[1-9][0-9]*$ ]] || critical_point=4096

    # Choose fast Bash path vs awk path
    len=${#str}
    use_awk=$((len >= critical_point ? 1 : 0))

    # ---- whitespace default fast-path ----
    if [[ "$chars" =~ ^[[:space:]]*$ ]]; then
        if ((use_awk == 0)); then
            # Pure Bash trimming for small strings (UTF-8 safe)
            ((endpoints == 1 || endpoints == 3)) && str="${str#"${str%%[![:space:]]*}"}"
            ((endpoints == 2 || endpoints == 3)) && str="${str%"${str##*[![:space:]]}"}"
            echo "$str"
            return 0
        else
            # Large input: robust awk path
            if ((endpoints == 1)); then
                str=$(awk -v chars='[[:space:]]' -v IGNORECASE="$ci" '{ gsub("^" chars "+",""); print }' <<<"$str" 2>/dev/null)
            elif ((endpoints == 2)); then
                str=$(awk -v chars='[[:space:]]' -v IGNORECASE="$ci" '{ gsub(chars "+$",""); print }' <<<"$str" 2>/dev/null)
            else
                str=$(awk -v chars='[[:space:]]' -v IGNORECASE="$ci" '{ gsub("^" chars "+",""); gsub(chars "+$",""); print }' <<<"$str" 2>/dev/null)
            fi
            echo "$str"
            return 0
        fi
    fi

    # ---- custom characters branch ----
    if ((use_awk == 1)); then
        # Large input: awk path, robust UTF-8
        case $endpoints in
        1) str=$(awk -v chars="[$chars]" -v IGNORECASE="$ci" '{ gsub("^" chars "+",""); print }' <<<"$str" 2>/dev/null) ;;
        2) str=$(awk -v chars="[$chars]" -v IGNORECASE="$ci" '{ gsub(chars "+$",""); print }' <<<"$str" 2>/dev/null) ;;
        3) str=$(awk -v chars="[$chars]" -v IGNORECASE="$ci" '{ gsub("^" chars "+",""); gsub(chars "+$",""); print }' <<<"$str" 2>/dev/null) ;;
        esac
        echo "$str"
        return 0
    fi

    # Small input & custom chars: pure Bash trimming
    local -A trim_map=()
    local ch chkey
    while IFS= read -r -n1 ch; do
        [[ -z "$ch" ]] && continue
        chkey=$([[ "$ci" -eq 1 ]] && echo "${ch,,}" || echo "$ch")
        trim_map["$chkey"]=1
    done <<<"$chars"

    # Left Bisu::trim
    if ((endpoints == 1 || endpoints == 3)); then
        while [[ -n "$str" ]]; do
            ch="${str:0:1}"
            chkey=$([[ "$ci" -eq 1 ]] && echo "${ch,,}" || echo "$ch")
            [[ ${trim_map[$chkey]+_} ]] || break
            str=${str#?}
        done
    fi

    # Right Bisu::trim
    if ((endpoints == 2 || endpoints == 3)); then
        while [[ -n "$str" ]]; do
            ch="${str: -1}"
            chkey=$([[ "$ci" -eq 1 ]] && echo "${ch,,}" || echo "$ch")
            [[ ${trim_map[$chkey]+_} ]] || break
            str=${str%?}
        done
    fi

    echo "$str"
    return 0
}

# Adaptive, POSIX-aware Bisu::ltrim function (UTF-8 friendly, high-performance)
# Usage: Bisu::ltrim "string" [chars] [case_insensitive]
#   chars: characters to Bisu::trim (default: POSIX space class)
#   case_insensitive: "true"|"false" (validated via Bisu::in_array; default "false")
Bisu::ltrim() {
    Bisu::trim "$1" "$2" "$3" "1" || return 1
    return 0
}

# Adaptive, POSIX-aware Bisu::rtrim function (UTF-8 friendly, high-performance)
# Usage: Bisu::rtrim "string" [chars] [case_insensitive]
#   chars: characters to Bisu::trim (default: POSIX space class)
#   case_insensitive: "true"|"false" (validated via Bisu::in_array; default "false")
Bisu::rtrim() {
    Bisu::trim "$1" "$2" "$3" "2" || return 1
    return 0
}

# Function to validate a variable name
Bisu::is_valid_var_name() {
    local var_name="$1"
    var_name="${var_name#"${var_name%%[![:space:]]*}"}" # Bisu::ltrim
    var_name="${var_name%"${var_name##*[![:space:]]}"}" # Bisu::rtrim
    if [[ -z "$var_name" || ! "$var_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        return 1
    fi
    return 0
}

# Function to validate a function name
Bisu::is_valid_func_name() {
    local func_name="$1"
    func_name="${func_name#"${func_name%%[![:space:]]*}"}" # Bisu::ltrim
    func_name="${func_name%"${func_name##*[![:space:]]}"}" # Bisu::rtrim
    if [[ -z "$func_name" || ! "$func_name" =~ ^[a-zA-Z_][a-zA-Z0-9_:]*$ ]]; then
        return 1
    fi
    return 0
}

# Set a variable with validation.
Bisu::set() {
    local name=$(Bisu::trim "$1")
    shift
    Bisu::is_valid_var_name "$name" || return 1
    printf -v "$name" '%s' "$@" 2>/dev/null || return 1
    return 0
}

# get timestamp_sec faster and more robust
Bisu::time_sec() {
    local ts sec

    # Prefer Bash 5+ built-ins for performance and zero external calls
    if [[ -n $EPOCHSECONDS ]]; then
        printf '%d\n' "$EPOCHSECONDS"
        return 0
    fi

    # GNU date fallback
    ts=$(date +%s 2>/dev/null || true)
    # Validate timestamp length (10 digits for seconds)
    if [[ $ts =~ ^[0-9]{10}$ ]]; then
        printf '%s\n' "$ts"
        return 0
    fi

    printf ''
    return 1
}

# get timestamp_ms faster and more robust
Bisu::time_ms() {
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
    ts=$(date +%s%N 2>/dev/null || true)
    # Validate Bisu::output length for seconds+nanoseconds (>=19 digits)
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

    printf ''
    return 1
}

# get timestamp_ns faster and more robust
Bisu::time_ns() {
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

    printf ''
    return 1
}

# BISU file path
Bisu::bisu_file_path() {
    printf '%s' "$BISU_FILE_PATH"
}

# BISU file name
Bisu::bisu_filename() {
    printf '%s' $(basename $(Bisu::bisu_file_path))
}

# Function: Bisu::output a message
Bisu::output() {
    local message="$1"
    local use_newline=$(Bisu::trim "$2")
    Bisu::in_array "$use_newline" "true" "false" || use_newline="true"
    local log_only=$(Bisu::trim "$3")
    Bisu::in_array "$log_only" "true" "false" || log_only="false"

    # Style tag parsing
    [[ $message == *\<*\>* ]] && {
        # style table
        declare -A style_codes=(
            [reset]=$'\033[0m' [bold]=$'\033[1m' [dim]=$'\033[2m' [underline]=$'\033[4m'
            [blink]=$'\033[5m' [reverse]=$'\033[7m' [hidden]=$'\033[8m'
            [fg_black]=$'\033[30m' [fg_red]=$'\033[31m' [fg_green]=$'\033[32m' [fg_yellow]=$'\033[33m' [fg_orange]=$'\033[38;5;166m'
            [fg_blue]=$'\033[34m' [fg_magenta]=$'\033[35m' [fg_cyan]=$'\033[36m' [fg_white]=$'\033[37m'
            [fg_bright_black]=$'\033[90m' [fg_bright_red]=$'\033[91m' [fg_bright_green]=$'\033[92m'
            [fg_bright_yellow]=$'\033[93m' [fg_bright_blue]=$'\033[94m' [fg_bright_magenta]=$'\033[95m'
            [fg_bright_cyan]=$'\033[96m' [fg_bright_white]=$'\033[97m'
            [bg_black]=$'\033[40m' [bg_red]=$'\033[41m' [bg_green]=$'\033[42m' [bg_yellow]=$'\033[43m'
            [bg_blue]=$'\033[44m' [bg_magenta]=$'\033[45m' [bg_cyan]=$'\033[46m' [bg_white]=$'\033[47m'
            [bg_bright_black]=$'\033[100m' [bg_bright_red]=$'\033[101m' [bg_bright_green]=$'\033[102m'
            [bg_bright_yellow]=$'\033[103m' [bg_bright_blue]=$'\033[104m' [bg_bright_magenta]=$'\033[105m'
            [bg_bright_cyan]=$'\033[106m' [bg_bright_white]=$'\033[107m'
        )
        # Inject customized style codes
        if Bisu::is_func "$BISU_STYLE_CODE_INJECTION_FUNC"; then
            local injected_style_codes="$(Bisu::safe_callfunc "$BISU_STYLE_CODE_INJECTION_FUNC" $(printf '%s ' "$@"))"
            injected_style_codes="$(Bisu::trim "$injected_style_codes")"
            [ -n "$injected_style_codes" ] && {
                injected_style_codes=("$injected_style_codes")
                Bisu::assoc_array_merge "style_codes" "injected_style_codes" "style_codes"
            }
        fi

        # Stack of open tags: each entry "ttype:name:start_index"
        # ttype is one of: fx, fg, bg, or "" for unknown (we still track to enforce positional pairing)
        declare -a tag_stack=()

        result="" # built Bisu::output without tag symbols
        seg=""    # accumulating plain text segment
        i=0
        len=${#message}

        # helper: determine tag type from tag name
        _tag_type() {
            case "$1" in
            fg_*) echo "fg" ;;
            bg_*) echo "bg" ;;
            bold | dim | underline | blink | reverse | hidden) echo "fx" ;;
            *) echo "" ;;
            esac
        }

        # helper: compute current outer prefix (top of each type in remaining stack)
        _outer_prefix_from_stack() {
            local prefix=""
            # iterate stack left->right to find last occurrence per type
            local t="" n="" start=""
            local found_fx="" found_fg="" found_bg=""
            for entry in "${tag_stack[@]}"; do
                t="${entry%%:*}"
                n="${entry#*:}"
                n="${n%%:*}" # remove possible :start if present
                case "$t" in
                fx) found_fx="$n" ;;
                fg) found_fg="$n" ;;
                bg) found_bg="$n" ;;
                esac
            done
            [[ -n "$found_fx" ]] && prefix+="${style_codes[$found_fx]}"
            [[ -n "$found_fg" ]] && prefix+="${style_codes[$found_fg]}"
            [[ -n "$found_bg" ]] && prefix+="${style_codes[$found_bg]}"
            printf "%s" "$prefix"
        }

        # single-pass parse
        while ((i < len)); do
            ch="${message:i:1}"

            # ordinary char: accumulate
            if [[ "$ch" != "<" ]]; then
                seg+="$ch"
                ((i++))
                continue
            fi

            # encountered '<' — try to read tag up to next '>'
            j=$((i + 1))
            tag_content=""
            while ((j < len)) && [[ "${message:j:1}" != ">" ]]; do
                tag_content+="${message:j:1}"
                ((j++))
            done

            # if no closing '>' found: treat '<' as literal
            if ((j >= len)); then
                seg+="$ch"
                ((i++))
                continue
            fi

            # We have a full tag: <tag_content>
            full_tag="<${tag_content}>"
            i=$((j + 1)) # advance past '>'

            # Flush accumulated segment with current outer prefix
            outer_prefix="$(_outer_prefix_from_stack)"
            if [[ -n "$seg" ]]; then
                if [[ -n "$outer_prefix" ]]; then
                    result+="${outer_prefix}${seg}${style_codes[reset]}"
                else
                    result+="$seg"
                fi
                seg=""
            fi

            # Normalize tag name: first token up to whitespace (names allow letters/digits/underscore/hyphen)
            raw_tag="$tag_content"
            # strip leading and trailing spaces
            raw_tag="${raw_tag#"${raw_tag%%[![:space:]]*}"}"
            raw_tag="${raw_tag%"${raw_tag##*[![:space:]]}"}"
            if [[ -z "$raw_tag" ]]; then
                # Per rule: paired-but-incorrect symbol removal applies only when closed; single empty tag stay literal now
                seg+="$full_tag"
                continue
            fi

            # Check if closing tag
            if [[ "${raw_tag:0:1}" == "/" ]]; then
                close_name="${raw_tag:1}"
                # If no open tag => unmatched closing, treat literal
                if ((${#tag_stack[@]} == 0)); then
                    seg+="$full_tag"
                    continue
                fi

                # top format: "ttype:name:start"
                top="${tag_stack[-1]}"
                unset 'tag_stack[-1]'
                tag_stack=("${tag_stack[@]}") # reindex
                ttype="${top%%:*}"
                rest="${top#*:}"
                name="${rest%%:*}"
                start_idx="${rest#*:}"

                # If names match -> positional pairing succeeded
                if [[ "$name" == "$close_name" ]]; then
                    # extract inner content that resides in result[start_idx:]
                    inner_len=$((${#result} - start_idx))
                    inner="${result:start_idx:inner_len}"
                    # remove inner from result to replace with styled/kept content
                    result="${result:0:start_idx}"

                    # If tag name maps to a style, apply style wrapper
                    if [[ -n "${style_codes[$name]}" && -n "$ttype" ]]; then
                        # Build outer-prefix after popping current (to restore outers)
                        outer_prefix="$(_outer_prefix_from_stack)"
                        # Compose: style_of_name + inner + reset + outer_prefix
                        result+="${style_codes[$name]}${inner}${style_codes[reset]}${outer_prefix}"
                    else
                        # Known positional pair but name not a style (or unknown type): remove tag symbols only, keep inner unchanged.
                        result+="${inner}"
                    fi
                else
                    # Names mismatch — per rule: remove tag symbols only (keep inner)
                    inner_len=$((${#result} - start_idx))
                    inner="${result:start_idx:inner_len}"
                    result="${result:0:start_idx}${inner}"
                    # Do NOT reapply any outer prefix here (outer remains as is)
                fi

                continue
            fi

            # Opening tag processing
            tag_name="${raw_tag%%[[:space:]]*}"
            ttype="$(_tag_type "$tag_name")"
            tag_stack+=("${ttype}:${tag_name}:${#result}")
            continue
        done

        # End of input: flush trailing seg
        outer_prefix="$(_outer_prefix_from_stack)"
        if [[ -n "$seg" ]]; then
            if [[ -n "$outer_prefix" ]]; then
                result+="${outer_prefix}${seg}${style_codes[reset]}"
            else
                result+="$seg"
            fi
        fi

        # Build a temporary buffer and reinsert at recorded offsets.
        if ((${#tag_stack[@]})); then
            tmp_result=""
            i=0
            idx_stack=0

            for entry in "${tag_stack[@]}"; do
                # entry format ttype:name:start
                name="${entry#*:}"
                name="${name%%:*}"
                tmp_result+="<${name}>"
            done
            result+="$tmp_result"
        fi

        # Final mutate
        message="$result"
    }

    local command
    if [[ "$use_newline" == "true" ]]; then
        command="printf '%b\\n' \"$message\""
    else
        command="printf '%b' \"$message\""
    fi

    if [[ "$log_only" == "true" ]]; then
        eval "$(printf '%s ' "$command")" |
            { Bisu::debug_mode_on && fold -s -w "$BISU_LINE_BREAK_LENGTH" || fold -s -w "$BISU_LINE_BREAK_LENGTH" 2>/dev/null; } |
            tee -a -- "$(Bisu::current_log_file)" &>/dev/null ||
            return 1
    else
        eval "$(printf '%s ' "$command")" |
            { Bisu::debug_mode_on && fold -s -w "$BISU_LINE_BREAK_LENGTH" || fold -s -w "$BISU_LINE_BREAK_LENGTH" 2>/dev/null; } |
            { Bisu::debug_mode_on && tee -a -- "$(Bisu::current_log_file)" || tee -a -- "$(Bisu::current_log_file)" 2>/dev/null; } ||
            return 1
    fi

    return 0
}

# Function to check if a command is existent
Bisu::command_exists() {
    local command=$(Bisu::trim "${1:-}")
    local strict_mode=$(Bisu::trim "${2:-false}")
    Bisu::in_array "$strict_mode" "true" "false" || strict_mode="false"
    [ -n "$command" ] || return 1
    eval "command -v \"$command\"" &>/dev/null &
    local pid=$!
    wait "$pid"
    local status=$?
    [ "$status" -eq 0 ] || {
        [[ "$strict_mode" == "true" ]] && Bisu::error_exit "$command: command not found"
        return 1
    }
    return 0
}

# Function to check if commands are existent
Bisu::command_exists_async() {
    declare -A results # Associative array to store exit statuses keyed by command
    local cmds=("$@") pids=() pid i

    # Validate input: if no commands given, print warning and return
    if [ "${#cmds[@]}" -eq 0 ]; then
        return 0
    fi

    {
        # Launch async existence checks for each command
        for i in "${!cmds[@]}"; do
            local c
            c=$(Bisu::trim "${cmds[i]}")
            # Validate trimmed command and check existence
            Bisu::command_exists "$c" &
            pid=$!
            pids[i]=$pid
        done

        wait "$pid"
        # Wait for all background jobs and collect their exit codes reliably
        for i in "${!pids[@]}"; do
            wait "${pids[i]}"
            results["${cmds[i]}"]=$?
        done

        local inexistent_commands=()
        # Output results in original order
        for cmd in "${cmds[@]}"; do
            if [ "${results[$cmd]}" -ne 0 ]; then
                eval "inexistent_commands+=(\"$cmd\")"
            fi
        done

        printf '%s ' "${inexistent_commands[@]}"
        return 0
    } &
}

# Function to check if a func is defined
Bisu::is_func() {
    local command=$(Bisu::trim "$1")
    [ -n "$command" ] || return 1
    declare -F "$command" &>/dev/null || return 1

    return 0
}

# Function to check if the command is executable
Bisu::is_executable() {
    local command=$(Bisu::trim "$1")
    [ -n "$command" ] || return 1
    if ! Bisu::is_func "$command" && ! Bisu::command_exists "$command"; then
        return 1
    fi

    return 0
}

# Function to check if the process is running
Bisu::process_is_running() {
    local pid="$1"
    pid="${pid#"${pid%%[![:space:]]*}"}" # Bisu::ltrim
    pid="${pid%"${pid##*[![:space:]]}"}" # Bisu::rtrim
    [[ "$pid" =~ ^[1-9][0-9]*$ ]] || exit_code=0
    kill -0 "$pid" &>/dev/null || return 1
    return 0
}

# count processes number by running command
Bisu::processes_count() {
    local cmd=$(Bisu::trim "$1")
    local count=$(ps aux | grep -c "$cmd" 2>/dev/null) || {
        printf '0'
        return 1
    }
    count=$(Bisu::trim "$count")
    Bisu::is_nn_int "$count" || count=0
    printf '%s' "$count"
    return 0
}

# Quit the current command with a protocol-based signal
Bisu::quit() {
    local original_sigterm=$(trap -p SIGTERM)

    local exit_code=$1
    local pid="$2"
    pid="${pid#"${pid%%[![:space:]]*}"}" # Bisu::ltrim
    pid="${pid%"${pid##*[![:space:]]}"}" # Bisu::rtrim
    local quit_group="$3"
    quit_group="${quit_group#"${quit_group%%[![:space:]]*}"}" # Bisu::ltrim
    quit_group="${quit_group%"${quit_group##*[![:space:]]}"}" # Bisu::rtrim
    local force="$4"
    force="${force#"${force%%[![:space:]]*}"}" # Bisu::ltrim
    force="${force%"${force##*[![:space:]]}"}" # Bisu::rtrim

    local command=""
    local signal="TERM"

    if [[ "$pid" == "" ]]; then
        pid=$BISU_CURRENT_UTIL_PID
    fi

    Bisu::is_posi_int "$pid" || {
        Bisu::error_log "Can not terminate the specified process, incorrect pid of '${pid}'" "⚠️"
        return 1
    }

    [[ "$pid" =~ ^[1-9][0-9]*$ ]] || exit 1
    [[ "$exit_code" =~ ^[1-9][0-9]*$ ]] || exit_code=0
    [[ "$quit_group" == "true" || "$quit_group" == "false" ]] || quit_group="true"
    [[ "$force" == "true" || "$force" == "false" ]] || force="false"

    if [[ "$force" == "true" ]]; then
        signal="9"
    fi

    if [[ "$exit_code" != 0 ]]; then
        exit_code=1
    fi

    if Bisu::process_is_running "$pid"; then
        Bisu::execution_time
        if [[ "$pid" == "$BISU_CURRENT_UTIL_PID" ]]; then
            exit $exit_code
        fi

        trap '' SIGTERM 2>/dev/null
        if [[ "$quit_group" == "true" ]]; then
            command="kill -${signal} -- $pid"
        else
            command="kill -${signal} $pid"
        fi
        Bisu::exec_command "$command" "true"
        trap "$original_sigterm" SIGTERM 2>/dev/null
    fi

    exit $exit_code
}

# Dump
Bisu::dump() {
    echo "$@" >&1
    kill -TERM $BISU_CURRENT_UTIL_PID &>/dev/null &
    disown %+ &>/dev/null
    exit 0
}

# Function: Bisu::current_command
# Description: According to its naming
Bisu::current_command() {
    if [ -z "$BISU_CURRENT_UTIL_COMMAND" ]; then
        printf '%s\n' "Invalid current command"
        kill -TERM $BISU_CURRENT_UTIL_PID &>/dev/null &
        disown %+ &>/dev/null
        exit 1
    fi
    printf '%s' "$BISU_CURRENT_UTIL_COMMAND"
}

# Function: Bisu::current_args
# Description: According to its naming
Bisu::current_args() {
    local array_count=$(Bisu::array_count "BISU_CURRENT_UTIL_ARGS")
    [ $array_count -gt 0 ] || printf ''
    printf '%s\n' "${BISU_CURRENT_UTIL_ARGS[@]}"
}

# Function: Bisu::current_file_path
# Description: According to its naming
Bisu::current_file_path() {
    if [ -z $BISU_CURRENT_UTIL_FILE_PATH ] || ! Bisu::is_file "$BISU_CURRENT_UTIL_FILE_PATH"; then
        printf '%s\n' "Invalid current file path: $BISU_CURRENT_UTIL_FILE_PATH"
        kill -TERM $BISU_CURRENT_UTIL_PID &>/dev/null &
        disown %+ &>/dev/null
        exit 1
    fi
    printf '%s' "$BISU_CURRENT_UTIL_FILE_PATH"
}

# Function: Bisu::current_filename
# Description: According to its naming
Bisu::current_filename() {
    if [ -z $BISU_CURRENT_UTIL_FILE_NAME ]; then
        printf '%s\n' "Invalid current file name"
        kill -TERM $BISU_CURRENT_UTIL_PID &>/dev/null &
        disown %+ &>/dev/null
        exit 1
    fi
    printf '%s' "$BISU_CURRENT_UTIL_FILE_NAME"
}

# Function: Bisu::user_conf_dir
# Description: According to its naming
Bisu::user_conf_dir() {
    if [ -z $BISU_USER_CONF_DIR ]; then
        printf '%s\n' "Invalid user conf dir"
        kill -TERM $BISU_CURRENT_UTIL_PID &>/dev/null &
        disown %+ &>/dev/null
        exit 1
    fi
    printf '%s' "$BISU_USER_CONF_DIR"
}

# Function: Bisu::user_backup_dir
# Description: According to its naming
Bisu::user_backup_dir() {
    printf '%s' "$(Bisu::user_conf_dir)/backup"
}

# Function: Bisu::current_dir
# Description: According to its naming
Bisu::current_dir() {
    printf '%s' $(dirname $(Bisu::current_file_path))
}

# The current log file
Bisu::current_log_file() {
    local log_file_dir=""
    local log_file=""
    local filename="$(Bisu::current_filename)"

    [ -n "$filename" ] || {
        printf '%s' "/dev/null"
        return
    }

    if [ -z "$BISU_CURRENT_LOG_FILE_DIR" ]; then
        if Bisu::is_root_user; then
            log_file_dir="$BISU_ROOT_LOG_FILE_DIR"
        else
            log_file_dir="$BISU_USER_LOG_FILE_DIR"
        fi

        log_file_dir=$(Bisu::trim "$log_file_dir")

        [ -n "$log_file_dir" ] || {
            log_file_dir="$HOME/.local/var/run"
        }

        BISU_CURRENT_LOG_FILE_DIR="$log_file_dir"
    fi

    log_file_dir="$BISU_CURRENT_LOG_FILE_DIR"
    Bisu::string_starts_with "$log_file_dir" "$BISU_USER_LOG_FILE_DIR" || Bisu::string_starts_with "$log_file_dir" "$BISU_ROOT_LOG_FILE_DIR" || {
        Bisu::error_log "Failed to mkdir: $log_file_dir"
        printf '%s' "/dev/null"
        return
    }

    local date_str="$(date +'%Y%m%d')"
    Bisu::is_valid_datetime "$date_str" || {
        printf '%s' "/dev/null"
        return
    }

    local month_str=$(Bisu::substr "$date_str" 0 6)
    local day_str=$(Bisu::substr "$date_str" 6 2)
    log_file_dir="$log_file_dir/$filename/$month_str"
    log_file="$log_file_dir/$day_str.log"

    Bisu::is_dir "$log_file_dir" || {
        mkdir -p "$log_file_dir" &>/dev/null || {
            printf '%s' "/dev/null"
            return
        }
        chmod -R 755 "$log_file_dir" &>/dev/null || {
            printf '%s' "/dev/null"
            return
        }
    }

    Bisu::is_file "$log_file" || {
        touch "$log_file" &>/dev/null || {
            printf '%s' "/dev/null"
            return
        }
    }

    Bisu::is_file "$log_file" && [ -w "$log_file" ] || {
        printf '%s' "/dev/null"
        return
    }

    printf '%s' "$log_file"
}

# Function: Bisu::current_tmpdir
# Description: According to its naming
Bisu::tmpdir() {
    if [ -z $TMPDIR ]; then
        printf '%s\n' "Invalid tmpdir"
        kill -TERM $BISU_CURRENT_UTIL_PID &>/dev/null &
        disown %+ &>/dev/null
        exit 1
    fi
    printf '%s' "$TMPDIR"
}

# Add a log record to buffer
Bisu::log_add() {
    Bisu::is_array "BISU_LOG_BUFFER" || {
        Bisu::output "${BISU_ERROR_MSG_PREFIX}Illegal log buffer array."
        Bisu::quit 1
    }

    local msg="$1"
    local display_time=$(Bisu::trim "$2")
    Bisu::in_array "$display_time" "true" "false" || display_time="false"

    if [[ "$display_time" == "true" ]]; then
        Bisu::array_push "BISU_LOG_BUFFER" "$(date +'%Y-%m-%d %H:%M:%S') - $msg" || return 1
    else
        Bisu::array_push "BISU_LOG_BUFFER" "$msg" || return 1
    fi

    return 0
}

# Flush the log buffer to the log file
Bisu::log_flush() {
    Bisu::is_array "BISU_LOG_BUFFER" || {
        Bisu::output "${BISU_ERROR_MSG_PREFIX}Illegal log buffer array."
        Bisu::quit 1
    }

    local output_buffer=$(Bisu::trim "${1:-true}")
    Bisu::in_array "${output_buffer}" "true" "false" || output_buffer="true"
    local log_only=$(Bisu::trim "${2:-false}")
    Bisu::in_array "${log_only}" "true" "false" || log_only="false"
    local array_count=$(Bisu::array_count "BISU_LOG_BUFFER")

    if [[ "$output_buffer" == "true" ]] && [ "$array_count" -gt 0 ]; then
        local content=""
        for log_record in "${BISU_LOG_BUFFER[@]}"; do
            content+="${log_record}\n"
        done

        Bisu::output "$content" "false" "$log_only"
    fi

    BISU_LOG_BUFFER=()
    return 0
}

# Function: Bisu::log_msg
# Description: Log messages with timestamps to a specified log file, with fallback options.
Bisu::log_msg() {
    local msg="$1"
    local log_only=$(Bisu::trim "$2")
    Bisu::in_array "${log_only}" "true" "false" || log_only="false"
    local use_newline=$(Bisu::trim "$3")
    Bisu::in_array "${use_newline}" "true" "false" || use_newline="true"

    Bisu::output "$(date +'%Y-%m-%d %H:%M:%S') - $msg" "$use_newline" "$log_only" || return 1

    return 0
}

# Emoji verification
Bisu::is_emoji() {
    local char=$(Bisu::trim "$1")

    # Empty or multi-char string is not emoji
    [[ -z "$char" ]] && return 1

    # Single-char emojis (general ranges)
    case "$char" in
    # Emoticons block
    [$'\U1F600'-$'\U1F64F']) return 0 ;;
    # Misc Symbols and Pictographs
    [$'\U1F300'-$'\U1F5FF']) return 0 ;;
    # Transport and Map symbols
    [$'\U1F680'-$'\U1F6FF']) return 0 ;;
    # Supplemental Symbols and Pictographs
    [$'\U1F900'-$'\U1F9FF']) return 0 ;;
    # Symbols & Dingbats
    [$'\U2600'-$'\U26FF']) return 0 ;;
    [$'\U2700'-$'\U27BF']) return 0 ;;
    esac

    # Flag emojis (regional indicator pairs) → 2 chars: U+1F1E6–U+1F1FF
    if [[ ${#char} -eq 8 ]]; then # each RI is 4-byte UTF-8
        local c1=${char:0:4} c2=${char:4:4}
        case "$c1$c2" in
        [$'\U1F1E6'-$'\U1F1FF'][$'\U1F1E6'-$'\U1F1FF']) return 0 ;;
        esac
    fi

    # Family/skin-tone sequences (joined with U+200D, variation selectors)
    # Detect presence of key emoji parts + ZWJ
    if [[ "$char" == *$'\u200d'* ]]; then
        return 0
    fi

    return 1
}

# Function: Bisu::error_log
Bisu::error_log() {
    local error_msg="$1"
    local emoji_label=$(Bisu::trim "$2")
    Bisu::is_emoji "$emoji_label" || emoji_label="❗️"
    error_msg="${emoji_label} ${error_msg}"
    Bisu::log_msg "$error_msg" "true" || return 1
    return 0
}

# Function: forcefully terminate and show errors
Bisu::error_exit() {
    local msg=$(Bisu::trim "$1")
    local status_code=$(Bisu::trim "${2:-1}")
    Bisu::is_posi_int "${status_code}" || status_code=1

    [ -n "$msg" ] && {
        Bisu::log_add "${BISU_ERROR_MSG_PREFIX}$msg" "true"
        Bisu::debug_mode_on && {
            # Determine parent and current
            local parent_file="${BASH_SOURCE[0]}"
            local parent_lineno="${BASH_LINENO[0]}"

            local current_file_path=""
            local current_lineno=""

            for i in "${!BASH_SOURCE[@]}"; do
                src="${BASH_SOURCE[i]}"
                if [[ "$src" != "$parent_file" ]]; then
                    current_file_path="$src"
                    current_lineno="${BASH_LINENO[i - 1]:-?}"
                    break
                fi
            done

            [[ -z "$current_file_path" ]] && current_file_path="$parent_file" && current_lineno="$parent_lineno"

            # For parent file
            local parent_line_text
            parent_line_text=$(sed "${parent_lineno}q;d" "$parent_file" 2>/dev/null)
            local parent_charno
            parent_charno=$(awk '{match($0,/[^[:space:]]/); print (RSTART?RSTART:1)}' <<<"$parent_line_text")
            # For current file
            local current_line_text
            current_line_text=$(sed "${current_lineno}q;d" "$current_file_path" 2>/dev/null)
            local current_charno
            current_charno=$(awk '{match($0,/[^[:space:]]/); print (RSTART?RSTART:1)}' <<<"$current_line_text")
            Bisu::log_add "<fg_bright_yellow>Quitted ${status_code}:\n \
    ${current_file_path}:${current_lineno}:${current_charno}\n \
    ${parent_file}:${parent_lineno}:${parent_charno}</fg_bright_yellow>"
        }
        Bisu::log_flush
    }

    Bisu::quit $status_code
}

# The current file's run lock by signed md5 of full path
Bisu::current_lock_file() {
    if [ -z "$BISU_LOCK_ID" ]; then
        local lock_file_dir="$BISU_LOCK_FILE_DIR"
        if ! Bisu::is_dir "$lock_file_dir"; then
            if Bisu::is_root_user; then
                lock_file_dir="$BISU_ROOT_LOCK_FILE_DIR"
            else
                lock_file_dir="$BISU_USER_LOCK_FILE_DIR"
            fi
        fi

        if ! Bisu::is_dir "$lock_file_dir"; then
            lock_file_dir=$(Bisu::tmpdir)
            Bisu::mkdir_p "$lock_file_dir"
        fi

        if ! Bisu::is_dir "$lock_file_dir"; then
            Bisu::error_exit "❗️ Failed to create 🔒 lock_file_dir: ${lock_file_dir}."
        fi

        if Bisu::string_ends_with "$lock_file_dir" "/"; then
            lock_file_dir=$(Bisu::substr "$lock_file_dir" 0 -1)
        fi

        BISU_LOCK_FILE_DIR="$lock_file_dir"
        BISU_LOCK_ID=$(Bisu::md5_sign "$(Bisu::current_command)")
        BISU_LOCK_FILE="$BISU_LOCK_FILE_DIR/$(Bisu::current_filename)_$BISU_LOCK_ID.lock" || {
            Bisu::error_exit "❗️ Failed to set 🔒 lock_file: ${BISU_LOCK_FILE}"
        }
    fi

    if [ -z "$BISU_LOCK_ID" ]; then
        Bisu::error_exit "❗️ Could not set 🔒 lock_id."
    fi

    printf '%s' "$BISU_LOCK_FILE"
    return 0
}

# Get the variable for requirements if it is set.
Bisu::get_importer_var() {
    local var_name=$(Bisu::str_replace $(Bisu::strtoupper $(Bisu::trim "$1")) "-" "_")
    Bisu::isset "$var_name" || Bisu::error_exit "Undefined importer variable: $var_name; Please define it in the importer block <user-customized-variables>."
    printf '%s' "${!var_name}"
}

# Function: Bisu::target_dir
# Description: Installation Bisu::target_dir
Bisu::target_dir() {
    local target_dir="$BISU_TARGET_PATH_PREFIX"
    local os_name=$(Bisu::get_os_name)

    if [[ "$os_name" == "android" ]]; then
        target_dir="$BISU_TERMUX_TARGET_PATH_PREFIX"
    fi

    target_dir=$(Bisu::normalize_path "$target_dir")
    printf '%s' "$target_dir"
}

# Function: Bisu::target_path
# Description: Installation Bisu::target_path
Bisu::target_path() {
    printf '%s' "$(Bisu::target_dir)/$(Bisu::current_filename)"
}

# Function: Bisu::strtolower
# Description: According to its naming
Bisu::strtolower() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

# Function: Bisu::strtoupper
# Description: According to its naming
Bisu::strtoupper() {
    printf '%s' "$1" | tr '[:lower:]' '[:upper:]'
}

# Function: Bisu::substr
# Description: According to its naming
Bisu::substr() {
    local string="$1"
    local offset=$(Bisu::trim "$2")
    local length=$(Bisu::trim "$3")
    local strlen="${#string}"

    [ -z "$length" ] && length="$strlen"

    # Validate integers
    if [[ "$strlen" -eq 0 ]] || ! Bisu::is_int "$offset" || ! Bisu::is_int "$length" ||
        [[ "$length" -eq 0 || $(Bisu::abs "$offset") -gt "$strlen" || $(Bisu::abs "$length") -gt "$strlen" ]]; then
        return 1
    fi

    # Handle negative offset
    ((offset < 0)) && offset=$((strlen + offset))

    # Handle negative length
    ((length < 0)) && length=$((strlen - offset + length))

    # Bounds check
    ((offset + length > strlen)) && length=$((strlen - offset))

    # Extract substring
    echo "${string:offset:length}"
    return 0
}

# Bisu::normalize_string - collapse whitespace, Bisu::trim leading/trailing spaces
# Usage: Bisu::normalize_string "  foo   bar   " [big_spec]
# If no args, reads stdin. big_spec: true=use awk algo, false=use pure bash (default).
Bisu::normalize_string() {
    local input big_spec
    if [ $# -eq 0 ]; then
        input="$(cat)"
    else
        input="$*"
    fi

    big_spec=$(Bisu::trim "${2:-false}")
    Bisu::in_array "$big_spec" "true" "false" || big_spec="false"

    if [[ $big_spec == "true" ]]; then
        # Original awk algorithm as spec reference
        awk '{
            sub(/[ \t]+$/, "")
            gsub(/[ \t]+/, " ")
            print
        }' <<<"$input" 2>/dev/null || {
            printf ''
            return 1
        }
    else
        # Pure Bash5 internal patterns, faster
        input="${input#"${input%%[![:space:]]*}"}" # Bisu::trim leading
        input="${input%"${input##*[![:space:]]}"}" # Bisu::trim trailing
        while [[ $input == *"  "* ]]; do
            input="${input//  / }" # collapse runs of spaces
        done
        # collapse tabs as well
        input="${input//$'\t'/ }"
        printf '%s\n' "$input"
    fi

    return 0
}

# string to boolean result with a candidate value
Bisu::normalize_bool() {
    local var_name=$(Bisu::trim "$1")
    Bisu::isset "$var_name" || Bisu::error_exit "Got an invalid varname when normalizing a bool value"
    local str="${!var_name}"
    local candidate=$(Bisu::trim "${2:-}")
    local strict_mode=$(Bisu::trim "${3:-true}")
    Bisu::in_array "$strict_mode" "true" "false" "0" "1" || strict_mode="true"
    local result="$str"
    Bisu::in_array "$result" "true" "false" "0" "1" || result="$candidate"
    Bisu::in_array "$result" "true" "false" "0" "1" || {
        Bisu::in_array "$strict_mode" "true" "1" && Bisu::error_exit "Invalid bool candidate value"
        return 1
    }
    if [[ "$result" == "1" ]]; then
        result="true"
    elif [[ "$result" == "0" ]]; then
        result="false"
    fi
    Bisu::set "$var_name" "$result" || return 1
    return 0
}

# Bisu::string_join - join array elements with a separator
# Usage: Bisu::string_join "array_name" "sep" [big_spec]
# big_spec: true=use awk algo, false=use pure bash (default).
Bisu::string_join() {
    local array_name sep big_spec
    array_name=$(Bisu::trim "$1")
    sep="$2"

    declare -n arr_ref="$array_name"
    Bisu::array_is_available "$array_name" || {
        printf ''
        return 1
    }

    big_spec=$(Bisu::trim "${3:-false}")
    Bisu::in_array "$big_spec" "true" "false" || big_spec="false"

    if [[ $big_spec == "true" ]]; then
        # Original awk algorithm for big-spec reference
        printf '%s\n' "${arr_ref[@]}" | awk -v ORS="" -v sep="$sep" '
        {
            if (NR == 1) out = $0;
            else out = out sep $0;
        }
        END { print out }' 2>/dev/null || {
            printf ''
            return 1
        }
    else
        # Pure Bash5 implementation (fastest)
        local out=""
        local first=true
        for elem in "${arr_ref[@]}"; do
            if $first; then
                out="$elem"
                first=false
            else
                out+="$sep$elem"
            fi
        done
        printf '%s\n' "$out"
    fi

    return 0
}

# Function: Bisu::normalize_number
# Description: Normalizes a number string by removing unnecessary leading zeros,
#              trailing zeros after decimal point, and unnecessary decimal point
# Usage: Bisu::normalize_number "number_string"
# Returns: Normalized number string, or empty string on failure
# Exit status: 0 on success, 1 on failure
Bisu::normalize_number() {
    # Validate number of arguments
    if [[ $# -ne 1 ]]; then
        printf ''
        return 1
    fi

    local input=$(Bisu::trim "$1")
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

# Function: Bisu::md5_sign
# Description: Compute SHA1 hash of a string, robust and consistent with Bisu::md5_sign
Bisu::md5_sign() {
    printf '%s' $(Bisu::trim "$1") | md5sum 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::sha1_sign
# Description: Compute SHA1 hash of a string, robust and consistent with Bisu::sha1_sign
Bisu::sha1_sign() {
    Bisu::command_exists "sha1sum" "true"
    printf '%s' "$(Bisu::trim "$1")" | sha1sum 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::sha224_sign
# Description: Compute SHA224 hash of a string, robust and consistent with Bisu::sha224_sign
Bisu::sha224_sign() {
    Bisu::command_exists "sha224sum" "true"
    printf '%s' "$(Bisu::trim "$1")" | sha224sum 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::sha256_sign
# Description: Compute SHA256 hash of a string, robust and consistent with Bisu::sha256_sign
Bisu::sha256_sign() {
    Bisu::command_exists "sha256sum" "true"
    printf '%s' "$(Bisu::trim "$1")" | sha256sum 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::sha384_sign
# Description: Compute SHA384 hash of a string, robust and consistent with Bisu::sha384_sign
Bisu::sha384_sign() {
    Bisu::command_exists "sha384sum" "true"
    printf '%s' "$(Bisu::trim "$1")" | sha384sum 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::sha512_sign
# Description: Compute SHA512 hash of a string, robust and consistent with Bisu::sha512_sign
Bisu::sha512_sign() {
    Bisu::command_exists "sha512sum" "true"
    printf '%s' "$(Bisu::trim "$1")" | sha512sum 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::md5_file
# Description: Sign a md5 hash for a file
Bisu::md5_file() {
    local file=$(Bisu::trim "$1")
    Bisu::is_file "$file" && [ -r "$file" ] || {
        printf ''
        return 1
    }
    md5sum "$file" 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::sha1_file
# Description: Generate SHA-1 hash for a file
Bisu::sha1_file() {
    Bisu::command_exists "sha1sum" "true"
    local file
    file=$(Bisu::trim "$1")
    Bisu::is_file "$file" && [ -r "$file" ] || {
        printf ''
        return 1
    }
    sha1sum "$file" 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::sha224_file
# Description: Generate SHA-224 hash for a file
Bisu::sha224_file() {
    Bisu::command_exists "sha224sum" "true"
    local file
    file=$(Bisu::trim "$1")
    Bisu::is_file "$file" && [ -r "$file" ] || {
        printf ''
        return 1
    }
    sha224sum "$file" 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::sha256_file
# Description: Generate SHA-256 hash for a file
Bisu::sha256_file() {
    Bisu::command_exists "sha256sum" "true"
    local file
    file=$(Bisu::trim "$1")
    Bisu::is_file "$file" && [ -r "$file" ] || {
        printf ''
        return 1
    }
    sha256sum "$file" 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::sha384_file
# Description: Generate SHA-384 hash for a file
Bisu::sha384_file() {
    Bisu::command_exists "sha384sum" "true"
    local file
    file=$(Bisu::trim "$1")
    Bisu::is_file "$file" && [ -r "$file" ] || {
        printf ''
        return 1
    }
    sha384sum "$file" 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# Function: Bisu::sha512_file
# Description: Generate SHA-512 hash for a file
Bisu::sha512_file() {
    Bisu::command_exists "sha512sum" "true"
    local file
    file=$(Bisu::trim "$1")
    Bisu::is_file "$file" && [ -r "$file" ] || {
        printf ''
        return 1
    }
    sha512sum "$file" 2>/dev/null | awk '{print $1}' || {
        printf ''
        return 1
    }
    return 0
}

# PHP-like function as its naming
Bisu::strpos() {
    # Assign core args
    local haystack="$1"
    local needle="$2"
    local offset="${3:-0}"
    local ci=$(Bisu::trim "$4")
    Bisu::in_array "$ci" "true" "false" || ci="false"
    local reverse=$(Bisu::trim "$5")
    Bisu::in_array "$reverse" "true" "false" || reverse="false"

    [ -n "$haystack" ] && [ -n "$needle" ] || {
        printf '%s' "false"
        return 1
    }
    Bisu::is_nn_int "$offset" || {
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

    Bisu::is_nn_int "$pos" || {
        printf '%s' "false"
        return 1
    }

    [ "$offset" -gt 0 ] && pos=$((pos + offset))

    printf '%s' "$pos"
    return 0
}

# PHP-like function as its naming
Bisu::stripos() {
    Bisu::strpos "$1" "$2" "$3" "true" "false" || return 1
    return 0
}

# PHP-like function as its naming
Bisu::strrpos() {
    Bisu::strpos "$1" "$2" "$3" "false" "true" || return 1
    return 0
}

# PHP-like function as its naming
Bisu::strripos() {
    Bisu::strpos "$1" "$2" "$3" "true" "true" || return 1
    return 0
}

# PHP-like function as its naming
Bisu::strlen() {
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

    Bisu::is_nn_int "$length" || {
        printf '%s' "0"
        return 1
    }

    # Output length or empty string on failure
    printf '%s' "$length"
    return 0
}

# PHP-like function as its naming
Bisu::strstr() {
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
Bisu::stristr() {
    local haystack="$1"
    local needle="$2"
    local result=""

    # Check if inputs are provided and valid
    if [ -z "$needle" ]; then
        Bisu::output "Needle cannot be empty"
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
Bisu::string_starts_with() {
    local string=$1
    local phrase=$2
    local ignore_case=$(Bisu::trim "$3")
    Bisu::in_array "${ignore_case}" "true" "false" || ignore_case="false"
    local pos

    if [[ "$ignore_case" == "true" ]]; then
        pos=$(Bisu::stripos "$string" "$phrase")
    else
        pos=$(Bisu::strpos "$string" "$phrase")
    fi

    if [[ "$pos" != "0" ]]; then
        return 1
    fi

    return 0
}

# Check string end with
Bisu::string_ends_with() {
    local string=$1
    local phrase=$2
    local ignore_case=$(Bisu::trim "$3")
    Bisu::in_array "${ignore_case}" "true" "false" || ignore_case="false"
    local pos strlen phraselen

    if [[ "$ignore_case" == "true" ]]; then
        pos=$(Bisu::strripos "$string" "$phrase")
    else
        pos=$(Bisu::strrpos "$string" "$phrase")
    fi

    strlen=$(Bisu::strlen "$string")
    phraselen=$(Bisu::strlen "$phrase")
    if [[ "$pos" != $(($strlen - $phraselen)) ]]; then
        return 1
    fi

    return 0
}

# continuous spaces count
Bisu::cspaces_count() {
    local input="$1"
    [[ "$input" =~ [[:space:]]+ ]] || {
        printf '0'
        return 1
    }
    local count=$(printf '%s' "$input" | grep -o ' ' | wc -l 2>/dev/null) || {
        printf '0'
        return 1
    }
    count=$(Bisu::trim "$count")
    Bisu::is_nn_int "$count" || count=0
    printf '%s' "$count"
    return 0
}

# Bisu::str_replace
# Replace all occurrences of a string with another string.
# Usage:
#   Bisu::str_replace <string> <search> <replace>
# Returns:
#   0 if successful, 1 if an error occurs.
Bisu::str_replace() {
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
        local cspaces_count=$(Bisu::cspaces_count "$replace")
        cspaces=$(printf '%*s' $cspaces_count '')

        haystack=$(awk -v needle="$needle" -v replace="$replace" -v ORS="$cspaces" '
            BEGIN { IGNORECASE=0 }
            { gsub(needle, replace); print }
        ' <<<"$haystack" 2>/dev/null)
    done

    printf '%s' "$haystack"
    return 0
}

# Bisu::str_ireplace
# Replace all occurrences of a string with another string, case-insensitively.
# Usage:
#   Bisu::str_ireplace <string> <search> <replace>
# Returns:
#   0 if successful, 1 if an error occurs.
Bisu::str_ireplace() {
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
        local cspaces_count=$(Bisu::cspaces_count "$replace")
        cspaces=$(printf '%*s' $cspaces_count '')

        haystack=$(awk -v needle="$needle" -v replace="$replace" -v ORS="$cspaces" '
            BEGIN { IGNORECASE=0 }
            { gsub(needle, replace); print }
        ' <<<"$haystack" 2>/dev/null)
    done

    printf '%s' "$haystack"
    return 0
}

# Convert a string into an array (lossless, robust)
Bisu::string_to_array() {
    local input="$1"
    local array_name=$(Bisu::trim "$2")
    Bisu::is_valid_var_name "$array_name" || return 1

    declare -n arr_ref="$array_name"
    arr_ref=()

    # Empty input → nothing
    input=$(Bisu::trim "$input" "() ")
    [ -n "$input" ] || return 0

    # Matched assoc supplement
    if [[ "$input" =~ ^[[:space:]]*([A-Za-z_][A-Za-z0-9_]*)[[:space:]]*=[[:space:]]*(.*)$ ]]; then
        Bisu::set "arr_ref" "$input" || return 1
        eval "declare -gA ${array_name}=($arr_ref)" 2>/dev/null || return 1
        return 0
    fi

    # If input contains newline (from Bisu::current_args), use mapfile directly
    if [[ "$input" == *$'\n'* ]]; then
        mapfile -t arr_ref <<<"$input"
        return 0
    fi

    # Else split by delimiter (default = space, can be customized)
    local delim="${3:-" "}"
    local delim_awk
    case "$delim" in
    '.' | '[' | ']' | '\\' | '^' | '$' | '*' | '+' | '?' | '(' | ')' | '|') delim_awk="\\$delim" ;;
    $'\t') delim_awk="\\t" ;;
    *) delim_awk="$delim" ;;
    esac

    mapfile -t arr_ref < <(
        printf '%s\n' "$input" |
            awk -v FS="$delim_awk" '{
            for (i = 1; i <= NF; i++) print $i;
            if (length($0) > 0 && substr($0, length($0), 1) == FS) print "";
        }'
    ) 2>/dev/null || return 1

    return 0
}

# compare 2 files, if they have identical contents then return 0
Bisu::compare_files() {
    local file1=$(Bisu::trim "$1")
    local file2=$(Bisu::trim "$2")

    Bisu::is_file "$file1" || return 1
    Bisu::is_file "$file2" || return 1
    Bisu::exec_command "cmp -s \"$file1\" \"$file2\"" || return 1

    return 0
}

# Remove lines matching a pattern from a specified file (robust and efficient)
Bisu::remove_matched_lines() {
    local file=$(Bisu::trim "$1") # The file to modify
    local pattern="$2"            # The pattern to match and remove
    local tmp_file                # Temporary file for processing

    # Ensure file and pattern are provided
    [ -n "$file" ] && [ -n "$pattern" ] || return 1

    # Ensure file exists
    Bisu::is_file "$file" || return 1

    # Create a temporary file for Bisu::output
    tmp_file=$(mktemp) || return 1

    # Remove matched lines using a while loop with awk to process each line
    while IFS= read -r line; do
        # Using awk to check if the line matches the pattern
        printf '%s\n' "$line" | awk -v pat="$pattern" '{if ($0 !~ pat) print $0}' 2>/dev/null >>"$tmp_file"
    done <"$file" || return 1

    # Check if any changes were made, and compare the files
    if Bisu::compare_files "$file" "$tmp_file"; then
        local base_dir=$(dirname "$tmp_file")
        Bisu::is_file "$tmp_file" || return 0
        Bisu::saferm "$tmp_file" "$base_dir" || return 1
    else
        Bisu::move_file "$tmp_file" "$file" || return 1
    fi

    return 0
}

# Check if the current user is root (UID 0)
Bisu::is_root_user() {
    if [[ "$(id -u)" != 0 ]]; then
        return 1
    fi
    return 0
}

# debug mode switch checker
Bisu::debug_mode_on() {
    Bisu::in_array "$BISU_DEBUG_MODE" "true" "false" || BISU_DEBUG_MODE="false"
    [[ "$BISU_DEBUG_MODE" == "true" ]] || return 1
    return 0
}

# Execute command
Bisu::exec_command() {
    local phrase=$(Bisu::trim "$1")
    Bisu::string_to_array "$phrase" "phrase"
    Bisu::array_shift "phrase" "cmd"
    local args=$(Bisu::trim "$(printf '%s ' "${phrase[@]}")")
    phrase="$(printf '%s ' "${cmd} ${args}")"

    Bisu::is_executable "$cmd" || return 1

    local run_in_bg=$(Bisu::trim "$2")
    Bisu::in_array "${run_in_bg}" "true" "false" || run_in_bg="false"
    local log_file=$(Bisu::current_log_file)
    local logging=$(Bisu::trim "$3")
    Bisu::in_array "${logging}" "true" "false" || logging="true"

    Bisu::log_msg "🕒 Command executing: $phrase" "true"
    if [[ "$run_in_bg" == "false" ]]; then
        if [[ "$logging" == "true" ]]; then
            Bisu::debug_mode_on && eval "$(printf '%s' "$phrase")" 2>&1 || eval "$(printf '%s' "$phrase")" 2>/dev/null |
                tee -a -- "$(Bisu::current_log_file)" || {
                Bisu::error_log "Last execution failure was from: $phrase"
                return 1
            }
        else
            Bisu::debug_mode_on && eval "$(printf '%s' "$phrase")" 2>&1 || eval "$(printf '%s' "$phrase")" 2>/dev/null || {
                Bisu::error_log "Last execution failure was from: $phrase"
                return 1
            }
        fi
    else
        pid=$(Bisu::safe_fork "$phrase" "true" "$logging") || {
            Bisu::error_log "Last execution failure was from: $phrase"
            return 1
        }
    fi

    Bisu::log_msg "✅ Command execution done: $phrase" "true"
    return 0
}

# Confirmation method
Bisu::confirm() {
    local message=$(Bisu::trim "$1")
    local default=$(Bisu::trim "$2")
    local prompt="[y/n]"

    case "$default" in
    [Yy]*) prompt="[Y/n]" ;; # Default Yes (uppercase Y)
    [Nn]*) prompt="[y/N]" ;; # Default No (uppercase N)
    esac

    while [ 0 ]; do
        Bisu::log_msg "$message" "true"
        read -p "- ${message} ${prompt} " -r input

        # If user just presses Enter, use default
        input=$(Bisu::trim "$input")
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
Bisu::normalize_path() {
    # Trim spaces and handle parameters (assumes Bisu::trim and Bisu::in_array exist)
    local file=$(Bisu::trim "$1")
    local check_base_existence=$(Bisu::trim "${2:-false}")
    Bisu::in_array "$check_base_existence" "true" "false" || check_base_existence="false"

    # Preserve original semantics: empty input (after trim) -> return empty string
    if [ -z "$file" ]; then
        printf ''
        return 0
    fi

    # Convert relative paths to absolute paths (kept identical to original logic)
    case "$file" in
    /*) : ;; # Already absolute
    ~*) file="${HOME}${file#~}" ;;
    .) file="$(pwd)" ;;                                   # Convert "." to PWD
    ..) file="$(cd .. && pwd)" ;;                         # Convert ".." to absolute path
    ./*) file="$(pwd)/${file#./}" ;;                      # Handle "./file"
    ../*) file="$(cd "${file%/*}" && pwd)/${file##*/}" ;; # Handle "../file"
    *) file="$(pwd)/$file" ;;                             # Convert other relative paths
    esac

    # --------------------------
    # Path normalization (pure bash, adaptive low-cost loop)
    # - collapse repeated slashes using parameter-expansion in a loop until no '//' remains
    # - remove '/./' segments
    # - remove trailing '/.' if present
    # - trim trailing whitespace
    # - remove trailing slashes except for root '/'
    # --------------------------

    # Adaptive low-cost collapse of repeated '//' sequences (logarithmic behavior for long runs)
    while [[ "$file" == *//* ]]; do
        file=${file//\/\//\/}
    done

    # remove all '/./' occurrences
    file=${file//\/.\//\/}

    # remove trailing '/.' if present
    case "$file" in
    */.) file=${file%/.} ;;
    esac

    # trim trailing whitespace (spaces, tabs, newlines) using parameter-expansion idiom
    # compute trailing whitespace suffix then remove it
    local _trail="${file##*[![:space:]]}"
    file="${file%"$_trail"}"

    # remove trailing slashes but keep root "/" intact
    if [ "$file" != "/" ]; then
        file="${file%"${file##*[!/]}"}"
        # if result becomes empty (input was non-empty but all slashes), coerce to "/"
        [ -z "$file" ] && file="/"
    fi

    # Final output: if check_base_existence requested, only output if path exists; else output normalized path
    if [[ "$check_base_existence" == "true" ]]; then
        [ -e "$file" ] && printf '%s' "$file" || printf ''
    else
        printf '%s' "$file"
    fi
    return 0
}

# Function: Bisu::add_env_path
# Description: To robustly add new path to append
Bisu::add_env_path() {
    local new_path=$(Bisu::trim "$1")

    # Check if the directory exists
    Bisu::is_dir "$new_path" || {
        Bisu::error_log "The directory '${new_path}' does not exist."
        return 1
    }

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

# Bisu::is_numeric - validate Go-style numeric literals (pure Bash5)
# Returns 0 when legal, 1 otherwise. Relies on Bisu::trim "$1".
Bisu::is_numeric() {
    local raw s imag
    raw=$(Bisu::trim "$1")
    [[ -n $raw ]] || return 1

    # strip trailing imaginary 'i'
    if [[ ${raw: -1} == i ]]; then
        imag=1
        s=${raw:0:-1}
    else
        imag=0
        s=$raw
    fi

    # strip leading sign
    if [[ ${s:0:1} == '+' || ${s:0:1} == '-' ]]; then
        s=${s:1}
    fi
    [[ -n $s ]] || return 1

    # digit-group patterns (underscores allowed only between digits)
    local DEC='[0-9]+(_[0-9]+)*'
    local BIN='[01]+(_[01]+)*'
    local OCT='[0-7]+(_[0-7]+)*'
    local HEX='[0-9A-Fa-f]+(_[0-9A-Fa-f]+)*'

    # exponent patterns (digits may contain underscores between digits)
    local DEC_EXP='[eE][+-]?'$DEC
    local HEX_EXP='[pP][+-]?'$DEC

    # decimal anchors
    local re_dec_int="^(${DEC})$"
    local re_dec_flt_a="^(${DEC})\\.(${DEC})?(${DEC_EXP})?$"
    local re_dec_flt_b="^(${DEC})(${DEC_EXP})$"
    local re_dec_flt_c="^\\.(${DEC})(${DEC_EXP})?$"

    # ----- Branch by prefix/format ----- #
    if [[ $s =~ ^0[xX] ]]; then
        # hex integer or hex float (0x...p...)
        [[ $s =~ ^0[xX]_[0-9A-Fa-f] ]] && return 1
        [[ $s =~ ^0[xX](${HEX}(\.${HEX})?|\.${HEX})${HEX_EXP}$ ]] && return 0
        [[ $s =~ ^0[xX]${HEX}$ ]] && return 0
        return 1
    fi

    if [[ $s =~ ^0[bB] ]]; then
        [[ $s =~ ^0[bB]_[01] ]] && return 1
        [[ $s =~ ^0[bB]${BIN}$ ]] && return 0 || return 1
    fi

    if [[ $s =~ ^0[oO] ]]; then
        [[ $s =~ ^0[oO]_[0-7] ]] && return 1
        [[ $s =~ ^0[oO]${OCT}$ ]] && return 0 || return 1
    fi

    # legacy leading-zero octal: only when it's an integer (no dot, no exponent/prefix)
    if [[ ${#s} -gt 1 && $s =~ ^0 && ! $s =~ [.\'eEpP] && ! $s =~ ^0[xXbBoO] ]]; then
        local rest="${s:1}"
        [[ ${rest:0:1} == "_" ]] && return 1
        [[ $rest =~ ^${OCT}$ ]] && return 0 || return 1
    fi

    # decimal integer or float (including forms like 0.625, .5, 1e3)
    if [[ $s =~ $re_dec_int || $s =~ $re_dec_flt_a || $s =~ $re_dec_flt_b || $s =~ $re_dec_flt_c ]]; then
        return 0
    fi

    return 1
}

# positive numeric validator
Bisu::is_posi_numeric() {
    local num=$(Bisu::trim "$1")
    Bisu::is_numeric "$num" || return 1
    [[ "$num" > 0 ]] || return 1
    return 0
}

# natural number validator
Bisu::is_nn() {
    local num=$(Bisu::trim "$1")
    Bisu::is_numeric "$num" || return 1
    [[ "$num" > 0 || "$num" == 0 ]] || return 1
    return 0
}

# negative numeric validator
Bisu::is_nega_numeric() {
    local num=$(Bisu::trim "$1")
    Bisu::is_numeric "$num" || return 1
    [[ "$num" < 0 ]] || return 1
    return 0
}

# get a number's absolute value (Go-spec compliant)
Bisu::abs() {
    local num
    num=$(Bisu::trim "$1")
    [[ -n $num ]] || {
        printf ''
        return 1
    }

    # Ensure number is valid Go numeric literal
    Bisu::is_numeric "$num" || {
        printf ''
        return 1
    }

    # Strip leading + or -
    [[ ${num:0:1} == '+' || ${num:0:1} == '-' ]] && num=${num:1}

    printf '%s' "$num"
    return 0
}

# Check if it's int
Bisu::is_int() {
    local num=$(Bisu::trim "$1")
    [ -n "$num" ] || return 1
    [[ "$num" =~ ^(0|-?[1-9][0-9]*)$ ]] || return 1
    return 0
}

# positive int validator
Bisu::is_posi_int() {
    local num=$(Bisu::trim "$1")
    Bisu::is_int "$num" || return 1
    [ "$num" -gt 0 ] || return 1
    return 0
}

# natural int validator
Bisu::is_nn_int() {
    local num=$(Bisu::trim "$1")
    Bisu::is_int "$num" || return 1
    [ "$num" -ge 0 ] || return 1
    return 0
}

# negative int validator
Bisu::is_nega_int() {
    local num=$(Bisu::trim "$1")
    Bisu::is_int "$num" || return 1
    [ "$num" -lt 0 ] || return 1
    return 0
}

# positive int validator
Bisu::is_unsigned_int() {
    Bisu::is_posi_int "$1" || return 1
    return 0
}

# Check if it's int
Bisu::is_float() {
    local num=$(Bisu::trim "$1")
    [ -n "$num" ] || return 1
    [[ "$num" =~ ^-?[1-9]?[0-9]*\.[0-9]+$ ]] || return 1
    return 0
}

# positive float validator
Bisu::is_posi_float() {
    local num=$(Bisu::trim "$1")
    Bisu::is_float "$num" || return 1
    [ "$num" -gt 0 ] || return 1
    return 0
}

# natural float validator
Bisu::is_nn_float() {
    local num=$(Bisu::trim "$1")
    Bisu::is_float "$num" || return 1
    [ "$num" -ge 0 ] || return 1
    return 0
}

# negative float validator
Bisu::is_nega_float() {
    local num=$(Bisu::trim "$1")
    Bisu::is_float "$num" || return 1
    [ "$num" -lt 0 ] || return 1
    return 0
}

# positive float validator
Bisu::is_unsigned_float() {
    Bisu::is_posi_float "$1" || return 1
    return 0
}

# Increase a number to the next integer (ceiling)
# Usage: Bisu::ceil "<number>" [big_spec]
#   big_spec: "true" -> use awk backup mode; "false" -> use fast Bash internal mode (default)
# Returns: prints the ceil and returns 0 on success; prints '' and returns 1 on error.
Bisu::ceil() {
    local input result
    local big_spec
    big_spec=$(Bisu::trim "${2:-false}")
    Bisu::in_array "$big_spec" "true" "false" || big_spec="false"

    input=$(Bisu::trim "$1")
    [[ -n $input ]] || {
        printf ''
        return 1
    }

    # reject imaginary numbers (not supported)
    if [[ ${input: -1} == i ]]; then
        printf ''
        return 1
    fi

    # split sign for fast path handling
    local s sign abs_nounders intpart frac
    s=$input
    sign=''
    if [[ ${s:0:1} == '+' || ${s:0:1} == '-' ]]; then
        sign=${s:0:1}
        s=${s:1}
    fi
    [[ -n $s ]] || {
        printf ''
        return 1
    }

    # If complex numeric forms present or backup requested -> use awk backup
    if [[ $big_spec == "true" || $s =~ [pP] || $s =~ [eE] || $s =~ ^0[xX] || $s =~ ^0[bB] || $s =~ ^0[oO] ]]; then
        result=$(printf '%s\n' "$input" | awk '{
            v = $0 + 0
            if (v != v) { exit 1 }
            if (v == int(v)) { printf "%d", int(v); exit 0 }
            if (v > 0) { printf "%d", int(v) + 1; exit 0 }
            printf "%d", int(v); exit 0
        }' 2>/dev/null)
        [[ -n $result ]] && {
            printf '%s' "$result"
            return 0
        }
        printf ''
        return 1
    fi

    # Fast Bash decimal handling (common cases)
    abs_nounders=${s//_/}

    if [[ $abs_nounders == *.* ]]; then
        intpart=${abs_nounders%%.*}
        frac=${abs_nounders#*.}
        [[ -z $intpart ]] && intpart=0
        [[ -z $frac ]] && frac=""

        # exact integer (fraction empty or all zeros)
        if [[ -z $frac || $frac =~ ^0+$ ]]; then
            if [[ $sign == '-' && $intpart != 0 ]]; then
                printf '%s' "-$intpart"
                return 0
            else
                printf '%s' "$intpart"
                return 0
            fi
        fi

        # non-integer with fractional part
        if [[ $sign == '-' ]]; then
            # ceil(negative non-integer) => -intpart (except -0 -> 0)
            if [[ $intpart == 0 ]]; then
                printf '0'
                return 0
            else
                printf '%s' "-$intpart"
                return 0
            fi
        else
            # positive non-integer: intpart + 1
            result=$((intpart + 1))
            printf '%s' "$result"
            return 0
        fi
    else
        # integer (no dot)
        if [[ $abs_nounders =~ ^0+$ ]]; then
            printf '0'
            return 0
        fi
        if [[ $sign == '-' ]]; then
            printf '%s' "-$abs_nounders"
            return 0
        else
            printf '%s' "$abs_nounders"
            return 0
        fi
    fi
}

# Decrease a number to the previous integer (floor)
# Usage: Bisu::floor "<number>" [big_spec]
#   big_spec: "true" -> use awk backup mode; "false" -> use fast Bash internal mode (default)
# Returns: prints the floor and returns 0 on success; prints '' and returns 1 on error.
Bisu::floor() {
    local input result
    local big_spec
    big_spec=$(Bisu::trim "${2:-false}")
    Bisu::in_array "$big_spec" "true" "false" || big_spec="false"

    input=$(Bisu::trim "$1")
    [[ -n $input ]] || {
        printf ''
        return 1
    }

    # Reject imaginary numbers (not supported)
    if [[ ${input: -1} == i ]]; then
        printf ''
        return 1
    fi

    # Validate numeric (relies on existing Bisu::is_numeric)
    if ! Bisu::is_numeric "$input"; then
        printf ''
        return 1
    fi

    # Split sign for fast path handling
    local s sign abs_nounders intpart frac
    s=$input
    sign=''
    if [[ ${s:0:1} == '+' || ${s:0:1} == '-' ]]; then
        sign=${s:0:1}
        s=${s:1}
    fi
    [[ -n $s ]] || {
        printf ''
        return 1
    }

    # If complex numeric forms present or backup requested -> use awk backup
    if [[ $big_spec == "true" || $s =~ [pP] || $s =~ [eE] || $s =~ ^0[xX] || $s =~ ^0[bB] || $s =~ ^0[oO] ]]; then
        result=$(printf '%s\n' "$input" | awk '{
            v = $0 + 0
            if (v != v) { exit 1 }                           # not a number for awk
            if (v == int(v)) { printf "%d", int(v); exit 0 } # exact integer
            if (v >= 0) { printf "%d", int(v); exit 0 }      # positive non-integer -> trunc toward 0 is floor
            printf "%d", int(v) - 1; exit 0                  # negative non-integer -> floor is int(v)-1
        }' 2>/dev/null)
        [[ -n $result ]] && {
            printf '%s' "$result"
            return 0
        }
        printf ''
        return 1
    fi

    # ---------- Fast Bash internal mode (common decimal cases) ----------
    abs_nounders=${s//_/}

    if [[ $abs_nounders == *.* ]]; then
        intpart=${abs_nounders%%.*}
        frac=${abs_nounders#*.}
        [[ -z $intpart ]] && intpart=0
        [[ -z $frac ]] && frac=""

        # exact integer (fraction empty or all zeros)
        if [[ -z $frac || $frac =~ ^0+$ ]]; then
            # respect sign except treat "-0" as "0"
            if [[ $sign == '-' && $intpart != 0 ]]; then
                printf '%s' "-$intpart"
                return 0
            else
                printf '%s' "$intpart"
                return 0
            fi
        fi

        # non-integer with fractional part
        if [[ $sign == '-' ]]; then
            # negative non-integer -> floor = -(intpart + 1)
            result=$((intpart + 1))
            printf '%s' "-$result"
            return 0
        else
            # positive non-integer -> floor is integer part
            printf '%s' "$intpart"
            return 0
        fi
    else
        # No dot -> integer already (remove leading-zero groups gracefully)
        if [[ $abs_nounders =~ ^0+$ ]]; then
            printf '0'
            return 0
        fi
        if [[ $sign == '-' ]]; then
            printf '%s' "-$abs_nounders"
            return 0
        else
            printf '%s' "$abs_nounders"
            return 0
        fi
    fi
}

# Function: Bisu::is_file
# Description: According to its naming
Bisu::is_file() {
    local filepath=$(Bisu::trim "$1")
    [[ -n "$filepath" && -f "$filepath" ]] || return 1
    return 0
}

# Function: Bisu::is_dir
# Description: According to its naming
Bisu::is_dir() {
    local dirpath=$(Bisu::trim "$1")
    [[ -n "$dirpath" && -d "$dirpath" ]] || return 1
    return 0
}

# Check if a directory is empty, excluding '.' and '..', with robust handling
Bisu::is_empty_dir() {
    local dirpath=$(Bisu::trim "$1")
    Bisu::is_dir "$dirpath" || return 1

    # Use find and awk with while IFS to check if directory is empty
    if ! find "$dirpath" -mindepth 1 -print | while IFS= read -r; do
        return 1
    done; then
        return 0
    fi
}

# Check if a folder is a sub-folder of another folder
Bisu::is_sub_folder_of() {
    local sub_folder=$(Bisu::trim "$1")
    local parent_folder=$(Bisu::trim "$2")

    sub_folder=$(Bisu::normalize_path "$sub_folder" "true")
    parent_folder=$(Bisu::normalize_path "$parent_folder" "true")

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
Bisu::is_top_folder() {
    local dirpath=$(Bisu::trim "$1")
    Bisu::is_dir "$dirpath" || return 1

    dirpath=$(Bisu::normalize_path "$dirpath" "true")
    [ -n "$dirpath" ] || return 1

    local parent_dir=$(dirname "$dirpath")
    [[ "$parent_dir" != "/" ]] || return 1

    return 0
}

# Function: Bisu::file_exists
# Description: According to its naming
Bisu::file_exists() {
    local filepath=$(Bisu::trim "$1")
    if Bisu::is_file "$filepath" || Bisu::is_dir "$filepath"; then
        return 0
    fi
    return 1
}

# Get file's extension
Bisu::fileext() {
    # Ensure the input is a valid filename
    local filename=$(Bisu::trim "$1")

    # Check if the filename is empty
    if [ -z "$filename" ]; then
        printf ''
        return 1
    fi

    # Extract the file extension using POSIX awk
    local ext
    ext=$(printf '%s\n' "$filename" | awk -F. '{if (NF > 1) {print $NF}}' 2>/dev/null)
    ext=$(Bisu::trim "$ext")

    # Output the extension, or an empty string if no extension is found
    if [ -z "$ext" ]; then
        printf ''
    fi

    printf '%s' "$ext"
    return 0
}

# Get file info
Bisu::extract_file_info() {
    local file_path=$(Bisu::trim "$1")
    file_path=$(Bisu::normalize_path "$file_path")
    [ -n "$file_path" ] || return 1

    local receiver_var_name=$(Bisu::trim "$2")
    Bisu::is_valid_var_name "$receiver_var_name" || return 1
    declare -n var_ref="$receiver_var_name"

    local filename=""
    local file_ext=""
    local file_dir=""
    local file_exists="false"
    local file_is_dir="false"
    local file_is_file="false"
    local file_has_ext="false"

    if [ -d "$file_path" ]; then
        file_is_dir="true"
        file_exists="true"
    elif [ -f "$file_path" ]; then
        file_is_file="true"
        file_exists="true"
    fi

    filename=$(basename "$file_path")
    file_dir=$(dirname "$file_path")
    file_ext=$(Bisu::fileext "$file_path")

    if [ -n "$file_ext" ]; then
        file_has_ext="true"
    fi

    local rs=()
    Bisu::array_set "rs" "filename" "$filename"
    Bisu::array_set "rs" "file_ext" "$file_ext"
    Bisu::array_set "rs" "file_path" "$file_path"
    Bisu::array_set "rs" "file_dir" "$file_dir"
    Bisu::array_set "rs" "file_exists" "$file_exists"
    Bisu::array_set "rs" "is_dir" "$file_is_dir"
    Bisu::array_set "rs" "is_file" "$file_is_file"
    Bisu::array_set "rs" "file_has_ext" "$file_has_ext"

    local kv_str=$(Bisu::array_dump "rs")
    Bisu::set "var_ref" "${kv_str[@]}" || return 1
    eval "declare -gA ${receiver_var_name}=($var_ref)" 2>/dev/null || return 1
    return 0
}

# files count
Bisu::files_count() {
    local file_dir=$(Bisu::trim "$1")
    local pattern=$(Bisu::trim "$2")
    local files_count=$(find "$file_dir" -type p -name "*" 2>/dev/null | wc -l)
    files_count=$(Bisu::trim "$files_count")
    Bisu::is_nn_int "$files_count" || files_count=0
    printf '%s' "$files_count"
    return 0
}

# Bisu::mkdir_p
Bisu::mkdir_p() {
    local dir=$(Bisu::trim "$1")
    dir=$(Bisu::normalize_path "$dir")

    # Check if the directory exists, if not, create it
    if ! Bisu::file_exists "$dir"; then
        bash -c "mkdir -p \"$dir\"" &>/dev/null || {
            Bisu::error_log "Failed to mkdir: '${dir}'"
            return 1
        }
        bash -c "chmod -R 755 \"$dir\"" &>/dev/null || {
            Bisu::error_log "Failed to change permissions for '${dir}'"
            return 1
        }
    fi

    return 0
}

# Bisu::cp_p
Bisu::cp_p() {
    local source_path=$(Bisu::trim "$1")
    local target_path=$(Bisu::trim "$2")
    local target_dir=""
    local force_override=$(Bisu::trim "$3")
    Bisu::in_array "${force_override}" "true" "false" || force_override="true"
    local keep_origin=$(Bisu::trim "$4")
    Bisu::in_array "${keep_origin}" "true" "false" || keep_origin="true"
    local source_is_file="false"
    local source_is_dir="false"
    local prepare_for_copy="false"
    local prepare_for_move="false"
    local command=""
    local failure_msg=""

    # Check if the source_path exists
    if ! Bisu::file_exists "$source_path"; then
        Bisu::error_log "Source path '${source_path}' does not exist."
        return 1
    fi

    # Check the source_path's permission
    if [[ ! -e "$source_path" ]]; then
        Bisu::error_log "Permission denied on file: '${source_path}'."
        return 1
    fi

    Bisu::extract_file_info "$target_path" "file_info"
    target_path=$(Bisu::array_get "file_info" "file_path")
    target_dir=$(Bisu::array_get "file_info" "file_dir")

    if [[ "$force_override" == "false" ]] && [ -e "$target_path" ]; then
        return 1
    fi

    if Bisu::is_file "$source_path"; then
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

    Bisu::mkdir_p "$target_dir" || return 1
    bash -c "$command" &>/dev/null || {
        Bisu::error_log "$failure_msg"
        return 1
    }

    return 0
}

# Function: Bisu::move_file
# Description: Moves any file to the specified target path.
# Arguments:
#   $1 - Source to move (source path).
#   $2 - Target path (destination directory).
#   $3 - Force override (optional), if set to "true", will overwrite the target file if it exists.
# Returns: 0 if successful, 1 if failure.
Bisu::move_file() {
    local source_path=$(Bisu::trim "$1")
    local target_path=$(Bisu::trim "$2")
    local target_dir=""
    local force_override=$(Bisu::trim "$3")
    Bisu::in_array "${force_override}" "true" "false" || force_override="true"

    Bisu::cp_p "$source_path" "$target_path" "$force_override" "false" || return 1

    return 0
}

# function to remove a target safely
Bisu::saferm() {
    local path=$(Bisu::trim "$1")
    local parent_dir=$(Bisu::trim "$2")
    parent_dir=${parent_dir:-"$TMPDIR"}
    local timing=$(Bisu::trim "$3")
    timing=${timing:-"immediately"}
    local rm_command=""

    path=$(Bisu::normalize_path "$path" "true")
    parent_dir=$(Bisu::normalize_path "$parent_dir" "true")

    if [ -z "$path" ] || [ -z "$parent_dir" ]; then
        return 1
    fi

    ! Bisu::is_top_folder "$path" || return 1

    if Bisu::is_sub_folder_of "$path" "$parent_dir"; then
        if Bisu::is_file "$path"; then
            rm_command="rm -f"
        elif Bisu::is_empty_dir "$path"; then
            rm_command="rm -r"
        fi
    else
        return 1
    fi
    rm_command="$rm_command \"$path\""

    case "$timing" in
    "immediately")
        Bisu::exec_command "$rm_command" "true" || return 1
        ;;
    "when_quit")
        Bisu::exec_when_quit "$rm_command" || return 1
        ;;
    *)
        return 1
        ;;
    esac

    return 0
}

# Function to check if a variable is an indexed array
Bisu::is_indexed_array() {
    local var=$(Bisu::trim "$1")
    Bisu::is_valid_var_name "$var" || return 1
    local decl
    decl=$(declare -p "$var" 2>/dev/null) || return 1
    case $decl in
    declare\ -a*) return 0 ;;
    *) return 1 ;;
    esac
}

# Function to check if a variable is an assoc array
Bisu::is_assoc_array() {
    local var=$(Bisu::trim "$1")
    Bisu::is_valid_var_name "$var" || return 1
    local decl
    decl=$(declare -p "$var" 2>/dev/null) || return 1
    case $decl in
    declare\ -A*) return 0 ;;
    *) return 1 ;;
    esac
}

# Function to check if a variable is an array
Bisu::is_array() {
    Bisu::is_indexed_array "$1" || Bisu::is_assoc_array "$1" || return 1
    return 0
}

# Function to check if an array is available
Bisu::array_is_available() {
    local array_name=$(Bisu::trim "$1")
    Bisu::is_array "$array_name" || return 1
    declare -n arr_ref="$array_name"
    [ ${#arr_ref[@]} -gt 0 ] || return 1
    return 0
}

# Function to sign an array based on its name
Bisu::sign_array() {
    local array_name=$(Bisu::trim "$1")
    local array_contents
    local array_md5

    # To perform indirect referencing of the array by its name
    Bisu::array_copy "$array_name" "array_contents" || {
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
Bisu::array_count() {
    local array_name=$(Bisu::trim "$1")
    local big_spec=$(Bisu::trim "${2:-false}")
    Bisu::in_array "$big_spec" "true" "false" || big_spec="false"

    Bisu::is_array "$array_name" || {
        printf '%s' "0"
        return 1
    }

    declare -n ref="$array_name" 2>/dev/null || {
        printf '%s' "0"
        return 1
    }

    local array_count=0
    if [[ "$big_spec" == "true" ]]; then
        array_count=$(awk -v n="${#ref[@]}" 'BEGIN { print n }' 2>/dev/null)
    else
        declare -n arr_ref="$array_name"
        array_count=${#arr_ref[@]}
    fi

    Bisu::is_nn_int "$array_count" || array_count=0
    printf '%s' "$array_count"
    return 0
}

# Function to check if a value is in an array
Bisu::in_array() {
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

# Bisu::dump an array's elements into string
Bisu::array_dump() {
    local array_name=$(Bisu::trim "$1")
    if Bisu::is_indexed_array "$array_name"; then
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
            # Replace last space with newline to Bisu::trim trailing space precisely
            if (NR > 0) {
                printf "\n"
            }
        }' 2>/dev/null || {
            printf ''
            return 1
        }
        return 0
    elif Bisu::is_assoc_array "$array_name"; then
        local kv p
        if p="$(declare -p "$array_name" 2>/dev/null)"; then
            # strip everything up to the first '=' to leave the literal payload
            kv="${p#*=}"
            # Some bash builds may wrap the kv in top-level quotes;
            # if so strip *one* matching outer quote char (single or double).
            case "$kv" in
            \'*\') kv="${kv:1:-1}" ;;
            \"*\") kv="${kv:1:-1}" ;;
            esac
        fi
        kv=$(Bisu::trim "$kv" "() ")
        # Print exactly the literal (no extra chars).
        printf '%s\n' "$kv"
        return 0
    fi

    printf ''
    return 1
}

# Function: Bisu::array_copy
# Description: to copy an array internally or globally
Bisu::array_copy() {
    local array_name=$(Bisu::trim "$1")
    declare -n arr_ref="$array_name"
    local new_array_name=$(Bisu::trim "$2")
    declare -n new_arr_ref="$new_array_name"

    if ! Bisu::is_array "$array_name" || ! Bisu::is_valid_var_name "$new_array_name"; then
        return 1
    fi

    # Pass original array name, not nameref variable name, to Bisu::array_dump
    new_arr_ref=($(Bisu::array_dump "$array_name"))
    return 0
}

# Function: Bisu::normalize_array
Bisu::normalize_array() {
    Bisu::array_splice "$1" 0 0 || return 1
    return 0
}

# Function: Bisu::array_splice
# Description: To remove elements from an array
Bisu::array_splice() {
    local array_name=$(Bisu::trim "$1")
    declare -n arr_ref="$array_name"
    local position
    local quantity
    local array_count=$(Bisu::array_count "$array_name")

    Bisu::is_array "$array_name" || return 1
    [ "${#arr_ref[@]}" -gt 0 ] || return 0

    if [ $# -eq 2 ]; then
        quantity=$(Bisu::trim "$2")
        position=0
    else
        position=$(Bisu::trim "$2")
        quantity=$(Bisu::trim "$3")
    fi

    if ! Bisu::is_nn_int "$position" || ! Bisu::is_nn_int "$quantity"; then
        eval "$array_name=()"
        return 1
    fi

    [ "$position" -ge "$array_count" ] && return 0

    ((position + quantity > array_count)) && quantity=$((array_count - position))

    local new_array
    new_array=$(printf '%s\n' "${arr_ref[@]}" |
        awk -v pos="$position" -v qty="$quantity" 'NR < pos + 1 || NR > pos + qty { print }' 2>/dev/null) || {
        return 1
    }

    mapfile -t arr_ref <<<"$new_array" &>/dev/null
    return 0
}

# Set the specified key/value pairs in either indexed or associative arrays
# Usage: Bisu::array_set arr key1 val1 [key2 val2 ...]
# Returns 0 on success, 1 on failure
Bisu::array_set() {
    local array_name key value is_assoc tmp_var tmp_ref ref numeric_indices sorted_idx idx i old_IFS

    # first arg: array name (Bisu::trim provided by caller)
    array_name=$(Bisu::trim "$1")
    shift

    # ensure array exists (helper expected to exist)
    Bisu::is_array "$array_name" || return 1

    # name reference to target array
    declare -n ref="$array_name"

    # detect whether it is already associative (helper expected to exist)
    if Bisu::is_assoc_array "$array_name"; then
        is_assoc=1
    else
        is_assoc=0
    fi

    # Process each key/value pair
    while (($# > 1)); do
        key=$(Bisu::trim "$1")
        value="$2"
        shift 2

        # ignore empty keys
        [[ -z "$key" ]] && continue

        # fast path: already associative
        if ((is_assoc)); then
            ref["$key"]="$value"
            continue
        fi

        # fast path: numeric index -> keep indexed array
        case "$key" in
        '' | *[!0-9]*) ;; # non-numeric -> fall through to migration
        *)
            ref["$key"]="$value"
            continue
            ;;
        esac

        # ---------- migration: indexed -> associative ----------
        # create a unique temporary associative array name (sanitized)
        tmp_var="__array_mig_${array_name//[^a-zA-Z0-9_]/}_${BISU_CURRENT_UTIL_PID}_${RANDOM}"
        declare -gA "$tmp_var"
        declare -n tmp_ref="$tmp_var"

        # copy only existing numeric indices into temporary container
        numeric_indices=()
        for i in "${!ref[@]}"; do
            case "$i" in
            '' | *[!0-9]*) ;; # skip non-numeric keys (defensive)
            *)
                numeric_indices+=("$i")
                tmp_ref["$i"]="${ref[$i]}"
                ;;
            esac
        done

        # destroy original and re-declare as associative
        unset -v "$array_name"
        declare -gA "$array_name"
        declare -n ref="$array_name"

        # restore numeric entries in ascending numeric order (stable)
        if ((${#numeric_indices[@]})); then
            # Use bash builtin mapfile when more than one index to avoid word-splitting issues
            if ((${#numeric_indices[@]} > 1)); then
                old_IFS=$IFS
                IFS=$'\n'
                # sort numerically; use printf + sort (external) only when necessary for ordering
                mapfile -t sorted_idx < <(printf '%s\n' "${numeric_indices[@]}" | sort -n)
                IFS=$old_IFS
            else
                sorted_idx=("${numeric_indices[@]}")
            fi

            for idx in "${sorted_idx[@]}"; do
                ref["$idx"]="${tmp_ref[$idx]}"
            done
            unset sorted_idx
        fi

        # cleanup temporary container
        unset -v tmp_ref
        unset -v "$tmp_var"

        # mark as associative and set requested key
        is_assoc=1
        ref["$key"]="$value"
    done

    return 0
}

# Get an element from a indexed or assoc array, if multiple keys,
# return the first non-empty value found.
# Usage: Bisu::array_get arr key1 [key2 ...]
# Returns: 0 on success (prints value), 1 on failure (prints nothing)
Bisu::array_get() {
    local array_name key val is_assoc idx
    array_name=$(Bisu::trim "$1")
    shift

    # Array must exist
    Bisu::is_array "$array_name" || {
        printf ''
        return 1
    }

    # name reference to target
    declare -n ref="$array_name"

    # detect associative vs indexed (helper expected to exist)
    if Bisu::is_assoc_array "$array_name"; then
        is_assoc=1
    else
        is_assoc=0
    fi

    # iterate keys in order; return first non-empty value
    for key in "$@"; do
        # skip empty keys
        [[ -z "$key" ]] && continue

        val=""

        if ((is_assoc)); then
            # fast direct-existence check for associative arrays
            # -v works for array elements in bash and is fastest builtin check
            [[ -v ref["$key"] ]] || continue
            val="${ref[$key]}"
        else
            # indexed array: accept only non-negative integer indices
            case "$key" in
            '' | *[!0-9]*) continue ;; # non-numeric -> skip
            *) idx=$key ;;
            esac

            # existence check avoids bounds calculation and handles sparse arrays
            [[ -v ref[$idx] ]] || continue
            val="${ref[$idx]}"
        fi

        # Stop at first non-empty value
        if [[ -n "$val" ]]; then
            printf '%s' "$val"
            return 0
        fi
    done

    # nothing found
    printf ''
    return 1
}

# ---------------------------------------
# Bisu::array_keys <array_name> [pattern]
# Returns all keys of the array.
# ---------------------------------------
Bisu::array_keys() {
    local arr_name=$(Bisu::trim "$1")
    local sep="${2:-'\n'}"

    Bisu::array_is_available "$arr_name" || {
        printf ''
        return 1
    }

    eval "local keys=( \${!$arr_name[@]} )" || {
        printf ''
        return 1

    }
    local IFS="$sep"
    echo "(${keys[*]})"
    return 0
}

# --------------------------------------------
# Bisu::array_values <array_name> [pattern]
# Returns all values of the array.
# --------------------------------------------
Bisu::array_values() {
    local arr_name=$(Bisu::trim "$1")
    local sep="${2:-'\n'}"

    # Check if array exists
    Bisu::array_is_available "$arr_name" || {
        printf ''
        return 1
    }

    # Get all values
    eval "local values=( \"\${$arr_name[@]}\" )" || {
        printf ''
        return 1
    }

    local IFS="$sep"
    echo "(${values[*]})"
    return 0
}

# ------------------------------------------------------------
# Bisu::array_search <array_name> <search_value>
# Returns all keys where array value matches search_value.
# ------------------------------------------------------------
Bisu::array_search() {
    local arr_name=$(Bisu::trim "$1")
    local search_value="$2"
    local strict=$(Bisu::trim "$3")
    Bisu::in_array "$strict" "true" "false" || strict="false"

    # Check if array exists
    Bisu::array_is_available "$arr_name" || {
        printf ''
        return 1
    }

    # Get all keys and values once
    local keys values key val
    eval "keys=(\"\${!$arr_name[@]}\")"
    eval "values=(\"\${$arr_name[@]}\")"

    local i=0
    local total="${#keys[@]}"

    while ((i < total)); do
        key="${keys[i]}"
        val="${values[i]}"

        if [[ "$strict" == "true" ]]; then
            # Numeric strict comparison if both are numeric
            if [[ "$val" =~ ^-?[0-9]+([.][0-9]+)?$ ]] && [[ "$search_value" =~ ^-?[0-9]+([.][0-9]+)?$ ]]; then
                ((val + 0 == search_value + 0)) && {
                    echo "$key"
                    return 0
                }
            else
                [[ "$val" == "$search_value" ]] && {
                    echo "$key"
                    return 0
                }
            fi
        else
            # Non-strict string comparison
            [[ "$val" == "$search_value" ]] && {
                echo "$key"
                return 0
            }
        fi

        ((i++))
    done

    printf ''
    return 1
}

# Function to add an element to a specified global array from the bottom
Bisu::array_push() {
    local array_name=$(Bisu::trim "$1")
    local new_value="$2"
    local value_type=$(Bisu::trim "${3:-string}")
    local unique_values=$(Bisu::trim "${4:-false}")
    Bisu::in_array "$unique_values" "true" "false" || unique_values="false"

    # Validate the type parameter and input value
    case "$value_type" in
    int)
        if ! Bisu::is_int "$new_value"; then
            Bisu::error_log "Value must be an integer."
            return 1
        fi
        ;;
    float)
        if ! Bisu::is_numeric "$new_value"; then
            Bisu::error_log "Value must be a float."
            return 1
        fi
        ;;
    string)
        # No specific validation for STRING
        ;;
    *)
        Bisu::error_log "Invalid type specified. Use string, int, or float."
        return 1
        ;;
    esac

    # Ensure the global array exists
    Bisu::is_array "$array_name" || {
        Bisu::error_log "Array $array_name does not exist."
        return 1
    }

    # Access the global array using indirect reference
    Bisu::array_copy "$array_name" "array" || return 1

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
Bisu::array_unique_push() {
    local array_name="$1"
    local new_value="$2"
    local value_type="$3"

    Bisu::array_push "$array_name" "$new_value" "$value_type" "true" || return 1

    return 0
}

# Function to add an element to a specified global array from the top
Bisu::array_unshift() {
    local array_name=$(Bisu::trim "$1")
    local new_value="$2"
    local value_type=$(Bisu::trim "$3")
    value_type=${value_type:-"string"}
    local unique_values=$(Bisu::trim "$4")
    Bisu::in_array "$unique_values" "true" "false" || unique_values="false"

    case "$value_type" in
    int)
        if ! [[ "$new_value" =~ ^-?[0-9]+$ ]]; then
            Bisu::error_log "Value must be an integer."
            return 1
        fi
        ;;
    float)
        if ! [[ "$new_value" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
            Bisu::error_log "Value must be a float."
            return 1
        fi
        ;;
    string) ;;
    *)
        Bisu::error_log "Invalid type specified. Use string, int, or float."
        return 1
        ;;
    esac

    # Ensure the global array exists
    Bisu::is_array "$array_name" || {
        Bisu::error_log "Array $array_name does not exist."
        return 1
    }

    # Access the global array using indirect reference
    Bisu::array_copy "$array_name" "array" || return 1

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
Bisu::array_unique_unshift() {
    local array_name="$1"
    local new_value="$2"
    local value_type="$3"

    Bisu::array_unshift "$array_name" "$new_value" "$value_type" "true" || return 1

    return 0
}

# Function: Bisu::indexed_array_merge
# Description: Function to merge 2 arrays into arg3, according to arg3's array name
Bisu::indexed_array_merge() {
    local src1=$(Bisu::trim "$1")
    local src2=$(Bisu::trim "$2")
    local dest_name=$(Bisu::trim "$3")

    # Validate arguments
    if ! Bisu::is_indexed_array "$src1" || ! Bisu::is_indexed_array "$src2" || ! Bisu::is_valid_var_name "$dest_name"; then
        return 1
    fi

    # Namerefs avoid copies and make in-place updates safe even if dest == src1/src2
    declare -n _am_src1="$src1" _am_src2="$src2" _am_dest="$dest_name"

    # Build unique union while preserving order of first appearance
    local -a _am_merged=()
    declare -A _am_seen=()
    local _am_item
    for _am_item in "${_am_src1[@]}" "${_am_src2[@]}"; do
        if [[ -z ${_am_seen[$_am_item]+x} ]]; then
            _am_merged+=("$_am_item")
            _am_seen["$_am_item"]=1
        fi
    done

    # Final assignment (handles empty correctly: yields dest=() not dest=("")
    _am_dest=("${_am_merged[@]}")

    return 0
}

# Function: Bisu::assoc_array_merge
# Description: Merge 2 associative arrays into arg3 (dest associative array)
Bisu::assoc_array_merge() {
    local src1=$(Bisu::trim "$1")
    local src2=$(Bisu::trim "$2")
    local dest_name=$(Bisu::trim "$3")

    # Validate arguments
    if ! Bisu::is_array "$src1" || ! Bisu::is_array "$src2" || ! Bisu::is_valid_var_name "$dest_name"; then
        return 1
    fi

    # Namerefs avoid copies and make in-place updates safe even if dest == src1/src2
    declare -n _am_src1="$src1" _am_src2="$src2" _am_dest="$dest_name"

    # Build merged associative array
    #   - Preserve keys from src1 first
    #   - Keys from src2 override if duplicated
    #   - Ensures uniqueness by definition of associative arrays
    declare -A _am_merged=()
    local _am_key

    # Copy all from src1
    for _am_key in "${!_am_src1[@]}"; do
        _am_merged["$_am_key"]="${_am_src1[$_am_key]}"
    done

    # Copy/override from src2
    for _am_key in "${!_am_src2[@]}"; do
        _am_merged["$_am_key"]="${_am_src2[$_am_key]}"
    done

    # Final assignment
    _am_dest=()
    for _am_key in "${!_am_merged[@]}"; do
        _am_dest["$_am_key"]="${_am_merged[$_am_key]}"
    done

    return 0
}

# Function: Bisu::array_unique
# Description: To remove duplicates from a global array
Bisu::array_unique() {
    local array_name=$(Bisu::trim "$1")
    Bisu::is_array "$array_name" || return 1

    if [[ $# -eq 1 ]]; then
        return 0
    fi

    eval "${array_name}=(\"\$(printf '%s\n' \"\${${array_name}[@]}\" | awk '!a[\$0]++' 2>/dev/null | tr '\n' ' ')\")" || return 1
    return 0
}

# Function: Bisu::array_shift
# Accepts: $1 array_name, $2 external value reference
# Exits: 0 if success, 1 if failure (empty array)
Bisu::array_shift() {
    local array_name=$(Bisu::trim "$1")
    Bisu::isset "$array_name" || return 1
    # ensure array not empty (uses existing helper array_count)
    local array_count=$(Bisu::array_count "$array_name")
    [ $array_count -gt 0 ] || return 1
    local val_name="$2"

    # create namerefs for array and destination variable
    declare -n arr="$array_name"
    declare -n val_ref="$val_name"

    local first_key
    read -r first_key < <(printf '%s\n' "${!arr[@]}") 2>/dev/null
    [ -n "$first_key" ] || return 1
    Bisu::is_valid_var_name "$val_name" && val_ref="${arr[$first_key]}" 2>/dev/null

    if Bisu::is_assoc_array "$array_name"; then
        unset 'arr[$first_key]'
    else
        arr=("${arr[@]:1}")
    fi

    return 0
}

# Function: Bisu::array_pop
# Accepts: $1 array_name, $2 external value reference
# Exits: 0 if success, 1 if failure (empty array)
Bisu::array_pop() {
    local array_name=$(Bisu::trim "$1")
    Bisu::isset "$array_name" || return 1
    # ensure array not empty (uses existing helper array_count)
    local array_count=$(Bisu::array_count "$array_name")
    [ $array_count -gt 0 ] || return 1
    local val_name="$2"

    # create namerefs for array and destination variable
    declare -n arr="$array_name"
    declare -n val_ref="$val_name"

    local last_key
    last_key=$(printf '%s\n' "${!arr[@]}" | tail -n1 2>/dev/null)
    [ -n "$last_key" ] || return 1
    Bisu::is_valid_var_name "$val_name" && val_ref="${arr[$last_key]}" 2>/dev/null

    if Bisu::is_assoc_array "$array_name"; then
        unset 'arr[$last_key]' 2>/dev/null
    else
        arr=("${arr[@]:0:$last_key}")
    fi

    return 0
}

# Bisu::current() implementing PHP8 current() semantics
# - Supports indexed and associative arrays
# - Outputs only the current element (exact contents); exit 0 on success, 1 on failure
# Usage:
#   Bisu::current array_var_name
Bisu::current() {
    # require one argument (array variable name)
    if [ $# -lt 1 ]; then
        printf ''
        return 1
    fi

    local arr_name=$(trim "$1")
    Bisu::is_valid_var_name "$arr_name" || {
        printf ''
        return 1
    }

    # ensure variable exists and is an array (indexed or associative)
    local decl
    if ! decl="$(declare -p -- "$arr_name" 2>/dev/null)"; then
        printf ''
        return 1
    fi
    case "$decl" in
    declare\ -a* | declare\ -A*) ;; # ok
    *)
        printf ''
        return 1
        ;;
    esac

    # nameref to the array variable for direct access
    local -n _arr_ref="$arr_name"

    # empty array -> failure
    if [ "${#_arr_ref[@]}" -eq 0 ]; then
        printf ''
        return 1
    fi

    # pointer scalar name for this array
    local ptrvar="__ARRAY_PTR_${arr_name}"

    # read current pointer value (if any)
    local curkey="${!ptrvar}"
    # If pointer set and still present in array, use it immediately
    if [ -n "$curkey" ] && [ "${_arr_ref[$curkey]+_}" ]; then
        printf '%s' "${_arr_ref[$curkey]}"
        return 0
    fi

    # pointer missing or stale; initialize to first key encountered
    # iterate keys once, pick first that is not the internal pointer (none present)
    # iteration order: for assoc arrays is insertion order in Bash 5; for indexed arrays
    # it yields the existing indices (sparse arrays supported).
    local k
    for k in "${!_arr_ref[@]}"; do
        # there is no reserved key stored inside the array (we store pointer externally),
        # so the first key encountered is the first element for pointer initialization.
        curkey="$k"
        # persist pointer into scalar safely (handles arbitrary key contents)
        Bisu::set "$ptrvar" "$curkey"
        # output value and return
        printf '%s' "${_arr_ref[$curkey]}"
        return 0
    done

    # if reached here, no usable element found
    printf ''
    return 1
}

# Bisu::key() implementing PHP8 key($array) semantics
# - Supports indexed and associative arrays
# - Outputs only the current element key; exit 0 on success, 1 on failure
# Usage:
#   Bisu::key array_var_name
Bisu::key() {
    # require one argument (array variable name)
    if [ $# -lt 1 ]; then
        printf ''
        return 1
    fi

    local arr_name=$(trim "$1")
    Bisu::is_valid_var_name "$arr_name" || {
        printf ''
        return 1
    }

    # check that variable exists and is array
    local decl
    if ! decl="$(declare -p -- "$arr_name" 2>/dev/null)"; then
        printf ''
        return 1
    fi
    case "$decl" in
    declare\ -a* | declare\ -A*) ;; # valid array
    *)
        printf ''
        return 1
        ;;
    esac

    # nameref to array
    local -n _arr_ref="$arr_name"

    # empty -> failure
    if [ "${#_arr_ref[@]}" -eq 0 ]; then
        printf ''
        return 1
    fi

    # pointer scalar name
    local ptrvar="__ARRAY_PTR_${arr_name}"

    # current pointer value
    local curkey="${!ptrvar}"
    if [ -n "$curkey" ] && [ "${_arr_ref[$curkey]+_}" ]; then
        printf '%s' "$curkey"
        return 0
    fi

    # pointer not set or invalid → init to first key
    local k
    for k in "${!_arr_ref[@]}"; do
        curkey="$k"
        Bisu::set "$ptrvar" "$curkey"
        printf '%s' "$curkey"
        return 0
    done

    printf ''
    return 1
}

# Bisu::prev() implementing PHP8's prev($array) semantics (compatible with the existing pointer scheme)
# - Supports indexed and associative arrays
# - Outputs only the new current element VALUE after moving pointer backwards
# - Exit status: 0 on success (value printed), 1 on failure (moved before first / empty / invalid)
# Behaviour notes (keeps consistency with the previously-established pointer semantics):
# - If pointer is unset, it is treated as "at first element" for movement purposes;
#   prev() will move before-first and return failure (1) in that case.
# - On moving before-first, the pointer scalar is cleared (empty), which will cause
#   the earlier current()/key() implementations (which init pointer when absent) to
#   re-initialize to the first element if called afterwards.
Bisu::prev() {
    # require array variable name
    if [ $# -lt 1 ]; then
        printf ''
        return 1
    fi

    local arr_name=$(trim "$1")
    Bisu::is_valid_var_name "$arr_name" || {
        printf ''
        return 1
    }

    # ensure variable exists and is an array
    local decl
    if ! decl="$(declare -p -- "$arr_name" 2>/dev/null)"; then
        printf ''
        return 1
    fi
    case "$decl" in
    declare\ -a* | declare\ -A*) ;; # ok
    *)
        printf ''
        return 1
        ;;
    esac

    # nameref to array
    local -n _arr_ref="$arr_name"

    # empty array -> failure
    if [ "${#_arr_ref[@]}" -eq 0 ]; then
        printf ''
        return 1
    fi

    # pointer scalar name and current key (may be empty)
    local ptrvar="__ARRAY_PTR_${arr_name}"
    local curkey="${!ptrvar}"

    # collect keys in iteration order into local array 'keys' (single pass)
    local keys=()
    local k
    for k in "${!_arr_ref[@]}"; do
        keys+=("$k")
    done

    # find current position index in keys (if curkey set)
    local idx=-1
    if [ -n "$curkey" ]; then
        local i
        for i in "${!keys[@]}"; do
            if [ "${keys[$i]}" = "$curkey" ]; then
                idx=$i
                break
            fi
        done
        # if curkey was set but no longer present (stale), treat as at-first (so prev -> before-first)
        if [ "$idx" -lt 0 ]; then
            idx=0
        fi
    else
        # pointer unset: treat as if currently at first element for movement purposes
        idx=0
    fi

    # if at or before first element, moving back goes before-first -> clear pointer and return failure
    if [ "$idx" -le 0 ]; then
        # clear pointer scalar to represent "before-first"
        printf -v "$ptrvar" '%s' ''
        printf ''
        return 1
    fi

    # otherwise move to previous element
    local prev_index=$((idx - 1))
    local prevkey="${keys[$prev_index]}"

    # persist pointer and print value
    Bisu::set "$ptrvar" "$prevkey"
    printf '%s' "${_arr_ref[$prevkey]}"
    return 0
}

# Bisu::next() implementing PHP8's next($array) semantics (compatible with existing pointer scheme)
# - Supports indexed and associative arrays
# - Outputs only the new current element VALUE after moving pointer forward
# - Exit status: 0 on success (value printed), 1 on failure (moved past last / empty / invalid)
# Behaviour notes (keeps consistency with previously-established pointer semantics):
# - If pointer is unset, it is treated as "at first element" for movement purposes;
#   next() will move forward from the first element (to second) when possible.
# - If pointer is stale (set but key no longer exists), it is treated as at-first (same as prev()).
# - When moving past the last element, pointer scalar is cleared (set to empty) and failure (1) is returned.
Bisu::next() {
    # require array variable name
    if [ $# -lt 1 ]; then
        printf ''
        return 1
    fi

    local arr_name=$(trim "$1")
    Bisu::is_valid_var_name "$arr_name" || {
        printf ''
        return 1
    }

    # ensure variable exists and is an array
    local decl
    if ! decl="$(declare -p -- "$arr_name" 2>/dev/null)"; then
        printf ''
        return 1
    fi
    case "$decl" in
    declare\ -a* | declare\ -A*) ;; # ok
    *)
        printf ''
        return 1
        ;;
    esac

    # nameref to array
    local -n _arr_ref="$arr_name"

    # empty array -> failure
    if [ "${#_arr_ref[@]}" -eq 0 ]; then
        printf ''
        return 1
    fi

    # pointer scalar name and current key (may be empty)
    local ptrvar="__ARRAY_PTR_${arr_name}"
    local curkey="${!ptrvar}"

    # collect keys in iteration order into local array 'keys' (single pass)
    local keys=()
    local k
    for k in "${!_arr_ref[@]}"; do
        keys+=("$k")
    done

    # find current position index in keys (if curkey set)
    local idx=-1
    if [ -n "$curkey" ]; then
        local i
        for i in "${!keys[@]}"; do
            if [ "${keys[$i]}" = "$curkey" ]; then
                idx=$i
                break
            fi
        done
        # if curkey was set but no longer present (stale), treat as at-first
        if [ "$idx" -lt 0 ]; then
            idx=0
        fi
    else
        # pointer unset: treat as if currently at first element for movement purposes
        idx=0
    fi

    local last_index=$((${#keys[@]} - 1))

    # if currently at or beyond last element, moving forward goes past-last -> clear pointer and return failure
    if [ "$idx" -ge "$last_index" ]; then
        printf -v "$ptrvar" '%s' ''
        printf ''
        return 1
    fi

    # otherwise move to next element
    local next_index=$((idx + 1))
    local nextkey="${keys[$next_index]}"

    # persist pointer and print value
    Bisu::set "$ptrvar" "$nextkey"
    printf '%s' "${_arr_ref[$nextkey]}"
    return 0
}

# Bisu::end() implementing PHP8 end($array) semantics
# - Supports indexed and associative arrays
# - Sets pointer to last element (in insertion order for associative arrays, highest index for indexed arrays)
# - Outputs last element value; exit 0 on success, 1 on failure
Bisu::end() {
    if [ $# -lt 1 ]; then
        printf ''
        return 1
    fi

    local arr_name=$(trim "$1")
    Bisu::is_valid_var_name "$arr_name" || {
        printf ''
        return 1
    }

    # ensure variable exists and is an array
    local decl
    if ! decl="$(declare -p -- "$arr_name" 2>/dev/null)"; then
        printf ''
        return 1
    fi
    case "$decl" in
    declare\ -a* | declare\ -A*) ;; # valid
    *)
        printf ''
        return 1
        ;;
    esac

    # nameref to array
    local -n _arr_ref="$arr_name"

    # empty -> failure
    if [ "${#_arr_ref[@]}" -eq 0 ]; then
        printf ''
        return 1
    fi

    # pointer scalar for this array
    local ptrvar="__ARRAY_PTR_${arr_name}"

    # iterate keys and keep last one
    local k lastkey
    lastkey=""
    for k in "${!_arr_ref[@]}"; do
        lastkey="$k"
    done

    # if no key found, fail
    if [ -z "$lastkey" ]; then
        printf ''
        return 1
    fi

    # update pointer and print value
    Bisu::set "$ptrvar" "$lastkey"
    printf '%s' "${_arr_ref[$lastkey]}"
    return 0
}

# Bisu::reset() implementing PHP8's reset($array) semantics
# - Supports indexed and associative arrays
# - Sets pointer to first element and outputs its VALUE; exit 0 on success, 1 on failure
# Usage:
#   Bisu::reset array_var_name
Bisu::reset() {
    # require array variable name
    if [ $# -lt 1 ]; then
        printf ''
        return 1
    fi

    local arr_name="$1"

    # validate identifier
    if ! [[ $arr_name =~ ^[A-Za-z_][A-Za-z0-9_]*$ ]]; then
        printf ''
        return 1
    fi

    # ensure variable exists and is an array
    local decl
    if ! decl="$(declare -p -- "$arr_name" 2>/dev/null)"; then
        printf ''
        return 1
    fi
    case "$decl" in
    declare\ -a* | declare\ -A*) ;; # valid
    *)
        printf ''
        return 1
        ;;
    esac

    # nameref to array
    local -n _arr_ref="$arr_name"

    # empty -> failure
    if [ "${#_arr_ref[@]}" -eq 0 ]; then
        printf ''
        return 1
    fi

    # pointer scalar
    local ptrvar="__PHP_PTR__${arr_name}"

    # find first element and print its value
    local k firstkey
    for k in "${!_arr_ref[@]}"; do
        firstkey="$k"
        # release pointer after reset
        Bisu::set "$ptrvar" ""
        printf '%s' "${_arr_ref[$firstkey]}"
        return 0
    done

    # fallback: no elements found
    printf ''
    return 1
}

# Convert JSON array to bash array
Bisu::array_to_json() {
    local array_data=$(Bisu::trim "$1")
    local use_private_array=$(Bisu::trim "$2")
    Bisu::in_array "${use_private_array}" "true" "false" || use_private_array="false"
    local array_name=$(Bisu::trim "$3")

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

    if ! Bisu::is_array "$array_name"; then
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
    Bisu::string_ends_with "$result" "}" || {
        printf ''
        return 1
    }

    printf '%s' "$result"
    return 0
}

# Function: Bisu::is_valid_version
# Description: Validates a version number in formats vX.Y.Z, X.Y.Z, X.Y, or X/Y/Z.
# Arguments:
# $1 - Version number to validate.
# Returns: 0 if valid, 1 if invalid.
Bisu::is_valid_version() {
    local version
    version=$(Bisu::trim "$1")

    # Check for valid version formats: optional leading space, optional 'v', followed by numbers and dots
    if ! [[ "$version" =~ ^[[:space:]]*v?[0-9]+(\.[0-9]+)*$ ]]; then
        return 1
    fi

    return 0
}

# Function: Bisu::compare_version
# Purpose: Compares two version strings following Composer versioning rules, supporting complex constraints.
# Usage: Bisu::compare_version <constraint> <version>
# Returns:
#   - 1 if version satisfies the constraint
#   - 0 if version does not satisfy the constraint
Bisu::compare_version() {
    local constraint=$(Bisu::trim "$1")
    local version=$(Bisu::trim "$2")

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

    # --- Inline: compare_raw_versions (first use) ---
    local verA verB cmp_result
    verA="$version"
    verB="$constraint"

    # Define version labels for pre-release versions (associative array)
    declare -A version_labels
    version_labels=(
        [dev]=-3 [alpha]=-2 [a]=-2 [beta]=-1 [b]=-1 [rc]=0 [RC]=0
        [stable]=1 [final]=1 [pl]=2 [p]=2 [snapshot]=3 [milestone]=4 [pre]=0
        [v]=0 [release]=5
    )

    # Normalize version parts (replace '~' with '0.' and remove '^' since they're not part of the actual version)
    verA="${verA//~/0.}"
    verA="${verA//^/}"
    verB="${verB//~/0.}"
    verB="${verB//^/}"

    local IFS_bak="$IFS"
    IFS='.-' read -ra v1parts <<<"$verA"
    IFS='.-' read -ra v2parts <<<"$verB"
    IFS="$IFS_bak"

    local i=0
    cmp_result=
    while [[ $i -lt ${#v1parts[@]} || $i -lt ${#v2parts[@]} ]]; do
        local s1="${v1parts[i]:-}"
        local s2="${v2parts[i]:-}"
        [ -z "$s1" ] && s1=0
        [ -z "$s2" ] && s2=0

        # Numeric comparison of each segment
        if [[ "$s1" =~ ^[0-9]+$ && "$s2" =~ ^[0-9]+$ ]]; then
            if ((10#$s1 > 10#$s2)); then
                cmp_result="1"
                break
            fi
            if ((10#$s1 < 10#$s2)); then
                cmp_result="-1"
                break
            fi
        else
            # Compare pre-release versions (like alpha, beta)
            s1=${version_labels[$s1]:-$s1}
            s2=${version_labels[$s2]:-$s2}

            if [[ "$s1" > "$s2" ]]; then
                cmp_result="1"
                break
            fi
            if [[ "$s1" < "$s2" ]]; then
                cmp_result="-1"
                break
            fi
        fi

        ((i++))
    done
    cmp_result=${cmp_result:-0}
    # --- end inline compare_raw_versions (first use) ---

    # Perform comparison based on operator
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
            # --- Inline: compare_raw_versions (second use) to compute version_check ---
            local verC verD version_check
            verC="$version"
            verD="${constraint%.*}.999999"

            verC="${verC//~/0.}"
            verC="${verC//^/}"
            verD="${verD//~/0.}"
            verD="${verD//^/}"

            IFS_bak="$IFS"
            IFS='.-' read -ra v1parts <<<"$verC"
            IFS='.-' read -ra v2parts <<<"$verD"
            IFS="$IFS_bak"

            i=0
            version_check=
            while [[ $i -lt ${#v1parts[@]} || $i -lt ${#v2parts[@]} ]]; do
                local t1="${v1parts[i]}"
                local t2="${v2parts[i]}"
                [ -z "$t1" ] && t1=0
                [ -z "$t2" ] && t2=0

                if [[ "$t1" =~ ^[0-9]+$ && "$t2" =~ ^[0-9]+$ ]]; then
                    if ((10#$t1 > 10#$t2)); then
                        version_check="1"
                        break
                    fi
                    if ((10#$t1 < 10#$t2)); then
                        version_check="-1"
                        break
                    fi
                else
                    t1=${version_labels[$t1]:-$t1}
                    t2=${version_labels[$t2]:-$t2}
                    if [[ "$t1" > "$t2" ]]; then
                        version_check="1"
                        break
                    fi
                    if [[ "$t1" < "$t2" ]]; then
                        version_check="-1"
                        break
                    fi
                fi

                ((i++))
            done
            version_check=${version_check:-0}
            # --- end inline compare_raw_versions (second use) ---

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
Bisu::bash_version() {
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
        Bisu::error_exit "Bash version format not recognized"
    fi
}

# Function: Bisu::check_bash_version
# Description: Verifies that the installed Bash version is greater than or equal to the specified required version.
Bisu::check_bash_version() {
    if ! Bisu::is_valid_version "$BISU_MINIMAL_BASH_VERSION"; then
        Bisu::error_exit "Illegal version number of required Bash"
    fi

    local expr=">=$BISU_MINIMAL_BASH_VERSION"
    local bash_version=$(Bisu::bash_version)

    local result=$(Bisu::compare_version "$expr" "$bash_version")
    if [[ $result == 0 ]]; then
        Bisu::error_exit "Bash version (${bash_version}) is not compatible with the version requirement (${expr})."
    fi
}

# Function: Bisu::check_bisu_version
# Description: Verifies that the installed BISU version is greater than or equal to the specified required version.
Bisu::check_bisu_version() {
    local expr="${BISU_VERSION_REQUIREMENT:-}"
    local result=$(Bisu::compare_version "$expr" "$BISU_VERSION")
    local current_filename="$(Bisu::current_filename)"
    local bisu_filename="$(Bisu::bisu_filename)"
    if [[ $result == 0 ]] && [[ "$current_filename" != "$bisu_filename" ]]; then
        Bisu::error_exit "BISU version ($BISU_VERSION) is not as the satisfactory ($BISU_VERSION_REQUIREMENT)."
    fi
}

# Check if it's BISU's file or not
Bisu::is_bisu_file() {
    local current_filename=$(Bisu::current_filename)
    local bisu_filename=$(Bisu::bisu_filename)
    [[ "$current_filename" == "$bisu_filename" ]] || return 1
    return 0
}

# Function: Bisu::normalize_iso_datetime
Bisu::normalize_iso_datetime() {
    local input=$(Bisu::trim "$1")
    if [ -z "$input" ]; then
        printf '%s' "INVALID"
        return 1
    fi

    local formatted_time is_utc_time
    if Bisu::string_ends_with "$input" "Z"; then
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

# Function: Bisu::is_valid_datetime
# Description: Check if the given string is a valid adaptive datetime
Bisu::is_valid_datetime() {
    local datetime=$(Bisu::normalize_iso_datetime "$1")

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

# Function: Bisu::gdate
# Description: function for converting ISO8601 time format to natural language format
Bisu::gdate() {
    local raw fmt compact input datepart timepart tzpart timecore
    local Y M D h m s
    local len sep rem hh mm ss frac signpos
    local days era yoe doy doe days_since_epoch ts weekday
    local out token

    # get normalized input; return failure on empty
    input=$(Bisu::normalize_iso_datetime "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    fmt=$(Bisu::trim "$2")
    fmt="${fmt:-+%a %b %-e %H:%M:%S %Z %Y}"
    compact=$(Bisu::trim "$3")
    Bisu::in_array "$compact" "true" "false" || compact="true"

    # remove leading '+' like date(1) style
    [[ "${fmt}" == +* ]] && fmt="${fmt:1}"

    # Split date and time on first 'T' or space
    datepart=${input%%[T ]*}
    rem=${input#"$datepart"}
    if [[ "$rem" == "$input" ]]; then
        # no separator, only date
        timepart=''
    else
        # rem begins with separator char
        timepart=${rem#?}
    fi

    # strip timezone suffix from timepart (Z or +hh[:mm] or -hh[:mm])
    if [[ -z "$timepart" ]]; then
        timecore=''
    else
        # find position of 'Z' or '+' or '-' in timepart (if any)
        signpos=''
        # search for Z
        if [[ "$timepart" == *Z ]]; then
            timecore="${timepart%Z}"
        else
            # find first + or - (timezone), but avoid a leading hyphen if time missing - not expected
            if [[ "$timepart" =~ [+\-] ]]; then
                # remove timezone part starting at first + or -
                local tmp="${timepart%%[+-]*}"
                timecore="$tmp"
            else
                timecore="$timepart"
            fi
        fi
    fi

    # extract date components (YYYY-MM-DD)
    # basic validation and extraction using substring positions
    if [[ ${#datepart} -lt 10 ]]; then
        printf ''
        return 1
    fi
    Y=${datepart:0:4}
    M=${datepart:5:2}
    D=${datepart:8:2}
    # ensure numeric (basic)
    [[ "$Y" =~ ^[0-9]{4}$ && "$M" =~ ^[0-9]{2}$ && "$D" =~ ^[0-9]{2}$ ]] || {
        printf ''
        return 1
    }

    # parse timecore into hh:mm:ss (may be empty)
    if [[ -z "$timecore" ]]; then
        h=0
        m=0
        s=0
    else
        # Split by ':' using IFS read (safe)
        IFS=':' read -r hh mm ss <<<"$timecore"
        hh=${hh:-00}
        mm=${mm:-00}
        ss=${ss:-00}
        # strip fractional seconds if present (e.g., 12:34:56.789)
        if [[ "$ss" == *.* ]]; then
            frac="${ss#*.}"
            ss="${ss%%.*}"
        fi
        # defensive numeric defaults
        [[ "$hh" =~ ^[0-9]+$ ]] || hh=0
        [[ "$mm" =~ ^[0-9]+$ ]] || mm=0
        [[ "$ss" =~ ^[0-9]+$ ]] || ss=0
        h=$((10#$hh))
        m=$((10#$mm))
        s=$((10#$ss))
    fi

    # If compact and time is all zero, remember flag to remove time later
    local time_all_zero=0
    if [[ "$compact" == "true" && "$h" -eq 0 && "$m" -eq 0 && "$s" -eq 0 ]]; then
        time_all_zero=1
    fi

    # Convert Y M D to integer days since epoch (1970-01-01 -> 0)
    # Algorithm: Howard Hinnant's civil_from_days/days_from_civil (integer math)
    # Note: handle as signed integers; values well within 64-bit for common dates.
    local yi mi di y0 era_val yoe_val m_adj doy_val doe_val era_mul
    yi=$((10#$Y))
    mi=$((10#$M))
    di=$((10#$D))

    # adjust year for Jan/Feb
    if ((mi <= 2)); then
        y0=$((yi - 1))
        m_adj=$((mi + 12))
    else
        y0=$((yi))
        m_adj=$((mi))
    fi

    # era = Bisu::floor(y0 / 400)
    # bash division truncates toward zero; for positive years this is Bisu::floor
    era_val=$((y0 / 400))
    yoe_val=$((y0 - era_val * 400))
    # doy: day of year for March-based year
    # (153*(m_adj-3)+2)/5 + (d-1)
    doy_val=$(((153 * (m_adj - 3) + 2) / 5 + (di - 1)))
    doe_val=$((yoe_val * 365 + yoe_val / 4 - yoe_val / 100 + doy_val))
    days_since_epoch=$((era_val * 146097 + doe_val - 719468))

    # compute unix timestamp in UTC (seconds)
    ts=$((days_since_epoch * 86400 + h * 3600 + m * 60 + s))

    # compute weekday: 0=Sun ... 6=Sat (1970-01-01 was Thursday)
    weekday=$(((days_since_epoch + 4) % 7))
    ((weekday < 0)) && weekday=$((weekday + 7))

    # Prepare textual replacements
    local months_abbr months_full weekdays_abbr weekdays_full
    months_abbr=(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec)
    months_full=(January February March April May June July August September October November December)
    weekdays_abbr=(Sun Mon Tue Wed Thu Fri Sat)
    weekdays_full=(Sunday Monday Tuesday Wednesday Thursday Friday Saturday)

    local mon_idx mon_name mon_name_full w_abbr w_full
    mon_idx=$((10#$M - 1))
    mon_name=${months_abbr[mon_idx]:-Unknown}
    mon_name_full=${months_full[mon_idx]:-Unknown}
    w_abbr=${weekdays_abbr[weekday]:-Day}
    w_full=${weekdays_full[weekday]:-Day}

    # numeric padded values via printf builtin
    local Y4 Y2 MM DD HH II MN SS
    Y4=$(printf "%04d" "$yi")
    Y2=$(printf "%02d" $((yi % 100)))
    MM=$(printf "%02d" "$mi")
    DD=$(printf "%02d" "$di")
    # day space padded and non-padded
    day_space=$(printf "%2d" "$di")
    day_nopad=$(printf "%d" "$di")
    HH=$(printf "%02d" "$h")
    II_raw=$((h % 12))
    ((II_raw == 0)) && II_raw=12
    II=$(printf "%02d" "$II_raw")
    MN=$(printf "%02d" "$m")
    SS=$(printf "%02d" "$s")
    AMPM=$((h >= 12 ? 1 : 0))
    AMPM_STR=$([ $AMPM -eq 1 ] && printf 'PM' || printf 'AM')

    # Start replacing tokens in format string (longest tokens first)
    out="$fmt"

    # protect literal %%
    out="${out//%%/__PCT__PLACEHOLDER__}"

    # Replace %-e (no-pad day) before %e
    out="${out//%-e/$day_nopad}"
    # %e -> space-padded day
    out="${out//%e/$day_space}"

    # Year, month, day
    out="${out//%Y/$Y4}"
    out="${out//%y/$Y2}"
    out="${out//%m/$MM}"
    out="${out//%d/$DD}"

    # Month names
    out="${out//%b/$mon_name}"
    out="${out//%B/$mon_name_full}"

    # Weekday names
    out="${out//%a/$w_abbr}"
    out="${out//%A/$w_full}"

    # Time
    out="${out//%H/$HH}"
    out="${out//%I/$II}"
    out="${out//%M/$MN}"
    out="${out//%S/$SS}"
    out="${out//%p/$AMPM_STR}"

    # Timezone: this implementation uses UTC (consistent with previous date -u behavior)
    out="${out//%Z/UTC}"

    # restore literal percent
    out="${out//__PCT__PLACEHOLDER__/%%}"

    # If compact mode and midnight, remove exact "00:00:00" occurrences and collapse spaces
    if [[ "$compact" == "true" && "$time_all_zero" -eq 1 ]]; then
        out="${out//00:00:00/}"
        # remove stray colons leftover like trailing " :" or "::" don't expect in normal formats, but collapse multiple spaces
        while [[ "$out" == *"  "* ]]; do out="${out//  / }"; done
        # Bisu::trim leading/trailing spaces
        out="${out#"${out%%[![:space:]]*}"}"
        out="${out%"${out##*[![:space:]]}"}"
    fi

    printf '%s\n' "$out"
    return 0
}

# Function to check if a filename is valid
Bisu::is_valid_filename() {
    local filename=$(Bisu::trim "$1")
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
Bisu::get_os_info() {
    local os_info="$BISU_OS_INFO"
    [ -n "$os_info" ] && {
        printf '%s' "$os_info"
        return 0
    }

    local uname_s uname_o kernel_str uname_s_lc os_name='' os_version=''

    uname_s=$(command uname -s 2>/dev/null || :) || return 1
    uname_o=$(command uname -o 2>/dev/null || :) || :
    uname_s_lc=$(Bisu::strtolower "$uname_s" || :) || return 1
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
    BISU_OS_INFO="$os_info"
    printf '%s' "$os_info"
    return 0
}

# Bisu::get_os_name
Bisu::get_os_name() {
    local os_info=$(Bisu::get_os_info)
    Bisu::string_to_array "$os_info" "os_info"
    local os_name=$(Bisu::array_get "os_info" 0)
    printf '%s' "$os_name"
}

# Bisu::get_os_version
Bisu::get_os_version() {
    local os_info=$(Bisu::get_os_info)
    Bisu::string_to_array "$os_info" "os_info"
    local os_version=$(Bisu::array_get "os_info" 1)
    printf '%s' "$os_version"
}

# Returns kernel info in format: {name} v{major.minor.patch}
Bisu::get_kernel_info() {
    local kernel_info="$BISU_KERNEL_INFO"
    [ -n "$kernel_info" ] && {
        printf '%s' "$kernel_info"
        return 0
    }

    local kernname kernversion version_str

    kernname=$(uname -s 2>/dev/null || printf '')
    kernversion=$(uname -r 2>/dev/null || printf '')
    kernname=$(Bisu::strtolower "$kernname")

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
    BISU_KERNEL_INFO="$kernel_info"
    printf '%s' "$kernel_info"
    return 0
}

# Bisu::get_os_name
Bisu::get_kernel_name() {
    local kernel_info=$(Bisu::get_kernel_info)
    Bisu::string_to_array "$kernel_info" "kernel_info"
    local kernel_name=$(Bisu::array_get "kernel_info" 0)
    printf '%s' "$kernel_name"
}

# Bisu::get_os_version
Bisu::get_kernel_version() {
    local kernel_info=$(Bisu::get_kernel_info)
    Bisu::string_to_array "$kernel_info" "kernel_info"
    local kernel_version=$(Bisu::array_get "kernel_info" 1)
    printf '%s' "$kernel_version"
}

# ipv4 validator
Bisu::is_valid_ipv4() {
    local ip=$(Bisu::trim "$1")
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
Bisu::is_valid_ipv6() {
    local ip=$(Bisu::trim "$1")
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
        [ "$count" -gt 9 ] && return 1
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
Bisu::is_valid_ip() {
    ! Bisu::is_valid_ipv4 && ! Bisu::is_valid_ipv6 || return 1
    return 0
}

# Universal function to validate port number
Bisu::is_valid_port() {
    local port=$(Bisu::trim "$1")

    # Validate the port range: Must be a number between 0 and 65535
    if [[ ! "$port" =~ ^[0-9]+$ ]] || [[ "$port" -lt 0 || "$port" -gt 65535 ]]; then
        return 1
    fi

    return 0
}

# Domain name validator
Bisu::is_valid_domain() {
    local url=$(Bisu::trim "$1")
    local remaining_url="${url#*://}"
    local domain="${remaining_url%%/*}"

    if [[ ! "$domain" =~ ^([a-zA-Z0-9-.])+(\.[a-zA-Z]{2,16})$ ]] || [[ "$domain" =~ -- || "$domain" =~ ^[-.] ||
        "$domain" =~ [-.]$ || "$domain" =~ \.\. ]]; then
        return 1
    fi

    return 0
}

# Email address validator
Bisu::is_valid_email() {
    local email=$(Bisu::trim "$1")
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

# Function: Bisu::is_valid_url
# Validates a URL of the form: scheme://[userinfo@]host[:port][/path][?query][#fragment]
# Returns 0 when valid, 1 when invalid.
Bisu::is_valid_url() {
    local url=$(Bisu::trim "$1")

    # Trim leading/trailing whitespace
    url="${url#"${url%%[![:space:]]*}"}"
    url="${url%"${url##*[![:space:]]}"}"

    # Empty string -> invalid
    [[ -z "$url" ]] && return 1

    # 1) Scheme (e.g. http, https, ftp) - must be present and followed by "://"
    if [[ "$url" =~ ^([A-Za-z][A-Za-z0-9+.-]*):// ]]; then
        local scheme="${BASH_REMATCH[1]}"
    else
        return 1
    fi

    # 2) Split rest into authority (userinfo@host:port) and the path+query+fragment
    local rest="${url#*://}" # remove scheme:// (first occurrence)
    local authority path_and_more
    authority="${rest%%/*}" # up to first slash (or whole string if no slash)
    if [[ "$rest" == "$authority" ]]; then
        path_and_more=""
    else
        path_and_more="${rest#"$authority"}" # starts with "/" when present, or empty
    fi

    # 3) Remove optional userinfo (take text after last '@' if present)
    local hostport
    if [[ "$authority" == *@* ]]; then
        hostport="${authority##*@}"
    else
        hostport="$authority"
    fi

    # 4) Extract host (IPv6 bracketed OR hostname/IPv4) and optional port
    local host port is_ipv6=0
    if [[ "$hostport" == \[* ]]; then
        # bracketed IPv6 expected: [IPv6] or [IPv6]:port
        # first match bracketed portion and the rest (no spaces allowed)
        if [[ "$hostport" =~ ^(\[[0-9A-Fa-f:.%]+\])([^[:space:]]*)$ ]]; then
            host="${BASH_REMATCH[1]}" # includes brackets
            local rest_after="${BASH_REMATCH[2]}"
            if [[ -z "$rest_after" ]]; then
                port=""
            elif [[ "$rest_after" =~ ^:([0-9]{1,5})$ ]]; then
                port="${BASH_REMATCH[1]}"
            else
                return 1
            fi
            is_ipv6=1
        else
            return 1
        fi
    else
        # non-bracketed authority: host[:port]
        # ensure not an unbracketed IPv6 (multiple colons would indicate that)
        local colons="${hostport//[^:]/}"
        if ((${#colons} > 1)); then
            return 1
        fi
        if [[ "$hostport" == *:* ]]; then
            host="${hostport%%:*}"
            port="${hostport#*:}"
        else
            host="$hostport"
            port=""
        fi
    fi

    # Host must be non-empty
    [[ -z "$host" ]] && return 1

    # 5) Host validation
    if ((is_ipv6)); then
        # bracketed IPv6: minimal character validation already performed (hex, colons, dots, percent)
        # (full RFC IPv6 validation is complex; this accepts typical bracketed IPv6 forms)
        :
    elif [[ "$host" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        # IPv4 -> check each octet is 0-255
        IFS='.' read -r o1 o2 o3 o4 <<<"$host"
        for o in "$o1" "$o2" "$o3" "$o4"; do
            # numeric check
            if ! [[ "$o" =~ ^[0-9]+$ ]]; then
                return 1
            fi
            if ((o < 0 || o > 255)); then
                return 1
            fi
        done
    else
        # Domain name validation: ASCII labels, at least one dot, TLD 2-63 alpha chars.
        # (This enforces a conventional public-domain form; adjust if you wish to accept single-label hosts)
        if ! [[ "$host" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,63}$ ]]; then
            return 1
        fi
    fi

    # 6) Port validation (if present): numeric and within 0-65535
    if [[ -n "$port" ]]; then
        if ! [[ "$port" =~ ^[0-9]{1,5}$ ]]; then
            return 1
        fi
        if ((port < 0 || port > 65535)); then
            return 1
        fi
    fi

    # 7) Path/query/fragment must not contain whitespace characters
    if [[ "$path_and_more" =~ [[:space:]] ]]; then
        return 1
    fi

    # All checks passed
    return 0
}

# Function: Bisu::is_valid_uri
# Validates a generic URI: [scheme:][//authority][path][?query][#fragment]
# Returns 0 if valid, 1 if invalid.
Bisu::is_valid_uri() {
    local uri=$(Bisu::trim "$1")

    # Trim leading/trailing whitespace
    uri="${uri#"${uri%%[![:space:]]*}"}"
    uri="${uri%"${uri##*[![:space:]]}"}"

    [[ -z "$uri" ]] && return 1

    local scheme authority path_and_more hostport host port is_ipv6=0

    # 1) Extract scheme if present
    if [[ "$uri" =~ ^([A-Za-z][A-Za-z0-9+.-]*):(.*)$ ]]; then
        scheme="${BASH_REMATCH[1]}"
        uri="${BASH_REMATCH[2]}"
    fi

    # 2) If starts with "//", then authority is present
    if [[ "$uri" == //* ]]; then
        local tmp="${uri#//}"      # strip leading //
        authority="${tmp%%[/?#]*}" # until '/', '?', or '#' or end
        uri="${tmp#"$authority"}"  # rest after authority
    else
        authority=""
    fi

    # 3) Path/query/fragment (anything left)
    path_and_more="$uri"

    # 4) Parse authority into host and port (ignore userinfo by dropping up to last '@')
    if [[ -n "$authority" ]]; then
        if [[ "$authority" == *@* ]]; then
            hostport="${authority##*@}"
        else
            hostport="$authority"
        fi

        if [[ "$hostport" == \[* ]]; then
            # bracketed IPv6
            if [[ "$hostport" =~ ^(\[[0-9A-Fa-f:.%]+\])(:(.*))?$ ]]; then
                host="${BASH_REMATCH[1]}"
                port="${BASH_REMATCH[3]}"
                is_ipv6=1
            else
                return 1
            fi
        else
            # non-bracketed
            local colons="${hostport//[^:]/}"
            if ((${#colons} > 1)); then
                return 1 # reject unbracketed IPv6
            fi
            if [[ "$hostport" == *:* ]]; then
                host="${hostport%%:*}"
                port="${hostport#*:}"
            else
                host="$hostport"
                port=""
            fi
        fi
    fi

    # 5) Validate host (if authority present)
    if [[ -n "$authority" ]]; then
        [[ -z "$host" ]] && return 1

        if ((is_ipv6)); then
            # Already roughly validated; deeper RFC check omitted for simplicity
            :
        elif [[ "$host" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
            # IPv4 validation
            IFS='.' read -r o1 o2 o3 o4 <<<"$host"
            for o in "$o1" "$o2" "$o3" "$o4"; do
                if ! [[ "$o" =~ ^[0-9]+$ ]] || ((o < 0 || o > 255)); then
                    return 1
                fi
            done
        else
            # Domain validation: must have dot + TLD
            if ! [[ "$host" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)*\.[A-Za-z]{2,63}$ ]]; then
                return 1
            fi
        fi
    fi

    # 6) Validate port
    if [[ -n "$port" ]]; then
        if ! [[ "$port" =~ ^[0-9]{1,5}$ ]] || ((port < 0 || port > 65535)); then
            return 1
        fi
    fi

    # 7) Ensure no spaces in path/query/fragment
    if [[ "$path_and_more" =~ [[:space:]] ]]; then
        return 1
    fi

    return 0
}

# Json validator
Bisu::is_valid_json() {
    local input=$(Bisu::trim "$1")

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

#------------------------------------------------------------------------------
# Function: Bisu::gen_sig_file
# Purpose : Generate a SHA-256 checksum for a file and sign it with GPG,
#           producing an ASCII-armored signature file (.sha256.asc).
# Supports algorithms: md5, sha1, ripemd160, sha256, sha384, sha512, sha224.
#------------------------------------------------------------------------------
Bisu::gen_sig_file() {
    local target_file=$(Bisu::trim "$1")
    local algorithm=$(Bisu::trim "$2")
    algorithm="${algorithm:-"$BISU_CURRENT_UTIL_GPG_SIG_ALGO"}"
    algorithm=$(Bisu::strtolower "$algorithm")
    local sig_file=$(Bisu::trim "$3")

    if ! Bisu::in_array "$algorithm" "md5" "sha1" "ripemd160" "sha256" "sha384" "sha512" "sha224"; then
        Bisu::error_exit "Unsupported signature algorithm of '${algorithm}'"
    fi

    if [ -z "$target_file" ]; then
        target_file=$(Bisu::current_file_path)
    fi

    if ! Bisu::is_file "$target_file"; then
        Bisu::error_exit "Target file does not exist"
    fi

    if [ -z "$sig_file" ]; then
        if [[ "$target_file" != "$(Bisu::current_file_path)" ]]; then
            sig_file="${target_file}.asc"
        else
            sig_file="./$(Bisu::current_filename).asc"
        fi
    fi

    # Ensure key exists before signing
    if ! (
        gpg --list-secret-keys --with-colons | grep -q '^sec:' ||
            gpg --batch --generate-key <(
                cat <<EOF
        %no-protection
        Key-Type: default
        Key-Length: 2048
        Subkey-Type: default
        Name-Real: Auto Generated
        Name-Email: auto@example.com
        Expire-Date: 0
EOF
            ) 2>/dev/null
    ); then
        Bisu::error_exit "No GPG private keys found, please generate a GPG key for your machine."
    fi

    # Perform signing
    if ! (gpg --batch --yes --armor --digest-algo "$algorithm" --detach-sign --output "$sig_file" "$target_file" 2>/dev/null); then
        printf ''
        return 1
    fi

    if ! Bisu::is_file "$sig_file"; then
        printf ''
        return 1
    fi

    printf '%s' "$sig_file"
    return 0
}

# Bisu::verify_sig_file: Verify a GPG signature with maximum robustness
# Args:
#   $1 - signature file path
#   $2 - source file path (optional, Bisu::current_file_path() used if omitted)
# Output:
#   If technical errors prints "failed";
#   If detected hash algorithm prints {algo_name}, else "unknown";
# Returns:
#   0 = signature valid, 1 = invalid or error
Bisu::verify_sig_file() {
    local sig_file=$(Bisu::trim "$1")
    local src_file=$(Bisu::trim "$2")

    Bisu::is_file "$sig_file" || {
        printf "err_noperm"
        return 1
    }

    [ -n "$src_file" ] || src_file="$(Bisu::current_file_path)"

    Bisu::is_file "$src_file" || {
        printf "err_noperm"
        return 1
    }

    local status_code hash_id result return_code
    # Extract status status_code and optional hash_id in one awk pass
    read -r status_code hash_id <<<"$(
        gpg --status-fd=1 --verify "$sig_file" "$src_file" 2>&1 |
            awk '
            /^\[GNUPG:\] VALIDSIG/ { print "VALIDSIG", $(NF-2); next }
            /^\[GNUPG:\] BADSIG/   { print "BADSIG";   exit }
            /^\[GNUPG:\] NO_PUBKEY/{ print "NOPUB";    exit }
            /^\[GNUPG:\] ERRSIG/   { print "ERRSIG";   exit }
            /^\[GNUPG:\] NODATA/   { print "NODATA";   exit }
            END { if (!NR) print "UNKNOWN" }
        ' 2>/dev/null
    )"

    # Classify based on extracted status_code
    case "$status_code" in
    VALIDSIG)
        case "$hash_id" in
        1) result="sig_md5" ;;
        2) result="sig_sha1" ;;
        3) result="sig_ripemd160" ;;
        8) result="sig_sha256" ;;
        9) result="sig_sha384" ;;
        10) result="sig_sha512" ;;
        11) result="sig_sha224" ;;
        *) result="sig_unknown" ;;
        esac
        return_code=0
        ;;
    BADSIG)
        result="err_badsig"
        return_code=1
        ;;
    NOPUB)
        result="err_nopub"
        return_code=1
        ;;
    ERRSIG)
        result="err_errsig"
        return_code=1
        ;;
    NODATA)
        result="err_nodata"
        return_code=1
        ;;
    *)
        result="err_unknown"
        return_code=1
        ;;
    esac

    result=$(Bisu::strtoupper "$result")
    printf '%s' "$result"
    return $return_code
}

# Function to convert YAML to JSON
Bisu::yaml_to_json() {
    local yaml=$(Bisu::trim "$1")

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
Bisu::yaml_to_array() {
    local input key value
    # If no argument is passed, read from stdin, otherwise handle the passed argument
    if [ $# -eq 0 ]; then
        input=$(cat)
    else
        input=$(Bisu::trim "$1")
    fi

    local receiver_var_name=$(Bisu::trim "$2")
    Bisu::is_valid_var_name "$receiver_var_name" || return 1
    declare -n var_ref="$receiver_var_name"

    local rs=()
    # Read the input line by line
    while IFS=':' read -r key value; do
        # Trim spaces and remove quotes from key and value using POSIX awk
        key=$(printf '%s\n' "$key" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); gsub(/"/, ""); gsub(/'\''/, ""); print}' 2>/dev/null)
        value=$(printf '%s\n' "$value" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); gsub(/"/, ""); gsub(/'\''/, ""); print}' 2>/dev/null)

        # Skip if the key is empty (or invalid)
        [ -z "$key" ] && continue

        # Set the key-value pair
        Bisu::array_set "rs" "$key" "$value" || return 1
    done <<<"$input" || return 1

    local kv_str=$(Bisu::array_dump "rs")
    Bisu::set "var_ref" "${kv_str[@]}" || return 1
    eval "declare -gA ${receiver_var_name}=($var_ref)" 2>/dev/null || return 1
    return 0
}

# Parse JSON into array
Bisu::json_to_array() {
    local input key value
    # If no argument is passed, read from stdin, otherwise handle the passed argument
    if [ $# -eq 0 ]; then
        input=$(cat)
    else
        input=$(Bisu::trim "$1")
    fi

    local receiver_var_name=$(Bisu::trim "$2")
    Bisu::is_valid_var_name "$receiver_var_name" || return 1
    declare -n var_ref="$receiver_var_name"

    local rs=()
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
            Bisu::array_set "rs" "$key" "$value" || return 1
        fi
    done <<<"$input" || return 1

    local kv_str=$(Bisu::array_dump "rs")
    Bisu::set "var_ref" "${kv_str[@]}" || return 1
    eval "declare -gA ${receiver_var_name}=($var_ref)" 2>/dev/null || return 1
    return 0
}

# Check if a string contains URL-encoded sequences (%XX)
#   strict=true  -> the string must be fully URL-encoded
#   strict=false -> return true if at least one valid %XX exists
# Returns:
#   0 -> matches mode requirements
#   1 -> does not match mode requirements or empty string
Bisu::url_is_encoded() {
    local segment i len c hex strict mode valid_found=false
    segment=$(Bisu::trim "$1")
    mode=$(Bisu::trim "$2")
    mode=${mode:-"true"} # default strict mode is true

    # Handle empty input safely
    [ -n "$segment" ] || {
        return 1
    }

    len=${#segment}
    i=0

    while ((i < len)); do
        c=${segment:i:1}
        if [[ $c == "%" ]]; then
            # Check that there are exactly two characters following '%'
            if ((i + 2 >= len)); then
                if [[ $mode == "true" ]]; then
                    return 1 # invalid: incomplete % sequence in strict mode
                else
                    ((i++))
                    continue
                fi
            fi

            hex=${segment:i+1:2}

            # Validate that the two characters are hex digits
            if [[ $hex =~ ^[0-9A-Fa-f]{2}$ ]]; then
                valid_found="true"
            else
                if [[ $mode == "true" ]]; then
                    return 1 # invalid %XX in strict mode
                fi
            fi

            i=$((i + 3)) # skip over the %XX
        else
            ((i++))
        fi
    done

    if [[ $mode == false && $valid_found == "true" ]]; then
        return 0 # at least one valid %XX found
    elif [[ $mode == false ]]; then
        return 1 # no valid %XX found
    fi

    return 0 # strict mode success
}

# URL-encode a string safely using only POSIX/Bash 5 utilities
# Usage: Bisu::urlencode "string"
Bisu::urlencode() {
    local str=$(Bisu::trim "$1")
    [ -n "$str" ] || {
        printf ''
        return 1
    }

    local i c hex output=""
    local ord

    # Iterate over each character in the string
    for ((i = 0; i < ${#str}; i++)); do
        c=${str:i:1}

        # Detect non-ASCII characters safely using byte values
        ord=$(printf '%d' "'$c") # Get ASCII/byte value of the character
        if ((ord < 32 || ord > 126)); then
            # Multi-byte UTF-8 handling
            local utf8_bytes
            utf8_bytes=$(printf '%s' "$c" | od -An -tx1 | tr -d ' \n')
            for ((j = 0; j < ${#utf8_bytes}; j += 2)); do
                hex=${utf8_bytes:j:2}
                output+="%${hex^^}"
            done
            continue
        fi

        # Unreserved characters remain as-is
        case "$c" in
        [A-Za-z0-9.~_-]) output+="$c" ;;
        # Percent encode everything else
        *)
            ord=$(printf '%d' "'$c")
            output+=$(printf '%%%02X' "$ord")
            ;;
        esac
    done

    printf '%s' "$output"
    return 0
}

# URL-decode a string using only POSIX/Bash utilities
# Usage: Bisu::urldecode "string"
Bisu::urldecode() {
    local str
    str=$(Bisu::trim "$1")

    # Return empty string for empty input
    [ -n "$str" ] || {
        printf ''
        return 1
    }

    local i c hex output=""
    i=0
    while ((i < ${#str})); do
        c=${str:i:1}

        if [[ $c == "%" ]]; then
            # Ensure there are two characters after '%'
            if ((i + 2 >= ${#str})); then
                printf ''
                return 1 # Invalid encoding
            fi

            hex=${str:i+1:2}

            # Validate hex digits
            if [[ ! $hex =~ ^[0-9A-Fa-f]{2}$ ]]; then
                printf ''
                return 1 # Invalid encoding
            fi

            # Convert hex to character
            output+=$(printf '\\x%s' "$hex")
            i=$((i + 3)) # Skip '%XX'
        else
            output+="$c"
            i=$((i + 1))
        fi
    done

    # Safely print the decoded string
    printf '%b' "$output"
    return 0
}

# Normalize a URL and analyze its components
Bisu::extract_url_info() {
    local url scheme domain path remaining_url normalized_url
    local url_is_encoded unencoded_url unencoded_req_path encoded_url encoded_req_path

    url=$(Bisu::trim "$1")
    [ -n "$url" ] || return 1

    local receiver_var_name=$(Bisu::trim "$2")
    Bisu::is_valid_var_name "$receiver_var_name" || return 1
    declare -n var_ref="$receiver_var_name"

    # Step 1: Extract scheme if present
    if [[ "$url" =~ ^([a-zA-Z][a-zA-Z0-9+.-]*):\/\/(.*)$ ]]; then
        scheme="${BASH_REMATCH[1]}"
        remaining_url="${BASH_REMATCH[2]}"
    else
        scheme="http"
        remaining_url="$url"
    fi

    # Step 2: Validate scheme (only allow http, https, ftp)
    if [[ ! "$scheme" =~ ^(http|https|ftp)$ ]]; then
        return 1
    fi

    # Step 3: Extract domain and path
    if [[ "$remaining_url" =~ ^([^/]+)(/.*)?$ ]]; then
        domain="${BASH_REMATCH[1]}"
        path="${BASH_REMATCH[2]:-/}" # default to '/' if empty
    else
        return 1
    fi

    # Step 4: Validate domain (basic alphanumeric, dots, hyphens)
    if [[ ! "$domain" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        return 1
    fi

    # Step 5: Normalize path
    # Ensure leading slash
    [[ "$path" != /* ]] && path="/$path"
    # Keep only the first '?' if multiple exist
    if [[ "$path" =~ ^([^?]*)\?.* ]]; then
        path="${BASH_REMATCH[1]}?${path#*?}"
    fi

    normalized_url="$scheme://$domain$path"

    # Step 6: Determine encoding status
    if Bisu::url_is_encoded "$path"; then
        url_is_encoded="true"
        encoded_req_path="$path"
        encoded_url="$normalized_url"
        unencoded_req_path=$(Bisu::urldecode "$path")
        unencoded_url="$scheme://$domain$unencoded_req_path"
    else
        url_is_encoded="false"
        unencoded_req_path="$path"
        unencoded_url="$normalized_url"
        encoded_req_path=$(Bisu::urlencode "$path")
        encoded_url="$scheme://$domain$encoded_req_path"
    fi

    # Step 7: Set values in dictionary
    local rs=()
    Bisu::array_set "rs" "url_scheme" "$scheme"
    Bisu::array_set "rs" "url_domain" "$domain"
    Bisu::array_set "rs" "unencoded_req_path" "$unencoded_req_path"
    Bisu::array_set "rs" "unencoded_url" "$unencoded_url"
    Bisu::array_set "rs" "encoded_req_path" "$encoded_req_path"
    Bisu::array_set "rs" "encoded_url" "$encoded_url"

    local kv_str=$(Bisu::array_dump "rs")
    Bisu::set "var_ref" "${kv_str[@]}" || return 1
    eval "declare -gA ${receiver_var_name}=($var_ref)" 2>/dev/null || return 1
    return 0
}

# Convert URL query parameters to JSON
Bisu::url_params_to_json() {
    local str=$(Bisu::trim "$1")
    local key value json first=true

    # Remove leading slash if present
    Bisu::string_starts_with "$str" "/" && str="${str:1}"

    # Return empty JSON for empty input
    [ -n "$str" ] || {
        printf '%s' "{}"
        return 1
    }

    json="{"

    # Split by '&' and iterate
    IFS='&' read -r -a params <<<"$str"
    for param in "${params[@]}"; do
        # Split key and value by '='
        IFS='=' read -r key value <<<"$param"
        key=${key:-""}
        value=${value:-""}

        # Escape double quotes and backslashes in key/value
        key=${key//\\/\\\\}
        key=${key//\"/\\\"}
        value=${value//\\/\\\\}
        value=${value//\"/\\\"}

        # Append comma if not first element
        if [ "$first" = true ]; then
            first=false
        else
            json+=", "
        fi

        json+="\"$key\": \"$value\""
    done

    json+="}"

    Bisu::is_valid_json "$json" || {
        printf ''
        return 1
    }

    printf '%s' "$json"
    return 0
}

# Convert JSON object to URL query parameters
Bisu::json_to_url_params() {
    local str=$(Bisu::trim "$1")
    local key value param url_params=""

    # Return empty string if input is empty
    Bisu::is_valid_json "$str" || {
        printf ''
        return 1
    }

    # Remove surrounding braces if present
    str="${str#\{}"
    str="${str%\}}"

    # Split JSON entries by comma
    IFS=',' read -r -a entries <<<"$str"
    for entry in "${entries[@]}"; do
        # Split key and value by ':'
        key="${entry%%:*}"
        value="${entry#*:}"

        # Trim spaces and remove surrounding quotes
        key=$(Bisu::trim "${key//\"/}")
        value=$(Bisu::trim "${value//\"/}")

        # Append '&' if not first parameter
        [ -n "$url_params" ] && url_params+="&"

        url_params+="$key=$value"
    done

    printf '%s' "$url_params"
    return 0
}

# Bisu::reliable_curl - robust curl wrapper with retries
# Returns:
#   0 -> success (response code: 200)
#   1 -> failure (
#       prints internal error code:
#           5001="command missing", 5002="illegal url", 5005="unreachable network", 5006="unsupported behavior",
#           5008="permission denied", 5009="command internal panic"
#   )
Bisu::reliable_curl() {
    # -------------------------------
    # Public params (caller-visible)
    # -------------------------------
    local url=$(Bisu::trim "$1")
    local output_file=$(Bisu::trim "$2")
    local method=$(Bisu::trim "${3:-"GET"}")
    local data_file=$(Bisu::trim "$4")

    # -------------------------------
    # Grouped CURL_ global overrides
    # -------------------------------
    # All env-configurable behavior lives here for clarity.
    local headers_array_name="CURL_HEADERS"
    local CURL_CONNECT_TIMEOUT="${CURL_CONNECT_TIMEOUT:-30}"
    Bisu::is_posi_int "$CURL_CONNECT_TIMEOUT" || CURL_CONNECT_TIMEOUT=30
    local CURL_CONTINUE="${CURL_CONTINUE:-true}"
    local CURL_DISPLAY_ERRORS="${CURL_DISPLAY_ERRORS:-"false"}"
    Bisu::in_array "$CURL_DISPLAY_ERRORS" "true" "false" || CURL_DISPLAY_ERRORS="false"
    local CURL_RETRIES="${CURL_RETRIES:-0}"
    Bisu::is_nn_int "$CURL_RETRIES" || CURL_RETRIES=0
    local CURL_RETRY_DELAY="${CURL_RETRY_DELAY:-3}"
    Bisu::is_nn_int "$CURL_RETRY_DELAY" || CURL_RETRY_DELAY=3
    local CURL_RETRY_TIMEOUT="${CURL_RETRY_TIMEOUT:-60}"
    Bisu::is_nn_int "$CURL_RETRY_TIMEOUT" || CURL_RETRY_TIMEOUT=60
    local CURL_USER=$(Bisu::trim "${CURL_USER:-}")
    local CURL_PASSWORD=$(Bisu::trim "${CURL_PASSWORD:-}")
    local CURL_CERT=$(Bisu::trim "${CURL_CERT:-}")
    local CURL_KEY=$(Bisu::trim "${CURL_KEY:-}")
    local CURL_KEY_PASSPHRASE=$(Bisu::trim "${CURL_KEY_PASSPHRASE:-}")
    local CURL_EXTRA_OPTS=$(Bisu::trim "${CURL_EXTRA_OPTS:-}")
    local CURL_USE_RAW_STATUS_CODE=$(Bisu::trim "${CURL_USE_RAW_STATUS_CODE:-"false"}")
    Bisu::in_array "$CURL_USE_RAW_STATUS_CODE" "true" "false" || CURL_USE_RAW_STATUS_CODE="false"
    local CURL_FILE_HASH_ALGO=$(Bisu::trim "${CURL_FILE_HASH_ALGO:-}")
    CURL_FILE_HASH_ALGO=$(Bisu::strtolower "$CURL_FILE_HASH_ALGO")
    local CURL_FILE_HASH=$(Bisu::trim "${CURL_FILE_HASH:-}")

    # ------------------------------------
    # Internal vars (grouped & validated)
    # ------------------------------------
    local -a curl_opts=()           # options to pass to curl as an array
    local response_code=""          # captured from --write-out
    local curl_exit=0               # exit status of curl command
    local scheme=""                 # url scheme (http/https/ftp/sftp)
    local use_head_for_get=0        # 1 -> send HEAD instead of GET when user omitted Bisu::output
    local outdir=""                 # used when creating Bisu::output dir
    local retries validated_retries # numeric-checked retry vars
    local retry_delay validated_retry_delay
    local retry_max_time validated_retry_max_time

    # Validate numeric CURL_ envs and map to locals with safe fallbacks
    # retries
    if [[ "$CURL_RETRIES" =~ ^[0-9]+$ ]]; then
        validated_retries="$CURL_RETRIES"
    else
        validated_retries=2
    fi
    # retry delay
    if [[ "$CURL_RETRY_DELAY" =~ ^[0-9]+$ ]]; then
        validated_retry_delay="$CURL_RETRY_DELAY"
    else
        validated_retry_delay=3
    fi
    # retry max time
    if [[ "$CURL_RETRY_TIMEOUT" =~ ^[0-9]+$ ]]; then
        validated_retry_max_time="$CURL_RETRY_TIMEOUT"
    else
        validated_retry_max_time=60
    fi

    # ------------------------------
    # Dependency check
    # ------------------------------
    if ! Bisu::command_exists "curl"; then
        printf "5001\n"
        return 1
    fi

    # ---------------------------------
    # Basic validation of URL & method
    # ---------------------------------
    if ! Bisu::is_valid_url "$url"; then
        printf "5002\n"
        return 1
    fi

    scheme="${url%%:*}"
    case "$scheme" in
    http | https | ftp | sftp) ;;
    *)
        printf "5006\n"
        return 1
        ;;
    esac

    method="${method^^}"
    case "$method" in
    GET | POST | PUT | PATCH | DELETE | HEAD | OPTIONS) ;;
    *)
        printf "5006\n"
        return 1
        ;;
    esac

    # Validate data file presence/readability for body-bearing methods
    if [[ -n "$data_file" ]]; then
        if [[ ! -f "$data_file" || ! -r "$data_file" ]]; then
            printf "5002\n"
            return 1
        fi
    fi

    # ----------------------
    # Output-file policy
    # ----------------------
    if [ -z "$output_file" ]; then
        output_file="/dev/null"
    else
        outdir=$(dirname -- "$output_file")
        Bisu::mkdir_p "$outdir" || {
            printf "5008\n"
            return 1
        }
    fi

    local expected_sig_string=""
    if Bisu::is_file "$output_file" && [[ -n "$CURL_FILE_HASH" ]]; then
        if [[ "$CURL_FILE_HASH_ALGO" == "md5" ]]; then
            expected_sig_string=$(Bisu::md5_file "$output_file")
        elif [[ "$CURL_FILE_HASH_ALGO" == "sha1" ]]; then
            expected_sig_string=$(Bisu::sha1_file "$output_file")
        elif [[ "$CURL_FILE_HASH_ALGO" == "sha224" ]]; then
            expected_sig_string=$(Bisu::sha224_file "$output_file")
        elif [[ "$CURL_FILE_HASH_ALGO" == "sha256" ]]; then
            expected_sig_string=$(Bisu::sha256_file "$output_file")
        elif [[ "$CURL_FILE_HASH_ALGO" == "sha384" ]]; then
            expected_sig_string=$(Bisu::sha384_file "$output_file")
        elif [[ "$CURL_FILE_HASH_ALGO" == "sha512" ]]; then
            expected_sig_string=$(Bisu::sha512_file "$output_file")
        fi

        if [[ "$expected_sig_string" == "$CURL_FILE_HASH" ]]; then
            printf "200\n"
            return 0
        fi
    fi

    # ------------------------------------------
    # Build curl options (associative -> array)
    # ------------------------------------------
    # Collect fixed options in a map, then append in deterministic order to preserve behavior.
    local -A curl_kv=()

    if [[ "$CURL_DISPLAY_ERRORS" == "true" ]]; then
        curl_kv[silence_flag]="-sS"
    else
        curl_kv[silence_flag]="-s"
    fi

    curl_kv[location_flag]="-L"

    curl_kv[connect_timeout_flag]="--connect-timeout"
    curl_kv[connect_timeout_value]="$CURL_CONNECT_TIMEOUT"

    curl_kv[retry_flag]="--retry"
    curl_kv[retry_value]="$validated_retries"
    curl_kv[retry_delay_flag]="--retry-delay"
    curl_kv[retry_delay_value]="$validated_retry_delay"
    curl_kv[retry_connrefused_flag]="--retry-connrefused"
    curl_kv[retry_max_time_flag]="--retry-max-time"
    curl_kv[retry_max_time_value]="$validated_retry_max_time"

    curl_kv[write_out_flag]="--write-out"
    curl_kv[write_out_value]="%{response_code}"

    if [[ "$use_head_for_get" -eq 1 || "$method" == "HEAD" ]]; then
        curl_kv[head_flag]="-I"
    fi

    curl_kv[output_flag]="-o"
    curl_kv[output_value]="$output_file"

    if [[ "${CURL_CONTINUE}" == "true" && "$method" == "GET" && "$output_file" != "/dev/null" ]]; then
        curl_kv[resume_flag]="-C"
        curl_kv[resume_value]="-"
    fi

    if [[ "$method" != "GET" || -n "$data_file" ]]; then
        curl_kv[method_flag]="-X"
        curl_kv[method_value]="$method"
    fi

    case "$method" in
    POST | PUT | PATCH | DELETE)
        if [[ -n "$data_file" ]]; then
            curl_kv[data_flag]="--data-binary"
            curl_kv[data_value]="@$data_file"
        fi
        ;;
    esac

    # --------------------------------------------
    # Authentication: passcode & cert/key support
    # --------------------------------------------
    if [[ -n "$CURL_USER" || -n "$CURL_PASSWORD" ]]; then
        if [[ -n "$CURL_USER" && -n "$CURL_PASSWORD" ]]; then
            curl_kv[auth_flag]="-u"
            curl_kv[auth_value]="${CURL_USER}:${CURL_PASSWORD}"
        elif [[ -n "$CURL_USER" ]]; then
            curl_kv[auth_flag]="-u"
            curl_kv[auth_value]="${CURL_USER}"
        fi
    fi

    if [[ -n "$CURL_CERT" ]]; then
        curl_kv[cert_flag]="--cert"
        curl_kv[cert_value]="${CURL_CERT}"
        if [[ -n "$CURL_KEY_PASSPHRASE" ]]; then
            curl_kv[cert_pass_flag]="--pass"
            curl_kv[cert_pass_value]="${CURL_KEY_PASSPHRASE}"
        fi
    fi
    if [[ -n "$CURL_KEY" ]]; then
        curl_kv[key_flag]="--key"
        curl_kv[key_value]="${CURL_KEY}"
        if [[ -n "$CURL_KEY_PASSPHRASE" ]]; then
            curl_kv[key_pass_flag]="--pass"
            curl_kv[key_pass_value]="${CURL_KEY_PASSPHRASE}"
        fi
    fi

    # Extra user-provided options (split on whitespace safely)
    if [[ -n "$CURL_EXTRA_OPTS" ]]; then
        read -r -a _extra_opts <<<"$CURL_EXTRA_OPTS" 2>/dev/null
        curl_opts+=("${_extra_opts[@]}")
        unset "_extra_opts"
    fi

    # ------------------------------------------------------------
    # Headers conversion (indexed or associative array by name)
    # ------------------------------------------------------------
    if Bisu::array_is_available "$headers_array_name"; then
        # Associative: iterate original keys and transform to Title-Case hyphen-separated header names
        local orig_key header_name parts p first rest header_val joined
        for orig_key in "${!headers_array_name[@]}"; do
            header_name="${orig_key//_/-}"
            IFS='-' read -ra parts <<<"$header_name"
            joined=""
            for p in "${parts[@]}"; do
                if [[ -n "$p" ]]; then
                    first="${p:0:1}"
                    rest="${p:1}"
                    joined+="${first^^}${rest,,}-"
                fi
            done
            header_name="${joined%-}"
            header_val="${headers_array_name[$orig_key]}"
            curl_opts+=("-H" "${header_name}: ${header_val}")
        done
    fi

    # ----------------------------------------------------------------
    # Flatten curl_kv to curl_opts in original, deterministic order
    # ----------------------------------------------------------------
    [[ -n "${curl_kv[silence_flag]}" ]] && curl_opts+=("${curl_kv[silence_flag]}")
    [[ -n "${curl_kv[location_flag]}" ]] && curl_opts+=("${curl_kv[location_flag]}")
    if [[ -n "${curl_kv[connect_timeout_flag]}" ]]; then
        curl_opts+=("${curl_kv[connect_timeout_flag]}" "${curl_kv[connect_timeout_value]}")
    fi
    if [[ -n "${curl_kv[retry_flag]}" ]]; then
        curl_opts+=("${curl_kv[retry_flag]}" "${curl_kv[retry_value]}" "${curl_kv[retry_delay_flag]}" "${curl_kv[retry_delay_value]}"
            "${curl_kv[retry_connrefused_flag]}" "${curl_kv[retry_max_time_flag]}" "${curl_kv[retry_max_time_value]}")
    fi
    if [[ -n "${curl_kv[write_out_flag]}" ]]; then
        curl_opts+=("${curl_kv[write_out_flag]}" "${curl_kv[write_out_value]}")
    fi
    [[ -n "${curl_kv[head_flag]}" ]] && curl_opts+=("${curl_kv[head_flag]}")
    if [[ -n "${curl_kv[output_flag]}" ]]; then
        curl_opts+=("${curl_kv[output_flag]}" "${curl_kv[output_value]}")
    fi
    if [[ -n "${curl_kv[resume_flag]}" ]]; then
        curl_opts+=("${curl_kv[resume_flag]}" "${curl_kv[resume_value]}")
    fi
    if [[ -n "${curl_kv[method_flag]}" ]]; then
        curl_opts+=("${curl_kv[method_flag]}" "${curl_kv[method_value]}")
    fi
    if [[ -n "${curl_kv[data_flag]}" ]]; then
        curl_opts+=("${curl_kv[data_flag]}" "${curl_kv[data_value]}")
    fi
    if [[ -n "${curl_kv[auth_flag]}" ]]; then
        curl_opts+=("${curl_kv[auth_flag]}" "${curl_kv[auth_value]}")
    fi
    if [[ -n "${curl_kv[cert_flag]}" ]]; then
        curl_opts+=("${curl_kv[cert_flag]}" "${curl_kv[cert_value]}")
        [[ -n "${curl_kv[cert_pass_flag]}" ]] && curl_opts+=("${curl_kv[cert_pass_flag]}" "${curl_kv[cert_pass_value]}")
    fi
    if [[ -n "${curl_kv[key_flag]}" ]]; then
        curl_opts+=("${curl_kv[key_flag]}" "${curl_kv[key_value]}")
        [[ -n "${curl_kv[key_pass_flag]}" ]] && curl_opts+=("${curl_kv[key_pass_flag]}" "${curl_kv[key_pass_value]}")
    fi

    # -------------------------------------
    # Execute curl & capture response_code
    # -------------------------------------
    response_code="$(curl "${curl_opts[@]}" -- "$url" 2>/dev/null)"
    curl_exit=$?
    response_code=$(Bisu::trim "$response_code")
    local raw_status_code="$response_code"

    case "$scheme" in
    http | https)
        # HTTP/HTTPS: treat 2xx/3xx as success -> 200; 4xx/5xx or curl failure -> 0
        if [ "$curl_exit" -eq 0 ] && [ "$response_code" -ge 200 ] && [ "$response_code" -lt 400 ]; then
            response_code=200
        fi
        ;;
    ftp)
        # FTP: any successful curl call is normalized to 200
        if [ "$curl_exit" -eq 0 ]; then
            response_code=200
        fi
        ;;
    sftp)
        # SFTP: success -> 200, failure -> 0
        if [ "$curl_exit" -eq 0 ]; then
            response_code=200
        fi
        ;;
    *)
        # Other schemes: default to SFTP behavior
        if [ "$curl_exit" -eq 0 ]; then
            response_code=200
        fi
        ;;
    esac

    if [[ "$response_code" == "000" ]]; then
        response_code=5005
    fi

    if [[ "$response_code" != 200 ]]; then
        [[ "$CURL_USE_RAW_STATUS_CODE" == "true" ]] && printf '%s\n' "$raw_status_code" || printf '%s\n' "$response_code"
        return 1
    fi

    [[ "$CURL_USE_RAW_STATUS_CODE" == "true" ]] && printf '%s\n' "$raw_status_code" || printf '%s\n' "$response_code"
    return 0
}

# Generate a secure, URL-friendly nanoID-like string matching strict nanoID standards.
# Usage: Bisu::nanoid [length] [case_mode: lowercase|uppercase|mixed]
# Defaults: length=21, case_mode=mixed
Bisu::nanoid() {
    local length case_mode alphabet alpha_len result i=0
    local threshold num_bytes random_str byte_array array_len k=0 num_attempts=0
    local extra_factor=3 max_attempts=100

    # Parse and validate length
    length=${1:-21}
    length=$(Bisu::trim "$length")
    if ! Bisu::is_posi_int "$length"; then
        length=21
    fi

    # Parse and validate case_mode
    case_mode=${2:-mixed}
    case_mode=$(Bisu::trim "$case_mode")
    if ! Bisu::in_array "$case_mode" "lowercase" "uppercase" "mixed"; then
        case_mode=mixed
    fi

    # Apply case transformation
    case $case_mode in
    lowercase)
        alphabet='abcdefghijklmnopqrstuvwxyz'
        ;;
    uppercase)
        alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
        ;;
    mixed)
        # Base alphabet (64 chars: 0-9, a-z, A-Z, _-)
        alphabet='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-'
        ;;
    esac

    alpha_len=${#alphabet}
    if [[ $alpha_len -eq 0 ]]; then
        Bisu::error_log "Invalid nanoid alphabet." "⚠️"
        printf ''
        return 1
    fi

    # Compute threshold for unbiased rejection sampling (nanoID standard)
    threshold=$(((256 / alpha_len) * alpha_len))

    # Batch-generate random bytes (secure from /dev/urandom)
    num_bytes=$((length * extra_factor))
    random_str=$(dd if=/dev/urandom bs=1 count=$num_bytes 2>/dev/null | od -An -tu1 2>/dev/null | tr -s ' \n' ' ')
    IFS=' ' read -ra byte_array <<<"$random_str"
    array_len=${#byte_array[@]}

    # Build result with rejection sampling for uniformity
    while [[ $i -lt $length ]]; do
        # Regenerate if exhausted (rare)
        if [[ $k -ge $array_len ]]; then
            local additional=$(((length - i) * extra_factor))
            random_str=$(dd if=/dev/urandom bs=1 count=$additional 2>/dev/null | od -An -tu1 2>/dev/null | tr -s ' \n' ' ')
            IFS=' ' read -ra additional_bytes <<<"$random_str"
            byte_array+=("${additional_bytes[@]}")
            array_len=${#byte_array[@]}
            if [[ $array_len -eq $k ]]; then
                Bisu::error_log "Failed to generate random bytes for nanoid." "⚠️"
                printf ''
                return 1
            fi
        fi

        local byte=${byte_array[$k]}
        ((k++))

        # Reject for unbiased distribution
        if [[ $byte -ge $threshold ]]; then
            continue
        fi

        local idx=$((byte % alpha_len))
        result+="${alphabet:$idx:1}"
        ((i++))
        ((num_attempts++))

        # Safety limit on attempts
        if [[ $num_attempts -gt $((max_attempts * length)) ]]; then
            Bisu::error_log "Excessive attempts generating ID of nanoid; Attempt limit: ${max_attempts}" "⚠️"
            printf ''
            return 1
        fi
    done

    printf '%s\n' "$result"
    return 0
}

# Generate a secure random UUIDv4 (128 bits)
Bisu::uuidv4() {
    local uuidv4=""
    # Use /dev/urandom to generate random data and format as hex
    uuidv4=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | awk '{print tolower($0)}' 2>/dev/null)
    uuidv4=$(Bisu::trim "$uuidv4")

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
Bisu::hex2str() {
    local hex_string=$(Bisu::trim "$1")
    printf '%s' "$hex_string" | tr -d '[:space:]' | xxd -r -p || {
        printf ''
        return 1
    }

    return 0
}

# Function to convert string to hex
Bisu::str2hex() {
    local input_string=$(Bisu::trim "$1")
    local having_space=$(Bisu::trim "$2")
    Bisu::in_array "$having_space" "true" "false" || having_space="true"

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
# Concatenated 3-digit zero-padded ASCII decimals.
# Usage: Bisu::base10_encode "string" -> "DDD...DDD"
Bisu::base10_encode() {
    local input result="" char ascii
    input=$(Bisu::trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    # Read one character at a time and emit 3-digit decimal (000-255)
    while IFS= read -r -n1 char; do
        ascii=$(LC_ALL=C printf '%03d' "'$char")
        result+="$ascii"
    done <<<"$input"

    printf '%s' "$result"
    return 0
}

# Decode from Base10 to the original string.
# Accepts concatenated 3-digit blocks or tokens separated by non-digits.
# Usage: Bisu::base10_decode "DDD...DDD"  OR  Bisu::base10_decode "DDD SEP DDD SEP ..."
Bisu::base10_decode() {
    local input result="" ascii_value ascii_dec char len i token processed=0

    input=$(Bisu::trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    # If there is any non-digit, parse tokens (1-3 digits) using pure-bash regex (no external tools)
    if [[ "$input" =~ [^0-9] ]]; then
        while [[ $input =~ ^[^0-9]*([0-9]{1,3})(.*)$ ]]; do
            token=${BASH_REMATCH[1]}
            input=${BASH_REMATCH[2]}
            # Force decimal interpretation, reject invalid numeric forms
            ascii_dec=$((10#$token))
            ((ascii_dec >= 0 && ascii_dec <= 255)) || {
                printf ''
                return 1
            }
            # ignore NUL token '000'
            if ((ascii_dec != 0)); then
                char=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$ascii_dec")")
                result+="$char"
            fi
            processed=1
        done
        # if no numeric tokens were found, treat as invalid input
        ((processed == 1)) || {
            printf ''
            return 1
        }
    else
        # Pure digits: must be multiple of 3 (fixed-width 3-digit blocks)
        len=${#input}
        ((len % 3 == 0)) || {
            printf ''
            return 1
        }

        for ((i = 0; i < len; i += 3)); do
            ascii_value=${input:i:3}
            ascii_dec=$((10#$ascii_value))
            ((ascii_dec >= 0 && ascii_dec <= 255)) || {
                printf ''
                return 1
            }
            # ignore NUL token '000'
            if ((ascii_dec != 0)); then
                char=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$ascii_dec")")
                result+="$char"
            fi
        done
    fi

    printf '%s' "$result"
    return 0
}

# Bisu::base26_encode "string" -> base26 text (2 letters per byte)
Bisu::base26_encode() {
    local input result char ascii high low alphabet base
    input=$(Bisu::trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    base=26

    while IFS= read -r -n1 char; do
        ascii=$(LC_ALL=C printf '%d' "'$char")
        high=$((ascii / base))
        low=$((ascii % base))
        result+="${alphabet:high:1}${alphabet:low:1}"
    done <<<"$input"

    printf '%s' "$result"
    return 0
}

# Bisu::base26_decode "text" -> original bytes (ignores byte==0)
# Accepts A-Z sequences or tokenized input with separators.
Bisu::base26_decode() {
    local input result token len c0 c1 v0 v1 byte processed=0 i base ord
    input=$(Bisu::trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    input=${input^^}
    base=26

    if [[ "$input" =~ [^A-Z] ]]; then
        while [[ $input =~ ^[^A-Z]*([A-Z]{1,2})(.*)$ ]]; do
            token=${BASH_REMATCH[1]}
            input=${BASH_REMATCH[2]}
            len=${#token}
            if ((len == 1)); then
                c0=${token:0:1}
                ord=$(LC_ALL=C printf '%d' "'$c0")
                v0=$((ord - 65))
                byte=$v0
            else
                c0=${token:0:1}
                c1=${token:1:1}
                ord=$(LC_ALL=C printf '%d' "'$c0")
                v0=$((ord - 65))
                ord=$(LC_ALL=C printf '%d' "'$c1")
                v1=$((ord - 65))
                byte=$((v0 * base + v1))
            fi
            ((v0 >= 0 && v0 < base)) || {
                printf ''
                return 1
            }
            if ((len == 2)); then ((v1 >= 0 && v1 < base)) || {
                printf ''
                return 1
            }; fi
            ((byte >= 0 && byte <= 255)) || {
                printf ''
                return 1
            }
            if ((byte != 0)); then result+=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$byte")"); fi
            processed=1
        done
        ((processed == 1)) || {
            printf ''
            return 1
        }
    else
        len=${#input}
        ((len % 2 == 0)) || {
            printf ''
            return 1
        }
        for ((i = 0; i < len; i += 2)); do
            c0=${input:i:1}
            c1=${input:i+1:1}
            ord=$(LC_ALL=C printf '%d' "'$c0")
            v0=$((ord - 65))
            ord=$(LC_ALL=C printf '%d' "'$c1")
            v1=$((ord - 65))
            ((v0 >= 0 && v0 < base && v1 >= 0 && v1 < base)) || {
                printf ''
                return 1
            }
            byte=$((v0 * base + v1))
            ((byte >= 0 && byte <= 255)) || {
                printf ''
                return 1
            }
            if ((byte != 0)); then result+=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$byte")"); fi
        done
    fi

    printf '%s' "$result"
    return 0
}

# Bisu::base36_encode "string" -> base36 text (2 chars per byte)
Bisu::base36_encode() {
    local input result char ascii high low alphabet base
    input=$(Bisu::trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    alphabet='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    base=36

    # per-byte processing (fast, pure bash)
    while IFS= read -r -n1 char; do
        ascii=$(LC_ALL=C printf '%d' "'$char")
        high=$((ascii / base))
        low=$((ascii % base))
        result+="${alphabet:high:1}${alphabet:low:1}"
    done <<<"$input"

    printf '%s' "$result"
    return 0
}

# Bisu::base36_decode "text" -> original bytes (ignores byte==0)
# Accepts either pure concatenated chars (even length) or tokenized input with separators.
Bisu::base36_decode() {
    local input result token len c0 c1 v0 v1 byte processed=0 i base
    input=$(Bisu::trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    # normalize case so 'a'..'z' accepted as 'A'..'Z'
    input=${input^^}
    base=36

    # tokenized input (contains separators / other chars)
    if [[ "$input" =~ [^0-9A-Z] ]]; then
        while [[ $input =~ ^[^0-9A-Z]*([0-9A-Z]{1,2})(.*)$ ]]; do
            token=${BASH_REMATCH[1]}
            input=${BASH_REMATCH[2]}
            len=${#token}
            if ((len == 1)); then
                c0=${token:0:1}
                if [[ "$c0" =~ [0-9] ]]; then v0=$((c0)); else v0=$(($(LC_ALL=C printf '%d' "'$c0") - 55)); fi
                byte=$v0
            else
                c0=${token:0:1}
                c1=${token:1:1}
                if [[ "$c0" =~ [0-9] ]]; then v0=$((c0)); else v0=$(($(LC_ALL=C printf '%d' "'$c0") - 55)); fi
                if [[ "$c1" =~ [0-9] ]]; then v1=$((c1)); else v1=$(($(LC_ALL=C printf '%d' "'$c1") - 55)); fi
                byte=$((v0 * base + v1))
            fi
            ((byte >= 0 && byte <= 255)) || {
                printf ''
                return 1
            }
            # ignore NUL for portability (keeps behavior aligned with original)
            if ((byte != 0)); then
                result+=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$byte")")
            fi
            processed=1
        done
        ((processed == 1)) || {
            printf ''
            return 1
        }
    else
        # pure allowed-chars path must be even length (2 chars per byte)
        len=${#input}
        ((len % 2 == 0)) || {
            printf ''
            return 1
        }
        for ((i = 0; i < len; i += 2)); do
            c0=${input:i:1}
            c1=${input:i+1:1}
            if [[ "$c0" =~ [0-9] ]]; then v0=$((c0)); else v0=$(($(LC_ALL=C printf '%d' "'$c0") - 55)); fi
            if [[ "$c1" =~ [0-9] ]]; then v1=$((c1)); else v1=$(($(LC_ALL=C printf '%d' "'$c1") - 55)); fi
            byte=$((v0 * base + v1))
            ((byte >= 0 && byte <= 255)) || {
                printf ''
                return 1
            }
            if ((byte != 0)); then
                result+=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$byte")")
            fi
        done
    fi

    printf '%s' "$result"
    return 0
}

# Bisu::base62_encode "string" -> base62 text (2 chars per byte)
Bisu::base62_encode() {
    local input result char ascii high low alphabet base
    input=$(Bisu::trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    alphabet='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
    base=62

    while IFS= read -r -n1 char; do
        ascii=$(LC_ALL=C printf '%d' "'$char")
        high=$((ascii / base))
        low=$((ascii % base))
        result+="${alphabet:high:1}${alphabet:low:1}"
    done <<<"$input"

    printf '%s' "$result"
    return 0
}

# Bisu::base62_decode "text" -> original bytes (ignores byte==0)
# Accepts 0-9A-Za-z sequences or tokenized input with separators.
Bisu::base62_decode() {
    local input result token len c0 c1 v0 v1 byte processed=0 i base ord
    input=$(Bisu::trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }
    base=62

    if [[ "$input" =~ [^0-9A-Za-z] ]]; then
        while [[ $input =~ ^[^0-9A-Za-z]*([0-9A-Za-z]{1,2})(.*)$ ]]; do
            token=${BASH_REMATCH[1]}
            input=${BASH_REMATCH[2]}
            len=${#token}
            if ((len == 1)); then
                c0=${token:0:1}
                if [[ "$c0" =~ [0-9] ]]; then
                    v0=$((c0))
                else
                    ord=$(LC_ALL=C printf '%d' "'$c0")
                    if ((ord >= 65 && ord <= 90)); then
                        v0=$((ord - 55))
                    elif ((ord >= 97 && ord <= 122)); then
                        v0=$((ord - 61))
                    else
                        printf ''
                        return 1
                    fi
                fi
                byte=$v0
            else
                c0=${token:0:1}
                c1=${token:1:1}
                if [[ "$c0" =~ [0-9] ]]; then
                    v0=$((c0))
                else
                    ord=$(LC_ALL=C printf '%d' "'$c0")
                    if ((ord >= 65 && ord <= 90)); then
                        v0=$((ord - 55))
                    elif ((ord >= 97 && ord <= 122)); then
                        v0=$((ord - 61))
                    else
                        printf ''
                        return 1
                    fi
                fi
                if [[ "$c1" =~ [0-9] ]]; then
                    v1=$((c1))
                else
                    ord=$(LC_ALL=C printf '%d' "'$c1")
                    if ((ord >= 65 && ord <= 90)); then
                        v1=$((ord - 55))
                    elif ((ord >= 97 && ord <= 122)); then
                        v1=$((ord - 61))
                    else
                        printf ''
                        return 1
                    fi
                fi
                byte=$((v0 * base + v1))
            fi
            ((byte >= 0 && byte <= 255)) || {
                printf ''
                return 1
            }
            if ((byte != 0)); then
                result+=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$byte")")
            fi
            processed=1
        done
        ((processed == 1)) || {
            printf ''
            return 1
        }
    else
        len=${#input}
        ((len % 2 == 0)) || {
            printf ''
            return 1
        }
        for ((i = 0; i < len; i += 2)); do
            c0=${input:i:1}
            c1=${input:i+1:1}
            if [[ "$c0" =~ [0-9] ]]; then
                v0=$((c0))
            else
                ord=$(LC_ALL=C printf '%d' "'$c0")
                if ((ord >= 65 && ord <= 90)); then
                    v0=$((ord - 55))
                elif ((ord >= 97 && ord <= 122)); then
                    v0=$((ord - 61))
                else
                    printf ''
                    return 1
                fi
            fi
            if [[ "$c1" =~ [0-9] ]]; then
                v1=$((c1))
            else
                ord=$(LC_ALL=C printf '%d' "'$c1")
                if ((ord >= 65 && ord <= 90)); then
                    v1=$((ord - 55))
                elif ((ord >= 97 && ord <= 122)); then
                    v1=$((ord - 61))
                else
                    printf ''
                    return 1
                fi
            fi
            byte=$((v0 * base + v1))
            ((byte >= 0 && byte <= 255)) || {
                printf ''
                return 1
            }
            if ((byte != 0)); then
                result+=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$byte")")
            fi
        done
    fi

    printf '%s' "$result"
    return 0
}

# Encode a string to Base64
Bisu::base64_encode() {
    local input=$(Bisu::trim "$1")
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
Bisu::base64_decode() {
    local input=$(Bisu::trim "$1")
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

# Generate random string based on Bisu::uuidv4
Bisu::random_string() {
    local byte_length=$(Bisu::trim "$1")
    byte_length=${byte_length:-20}
    local type=$(Bisu::trim "$2")
    type=${type:-"base10"}
    local needle=""
    local uuid=""
    local result=""

    # Validate byte_length
    if ! Bisu::is_posi_int "$byte_length"; then
        printf ''
        return 1
    fi

    local uuid_rounds=$(printf '%s' "$byte_length / 32" | bc -l)
    uuid_rounds=$(Bisu::normalize_number "$uuid_rounds")
    uuid_rounds=$(Bisu::ceil "$uuid_rounds")
    Bisu::is_posi_int "$uuid_rounds" || {
        printf ''
        return 1
    }

    for ((i = 0; i < uuid_rounds; i++)); do
        uuid=$(Bisu::uuidv4)
        needle="$needle$uuid"
    done

    # Enforce limits based on type
    case "$type" in
    "base10")
        result=$(Bisu::base10_encode "$needle")
        result=$(Bisu::substr "$result" 0 "$byte_length")
        ;;
    "base26")
        result=$(Bisu::base26_encode "$needle")
        result=$(Bisu::substr "$result" 0 "$byte_length")
        ;;
    "base36")
        result=$(Bisu::base36_encode "$needle")
        result=$(Bisu::substr "$result" 0 "$byte_length")
        ;;
    "base62")
        result=$(Bisu::base62_encode "$needle")
        result=$(Bisu::substr "$result" 0 "$byte_length")
        ;;
    "base64")
        result=$(Bisu::base64_encode "$needle")
        result=$(Bisu::substr "$result" 0 "$byte_length")
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
Bisu::check_commands_list() {
    local invalid_commands_count=0
    local invalid_commands=""

    Bisu::is_array "BISU_REQUIRED_EXTERNAL_COMMANDS" || Bisu::error_exit "Invalid array of BISU_REQUIRED_EXTERNAL_COMMANDS."

    invalid_commands=($(Bisu::command_exists_async "${BISU_REQUIRED_EXTERNAL_COMMANDS[@]}"))
    invalid_commands_count=$(Bisu::array_count "invalid_commands")
    invalid_commands=$(printf '%s, ' "${invalid_commands[@]}")
    # Report the invalid commandString if any
    if [ $invalid_commands_count -gt 0 ]; then
        Bisu::error_exit "Missing $invalid_commands_count command(s): $invalid_commands"
    fi
}

# Function: Bisu::hanging_process
# Return: process status value
Bisu::hanging_process() {
    local pid=$(Bisu::trim "$1")
    Bisu::is_posi_int "$pid" || {
        return 1
    }

    wait "$pid" &>/dev/null
    local status=$?
    Bisu::is_nn_int "$status" || {
        return 1
    }

    [[ "$status" == 0 ]] || return 1
    Bisu::quit 0 "$pid" || return 1
    return 0
}

# Function to clean files when exit
Bisu::exit_with_commands() {
    if ! Bisu::is_array "BISU_EXIT_WITH_COMMANDS"; then
        Bisu::error_exit "Invalid array name 'BISU_EXIT_WITH_COMMANDS' provided."
    fi

    local util_name=$(Bisu::current_util_name)
    Bisu::log_msg "🕒 ${util_name}: Cleaning up..." "true"
    for val in "${BISU_EXIT_WITH_COMMANDS[@]}"; do
        val=$(Bisu::trim "$val")
        if [ -z "$val" ]; then
            continue
        fi
        {
            eval "$val" | tee -a -- "$(Bisu::current_log_file)" &
            disown %+ &>/dev/null
        } &
        &>/dev/null
        disown %+ &>/dev/null
    done

    Bisu::log_msg "⌛️ ${util_name}: Quitting..." "true"
    Bisu::quit
}

# Function for atomic mutex lock fast check
Bisu::atomic_mutex_lock() {
    local atomic_mutex_lock=$(Bisu::trim "$BISU_USE_AML_LOCK")

    if Bisu::in_array "$BISU_CURRENT_UTIL_ACTION" $(printf '%s ' "${BISU_ACTIONS_RO[@]}"); then
        atomic_mutex_lock="false"
    fi

    Bisu::in_array "$atomic_mutex_lock" "true" "false" || atomic_mutex_lock="false"
    [[ "$atomic_mutex_lock" == "true" ]] || return 1

    return 0
}

# set lock flag for flock
Bisu::lock_held() {
    [ "$BISU_LOCK_HELD" -eq 1 ] || BISU_LOCK_HELD=1
    return 0
}

# set BISU start flag
Bisu::bisu_start_flag() {
    [ "$BISU_START_FLAG" -eq 1 ] || BISU_START_FLAG=1
    return 0
}

# Function to acquire a lock to prevent multiple instances
Bisu::acquire_lock() {
    local lock_file=$(Bisu::current_lock_file)
    [ -n "$lock_file" ] || Bisu::error_exit "❗️ Failed to acquire 🔒 lock."
    exec 200>"$lock_file" 2>/dev/null || Bisu::error_exit "❗️ Cannot open 🔒 lock file: $lock_file"
    flock -n 200 2>/dev/null || {
        Bisu::lock_held
        Bisu::error_exit "🔒 An instance is running: $lock_file"
    }
}

# Function to release the lock
Bisu::release_lock() {
    [ "$BISU_LOCK_HELD" -eq 0 ] || return 0
    local lock_file=$(Bisu::current_lock_file)
    Bisu::is_file "$lock_file" || {
        return 0
    }

    flock -u 200 2>/dev/null && Bisu::saferm "$lock_file" || {
        Bisu::error_log "Failed to remove lock file: ${lock_file}"
        return 1
    }

    Bisu::log_msg "✅ Released 🔒 lock_file: ${lock_file}" "true"
    return 0
}

# Function: Bisu::set_title
# Purpose: Sets the terminal title safely and robustly
# Arguments: $1 - Title string
# Returns: 0 on success, 1 on invalid input, 2 on unsupported terminal
Bisu::set_title() {
    local title=$(Bisu::trim "$1")

    [ -n "$title" ] || return 1
    # Replace any non-alphanumeric character check and clean

    title=$(printf '%s\n' "$title" | awk '!/[^a-zA-Z0-9\-\(\)\#\@ ]/ { print $0 }' 2>/dev/null) || return 1
    # Set terminal title (in a POSIX-compliant way)
    exec 3>/dev/tty || return 1
    printf '\033]2;%s\007' "$title" >&3 2>/dev/null

    return 0
}

# Function to revert the terminal title
Bisu::revert_title() {
    Bisu::set_title "$BISU_DEFAULT_TITLE"
    return 0
}

# Add new element to pending to load script list, param 1 as the to load script file
Bisu::import_script() {
    local script=$(Bisu::trim "$1")
    Bisu::is_file "$script" || {
        Bisu::error_log "Failed to import script: $script"
        return 1
    }
    source "$script" 2>/dev/null || {
        Bisu::error_log "Failed to import script: $script"
        return 1
    }
    return 0
}

# Automatically import required scripts
Bisu::load_required_scripts() {
    Bisu::is_array "BISU_REQUIRED_SCRIPTS" || {
        Bisu::error_log "Invalid BISU_REQUIRED_SCRIPTS array." "⚠️"
        return 1
    }

    for script in "${BISU_REQUIRED_SCRIPTS[@]}"; do
        Bisu::import_script "$script"
    done

    return 0
}

# Execute a command when Bisu::quit
Bisu::exec_when_quit() {
    local command=$(Bisu::trim "$1")
    Bisu::array_unique_push "BISU_EXIT_WITH_COMMANDS" "$command" || {
        return 1
    }
    return 0
}

# verify utility's sig
Bisu::verify_sig() {
    Bisu::normalize_bool "BISU_VERIFY_SIG"
    [[ "$BISU_VERIFY_SIG" == "true" ]] && {
        local sig_status=$(Bisu::verify_sig_file "$(Bisu::bisu_file_path).asc" "$(Bisu::bisu_file_path)")
        Bisu::string_starts_with "$sig_status" "ERR_" && {
            Bisu::error_exit "Invalid bisu signature, signature specific error: ${sig_status}"
        }
    }

    Bisu::normalize_bool "BISU_CURRENT_UTIL_VERIFY_SIG"
    [[ "$BISU_CURRENT_UTIL_VERIFY_SIG" == "true" ]] && {
        local sig_status=$(Bisu::verify_sig_file "$(Bisu::current_file_path).asc" "$(Bisu::current_file_path)")
        Bisu::string_starts_with "$sig_status" "ERR_" && {
            Bisu::error_exit "Invalid utility signature, signature specific error: ${sig_status}"
        }
    }
}

# Register the current command
Bisu::register_current_command() {
    local current_args=$(Bisu::current_args)
    BISU_UNIX_USERNAME=$(whoami)
    BISU_UNIX_HOSTNAME=$(hostname)
    BISU_CURRENT_UTIL_COMMAND="$BISU_CURRENT_UTIL_FILE_PATH $current_args"
    [ -n "$BISU_CURRENT_UTIL_FILE_NAME" ] && {
        BISU_USER_CONF_DIR="${HOME}/.local/config/${BISU_CURRENT_UTIL_FILE_NAME}"
    }
    [ -n "$BISU_CURRENT_UTIL_TARGET_DIR" ] && Bisu::is_dir "$BISU_CURRENT_UTIL_TARGET_DIR" || {
        BISU_CURRENT_UTIL_TARGET_DIR=$(Bisu::target_dir)
    }

    # normalization of arrays allowed to manually modify them
    Bisu::array_is_available "BISU_CURRENT_UTIL_REQUIRED_COMMANDS" &&
        Bisu::indexed_array_merge "BISU_REQUIRED_EXTERNAL_COMMANDS" "BISU_CURRENT_UTIL_REQUIRED_COMMANDS" "BISU_REQUIRED_EXTERNAL_COMMANDS" &&
        Bisu::array_unique "BISU_REQUIRED_EXTERNAL_COMMANDS"
    Bisu::array_is_available "BISU_CURRENT_UTIL_REQUIRED_SCRIPTS" &&
        Bisu::indexed_array_merge "BISU_REQUIRED_SCRIPTS" "BISU_CURRENT_UTIL_REQUIRED_SCRIPTS" "BISU_REQUIRED_SCRIPTS" && Bisu::array_unique "BISU_REQUIRED_SCRIPTS"
    Bisu::array_is_available "BISU_CURRENT_UTIL_ACTIONS_RO" && Bisu::indexed_array_merge "BISU_ACTIONS_RO" "BISU_CURRENT_UTIL_ACTIONS_RO" "BISU_ACTIONS_RO" &&
        Bisu::array_unique "BISU_ACTIONS_RO"
    Bisu::array_is_available "BISU_CURRENT_UTIL_AUTORUN_COMMANDS" && Bisu::indexed_array_merge "BISU_AUTORUN" "BISU_CURRENT_UTIL_AUTORUN_COMMANDS" "BISU_AUTORUN" &&
        Bisu::array_unique "BISU_AUTORUN"
    Bisu::array_is_available "BISU_CURRENT_UTIL_EXIT_WITH_COMMANDS" &&
        Bisu::indexed_array_merge "BISU_EXIT_WITH_COMMANDS" "BISU_CURRENT_UTIL_EXIT_WITH_COMMANDS" "BISU_EXIT_WITH_COMMANDS" && Bisu::array_unique "BISU_EXIT_WITH_COMMANDS"
}

# Parse command-line arguments into an associative storage backend.
# - Uses only `Bisu::array_set "$array" "$key" "$value"` to write values.
# - Uses `Bisu::array_get "$array" "$key"` to read existing values (to enforce repetition rules).
# - Writes into "$args_array_name" or "result" by default.
# - Emits values only (in insertion order) on stdout (one per line), then returns 0.
Bisu::extract_args() {
    local array_name=$(Bisu::trim "$1")
    Bisu::is_valid_var_name "$array_name" || return 1
    # Load args safely (no splitting on spaces)
    local -a args
    mapfile -t args < <(Bisu::current_args)

    local argc=${#args[@]}
    local i=0
    declare -A target=()

    # order_list records keys in the order they were first set (insertion order)
    local -a order_list=()
    local positional_index=1
    local GETARGS_OVERRIDE_FLAG="${GETARGS_OVERRIDE:-0}"
    local EMPTY_EXPR_literal="$BISU_EMPTY_EXPR" # the literal to use for booleans
    local stop_parsing=0

    # Internal function-like inline logic (kept inline as required):
    # - set_key_if_allowed KEY VALUE
    #     respects repetition rules and records insertion order.
    # Implementation uses only Bisu::array_get/Bisu::array_set for storage checks/sets.
    #
    # Because subfunctions are disallowed by the spec, implement logic inline via labels
    # (comments) where used.

    while [ $i -lt $argc ]; do
        local token="${args[$i]}"

        if [ "$stop_parsing" -eq 1 ]; then
            # All subsequent args are positional
            local key="$positional_index"
            Bisu::array_set "target" "$key" "$token"
            order_list+=("$key")
            positional_index=$((positional_index + 1))
            i=$((i + 1))
            continue
        fi

        # End-of-options marker (unless consumed as a KV value later)
        if [ "$token" = "--" ]; then
            # '--' alone stops option parsing
            stop_parsing=1
            i=$((i + 1))
            continue
        fi

        # Long options: start with '--' (including 3+ dashes which will be normalized)
        if [[ "$token" == --* ]]; then
            # Handle forms:
            #  --opt=value        -> opt="value"
            #  --opt value        -> opt="value" (if next doesn't start with '-')
            #  --opt key=value    -> opt="key=value"
            #  --opt              -> opt="$BISU_EMPTY_EXPR"
            local long_raw="$token"
            local val=""
            local keyraw=""
            if [[ "$long_raw" == *=* ]]; then
                # --opt=value  (split at first '=')
                keyraw="${long_raw%%=*}"
                val="${long_raw#*=}"
                # strip leading dashes from keyraw
                # remove ALL leading '-' (3+ dashes allowed)
                while [[ "$keyraw" == -* ]]; do keyraw="${keyraw#-}"; done
                # normalize internal '-' to '_'
                local key="${keyraw//-/_}"
                # explicit empty after '=' means user supplied empty -> store single space " "
                [ -z "$val" ] && val=" "

                # repetition check
                local existing
                existing="$(Bisu::array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    Bisu::array_set "target" "$key" "$val"
                    # record order if first set
                    [ -z "$existing" ] && order_list+=("$key")
                fi
                i=$((i + 1))
                continue
            else
                # --opt (without '=')
                # keyraw is token without leading dashes
                keyraw="$long_raw"
                while [[ "$keyraw" == -* ]]; do keyraw="${keyraw#-}"; done
                local key="${keyraw//-/_}"

                # Lookahead to decide if it's a KV (next not starting with '-')
                local nextidx=$((i + 1))
                if [ $nextidx -lt $argc ]; then
                    local next="${args[$nextidx]}"
                    # If next is exactly '--' then spec says: if it's being used as the KV value,
                    # store it literally as the value. Otherwise, '--' alone stops option parsing.
                    if [[ "$next" = "--" ]]; then
                        # Treat it as a *value* for this option (per spec).
                        val="--"
                        # consume next arg as the value
                        i=$((i + 2))
                        local existing
                        existing="$(Bisu::array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            Bisu::array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
                        fi
                        continue
                    fi

                    # if next does not start with '-', bind it as the value (covers key=value literal too)
                    if [[ ! "$next" == -* ]]; then
                        val="$next"
                        i=$((i + 2))
                        local existing
                        existing="$(Bisu::array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            # explicit empty string binding (user wrote --opt "" ) would be an empty arg,
                            # but if val is empty we treat it as explicit empty: store single space " ".
                            [ -z "$val" ] && val=" "
                            Bisu::array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
                        fi
                        continue
                    fi
                fi

                # Otherwise, boolean flag
                val="$EMPTY_EXPR_literal"
                i=$((i + 1))
                local existing
                existing="$(Bisu::array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    Bisu::array_set "target" "$key" "$val"
                    [ -z "$existing" ] && order_list+=("$key")
                fi
                continue
            fi
        fi

        # Short options: start with single '-' and not '--'
        if [[ "$token" == -* && "$token" != "-" ]]; then
            # Distinguish single-letter '-k' vs bundled '-abc' vs '-ovalue' (which is treated as bundling)
            # If token length == 2 (e.g., -k) then it may bind the next arg as a value (if next exists and does not start with '-')
            local token_len=${#token}
            if [ "$token_len" -eq 2 ]; then
                local ch="${token:1:1}"
                local key="$ch"
                # check lookahead for KV binding: -k value -> KV; only when -k is alone, not bundled
                local nextidx=$((i + 1))
                if [ $nextidx -lt $argc ]; then
                    local next="${args[$nextidx]}"
                    # if next is exactly '--', spec: '--' after KV option stored as literal value "--"
                    if [ "$next" = "--" ]; then
                        # treat as value "--"
                        local val="--"
                        i=$((i + 2))
                        local existing
                        existing="$(Bisu::array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            Bisu::array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
                        fi
                        continue
                    fi
                    # Bind next as value only if it does NOT start with '-'
                    if [[ ! "$next" == -* ]]; then
                        local val="$next"
                        i=$((i + 2))
                        local existing
                        existing="$(Bisu::array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            [ -z "$val" ] && val=" "
                            Bisu::array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
                        fi
                        continue
                    fi
                fi

                # Otherwise boolean
                local val="$EMPTY_EXPR_literal"
                i=$((i + 1))
                local existing
                existing="$(Bisu::array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    Bisu::array_set "target" "$key" "$val"
                    [ -z "$existing" ] && order_list+=("$key")
                fi
                continue
            else
                # Bundled short options or -ovalue: treat every character after '-' as its own boolean.
                # Example: -abc -> a="$BISU_EMPTY_EXPR" b="$BISU_EMPTY_EXPR" c="$BISU_EMPTY_EXPR"
                # Example: -ovalue -> o="$BISU_EMPTY_EXPR" v="$BISU_EMPTY_EXPR" a="$BISU_EMPTY_EXPR" l="$BISU_EMPTY_EXPR" u="$BISU_EMPTY_EXPR" e="$BISU_EMPTY_EXPR"
                local j=1
                while [ $j -lt $token_len ]; do
                    local ch="${token:$j:1}"
                    local key="$ch"
                    local val="$EMPTY_EXPR_literal"
                    local existing
                    existing="$(Bisu::array_get "target" "$key")"
                    if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                        Bisu::array_set "target" "$key" "$val"
                        [ -z "$existing" ] && order_list+=("$key")
                    fi
                    j=$((j + 1))
                done
                i=$((i + 1))
                continue
            fi
        fi

        # Anything else is a positional argument
        {
            local key="$positional_index"
            Bisu::array_set "target" "$key" "$token"
            order_list+=("$key")
            positional_index=$((positional_index + 1))
            i=$((i + 1))
        }
    done

    local kv_str=$(Bisu::array_dump "target")
    Bisu::set "arr_ref" "${kv_str[@]}" || return 1
    # IMPORTANT: use -g so the declared associative array is global (visible outside function)
    eval "declare -gA ${array_name}=($arr_ref)" 2>/dev/null || return 1
    return 0
}

# define current action
Bisu::set_action() {
    local action=$(Bisu::trim "$1")
    BISU_CURRENT_UTIL_ACTION="$action"
    return 0
}

# Strict-safe adaptive function executor
Bisu::safe_callfunc() {
    (
        local fn_name=$(Bisu::trim "$1")
        Bisu::is_valid_func_name "$fn_name" || {
            printf '1'
            return 1
        }
        shift || {
            printf ''
            return 1
        }

        # Check function existence
        if Bisu::is_func "$fn_name"; then
            # Call function and capture exit
            eval "${fn_name} $(printf '%s ' "$@")" 2>/dev/null || {
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
Bisu::safe_fork() {
    local phrase=$(Bisu::trim "$1")
    Bisu::string_to_array "$phrase" "phrase"
    Bisu::array_shift "phrase" "cmd"
    local args=$(Bisu::trim "$(printf '%s ' "${phrase[@]}")")
    phrase="$(printf '%s ' "${cmd} ${args}")"

    Bisu::is_executable "$cmd" || {
        printf ''
        return 1
    }

    local async=$(Bisu::trim "$2")
    Bisu::in_array "$async" "true" "false" || async="true"

    local logging=$(Bisu::trim "$3")
    Bisu::in_array "$logging" "true" "false" || logging="true"

    local max_forks="$BISU_SAFE_FORK_LIMIT"
    Bisu::is_posi_int "$max_forks" || max_forks=16

    local processes_count=$(Bisu::processes_count "$phrase")
    if [ "$processes_count" -ge "$max_forks" ]; then
        printf ''
        exit
    fi

    if Bisu::is_func "$cmd"; then
        {
            if Bisu::debug_mode_on; then
                exec 0</dev/tty 1>/dev/tty 2>/dev/tty
            else
                exec 0</dev/tty 1>/dev/tty 2>/dev/null
            fi

            if [[ "$logging" == "true" ]]; then
                eval "$(printf '%s' "$phrase")" | tee -a -- "$(Bisu::current_log_file)" || {
                    printf ''
                    return 1
                }
            else
                eval "$(printf '%s' "$phrase")" || {
                    printf ''
                    return 1
                }
            fi
        } &
    elif Bisu::command_exists "$cmd"; then
        {
            if Bisu::debug_mode_on; then
                exec 0</dev/tty 1>/dev/tty 2>/dev/tty
            else
                exec 0</dev/tty 1>/dev/tty 2>/dev/null
            fi

            if [[ "$logging" == "true" ]]; then
                bash -c "$(printf '%s' "$phrase")" | tee -a -- "$(Bisu::current_log_file)" || {
                    printf ''
                    return 1
                }
            else
                bash -c "$(printf '%s' "$phrase")" || {
                    printf ''
                    return 1
                }
            fi
        } &
    fi
    local pid=$!
    Bisu::is_posi_int "$pid" || {
        printf ''
        return 1
    }
    disown "$pid"

    if [[ "$async" == "false" ]]; then
        wait "$pid"
        local status=$?
        [ "$status" -eq 0 ] || {
            printf ''
            return 1
        }
    fi

    printf '%s' "$pid"
    return 0
}

# Function: Bisu::continuous_exec
Bisu::continuous_exec() {
    local phrase=$(Bisu::trim "$1")
    local sleep_time=$(Bisu::trim "$2")
    local timeout=$(Bisu::trim "$3")
    local max_retries=$(Bisu::trim "$4")
    local op_name=$(Bisu::trim "$5")

    # while preparation
    Bisu::is_posi_numeric "$sleep_time" || sleep_time=3
    if [[ "$timeout" != "-1" ]] && ! Bisu::is_posi_int "$timeout"; then
        timeout=15
    fi
    if [[ "$max_retries" != "-1" ]] && ! Bisu::is_posi_int "$max_retries"; then
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
            elapsed=$(Bisu::normalize_number "$elapsed")
            Bisu::is_posi_int "$elapsed" || elapsed=0

            if [ "$elapsed" -ge "$timeout" ]; then
                over_retry="true"
                break
            fi
        fi

        [ -n "$op_name" ] && [ "$count" -gt 0 ] && {
            Bisu::error_log "The operation [${op_name}] has been failed. Attempting retry ${count}..." "⚠️"
        }

        pid=$(Bisu::safe_fork "$phrase") || return 1
        count=$((count + 1))

        while Bisu::process_is_running "$pid"; do
            if [[ "$check_over_retry_needed" == "false" ]]; then
                break
            fi

            if [[ "$over_retry" == "true" ]]; then
                break
            fi

            sleep $sleep_time
        done

        if Bisu::hanging_process "$pid"; then
            return 0
        fi

        if [[ "$over_retry" == "true" ]]; then
            Bisu::quit 1 "$pid" "true" "true"
            break
        fi
    done
    # while end

    return 1
}

# set guard for importing act
Bisu::set_source_guard() {
    # Only install once
    if declare -F __source_guard &>/dev/null; then
        return 0
    fi

    # Global registry for loaded scripts
    declare -gA __loaded_scripts

    # Core guard implementation
    __source_guard() {
        local target="$1"
        local abs_target

        # Resolve absolute path (fallback to raw path if readlink fails)
        abs_target=$(readlink -f "$target" 2>/dev/null) || abs_target="$target"

        # Skip if already loaded
        if [[ -n "${__loaded_scripts[$abs_target]}" ]]; then
            return 0
        fi

        # Mark as loaded and perform actual source
        __loaded_scripts[$abs_target]=1
        builtin source "$target" 2>/dev/null

        return 0
    }

    # Override source and dot transparently
    source() { __source_guard "$@"; }
    .() { __source_guard "$@"; }

    return 0
}

# exit signal event
Bisu::on_signal_exit() {
    local exit_code=$?
    Bisu::is_nn_int "$exit_code" || exit_code=1
    Bisu::revert_title &
    disown %+ &>/dev/null

    if [[ "$BISU_LOCK_HELD" -eq 0 ]]; then
        Bisu::exit_with_commands &
        disown %+ &>/dev/null
    fi

    exit $exit_code
}

# The End Point sign of the utility
Bisu::end() {
    local action_method
    if [ -n "$BISU_CURRENT_UTIL_ACTION" ]; then
        action_method="action_${BISU_CURRENT_UTIL_ACTION}"
        action_method=$(Bisu::str_replace "$action_method" "-" "_")
    else
        action_method="action_default"
    fi

    Bisu::is_func "__initialize" && {
        __initialize $(printf '%s ' "$(Bisu::current_args)") 2>/dev/null
    }

    Bisu::is_func "$action_method" || {
        Bisu::error_exit "Unintelligible action '$BISU_CURRENT_UTIL_ACTION'; Please type 'help' for more info."
    }

    $action_method $(printf '%s ' "$(Bisu::current_args)")
    Bisu::quit
}

# check dependencies
Bisu::check_dependencies() {
    Bisu::check_bash_version
    Bisu::check_bisu_version
    Bisu::check_commands_list
}

# Set bash signals
Bisu::set_signals() {
    local util_name=$(Bisu::current_util_name)
    Bisu::log_msg "🕒 ${util_name}: Initializing..." "true"
    trap 'wait' SIGCHLD
    trap 'Bisu::on_signal_exit' EXIT SIGINT SIGTERM SIGHUP SIGQUIT
}

# Start autorun list
Bisu::autorun_start() {
    if ! Bisu::is_array "BISU_AUTORUN"; then
        Bisu::error_exit "Invalid BISU_AUTORUN array."
    fi

    Bisu::set_signals

    if Bisu::atomic_mutex_lock; then
        Bisu::acquire_lock
        Bisu::array_unique_push "BISU_EXIT_WITH_COMMANDS" '\"Bisu::release_lock\"'
        Bisu::log_msg "🔒 Lock set." "true"
    fi

    Bisu::array_is_available "BISU_AUTORUN" &&
        {
            for command in "${BISU_AUTORUN[@]}"; do
                Bisu::log_msg "🕒 Autorun command executing: $command" "true"
                {
                    Bisu::safe_fork "$(printf '%s ' "$command")" || {
                        Bisu::error_log "Last execution failure was from: $command (Initialization Task)"
                        continue
                    }
                } &
                disown %+ &>/dev/null

                Bisu::log_msg "✅ Autorun command done: $command" "true"
            done
        }

    return 0
}

# Utility elapsed time
Bisu::execution_time() {
    Bisu::is_posi_numeric "$BISU_START_TIME" || BISU_START_TIME=$(Bisu::time_ms)
    if Bisu::debug_mode_on; then
        local execution_time=$(echo "($(Bisu::time_ms) - $BISU_START_TIME)" | bc)
        local fg_color="\033[32m"
        [ $execution_time -lt 600 ] 2>/dev/null || fg_color="\033[93m"
        echo -e "${fg_color}Elapsed: ${execution_time} ms\033[0m"
    fi
}

# Function to Bisu::initialize BISU
Bisu::initialize() {
    # prepare for the start and set the prevention for reinitialization
    BISU_START_TIME=$(Bisu::time_ms)
    [ "$BISU_START_FLAG" -eq 0 ] || return 0
    Bisu::bisu_start_flag
    # order#1 set source guard
    Bisu::set_source_guard
    # order#2 register current command
    Bisu::register_current_command
    # order#3 check dependencies
    Bisu::check_dependencies
    # order#4 load required scripts
    Bisu::load_required_scripts
    # order#5 integrate operations
    Bisu::integrate_ops
}

# Execute a command when Bisu::quit
Bisu::callfunc() {
    local current_args
    Bisu::string_to_array "$(Bisu::current_args)" "current_args"
    local argc=$(Bisu::array_count "current_args")
    Bisu::is_posi_int "$argc" || {
        Bisu::error_exit "Failed to pharse args."
    }

    Bisu::array_shift "current_args" "action"
    [[ "$action" == "callfunc" ]] || Bisu::quit

    Bisu::array_shift "current_args" "func"
    [ -n "$func" ] || Bisu::error_exit "Function '' does not exist."

    Bisu::is_func "$func" || {
        func="Bisu::${func}"
        Bisu::is_func "$func" || Bisu::error_exit "Function '$func' does not exist."
    }

    local params=$(Bisu::string_join "current_args" ' ')
    local output=""
    Bisu::safe_callfunc "$func" $(printf '%s ' "$params") | {
        output=$(Bisu::trim "$(cat)")
        [ -n "$output" ] || output="(empty result)"
        printf '%b\n' "$output"
    }
}

# get the current utility's name.
Bisu::current_util_name() {
    local util_name=$(Bisu::trim "$BISU_CURRENT_UTIL_NAME")
    [ -n "$util_name" ] || util_name=$(Bisu::current_filename)
    printf '%s' "$util_name"
}

# Get the current utility's version.
Bisu::current_util_version() {
    local version
    if Bisu::is_bisu_file; then
        version="$BISU_VERSION"
    else
        version="$BISU_CURRENT_UTIL_VERSION"
    fi
    version=$(Bisu::trim "$version")

    Bisu::is_valid_version "$version" || Bisu::error_exit "Invalid version number definition for \$BISU_CURRENT_UTIL_VERSION: '$version'"
    printf '%s' "$version"
}

# Get extra info URI of the current utility.
Bisu::current_util_info_uri() {
    local doc_uri
    if Bisu::is_bisu_file; then
        doc_uri="$BISU_INFO_URI"
    else
        doc_uri="$BISU_CURRENT_UTIL_INFO_URI"
    fi
    doc_uri=$(Bisu::trim "$doc_uri")

    Bisu::is_valid_uri "$doc_uri" || printf ''
    printf '%s' "$doc_uri"
}

# Get the current utility's last release date
Bisu::last_release_date() {
    local last_release_date
    if Bisu::is_bisu_file; then
        last_release_date=$(Bisu::trim "$BISU_LAST_RELEASE_DATE")
    else
        last_release_date=$(Bisu::trim "$BISU_CURRENT_UTIL_LAST_RELEASE_DATE")
    fi
    last_release_date=$(Bisu::normalize_iso_datetime "$last_release_date")
    printf '%s' "$last_release_date"
}

# Function to check if BISU is installed
Bisu::is_installed() {
    local target_path=$(Bisu::target_path)
    Bisu::is_file "$target_path" || return 1
    return 0
}

# Check if it's currently in the target dir
Bisu::in_target_dir() {
    local current_file_path="$(Bisu::current_file_path)"
    local target_path="$(Bisu::target_path)"
    [[ "$current_file_path" == "$target_path" ]] || return 1
    return 0
}

# Integrate operations
Bisu::integrate_ops() {
    Bisu::string_to_array "$(Bisu::current_args)" "current_args"
    Bisu::extract_args "args"
    local parg1=$(Bisu::array_get "args" 1)
    local action="$parg1"
    if [ -z "$action" ]; then
        local parg1=$(Bisu::array_get "current_args" 0)
        if Bisu::string_starts_with "$parg1" "--"; then
            parg1=$(Bisu::substr "$parg1" 2)
        elif Bisu::string_starts_with "$parg1" "-"; then
            parg1=$(Bisu::substr "$parg1" 1 1)
        fi
        # recheck to ensure the param
        if [ -n "$parg1" ] && [ -n parg1=$(Bisu::array_get "args" "$parg1") ]; then
            action="$parg1"
        fi
    fi

    Bisu::in_array "$action" "install" || Bisu::verify_sig
    Bisu::set_action "$action"
    Bisu::autorun_start

    local option_force=$(Bisu::array_get "args" "f" "force")
    local option_yes=$(Bisu::array_get "args" "y" "yes")
    local option_version=$(Bisu::array_get "args" "v" "version")
    local current_file_path=$(Bisu::current_file_path)
    local current_filename=$(Bisu::current_filename)
    local target_path=$(Bisu::target_path)
    local is_matched_action="true"

    case "$BISU_CURRENT_UTIL_ACTION" in
    "v" | "version")
        local version current_util_name last_release_date
        current_util_name="$(Bisu::current_util_name)"
        version="; $current_util_name v$(Bisu::current_util_version)"
        last_release_date="$(Bisu::last_release_date)"
        [ -n "$last_release_date" ] && {
            last_release_date="$(Bisu::gdate "$last_release_date")"
            [ -n "$last_release_date" ] && version+=" released on ${last_release_date}"
        }

        Bisu::is_bisu_file || {
            version+="; using bisu framework v${BISU_VERSION}"
        }

        [ -n "$(Bisu::current_util_info_uri)" ] && {
            version+="; for more info please visit $(Bisu::current_util_info_uri)"
        }
        version=$(Bisu::substr "$version" 2)
        Bisu::output "${version}"
        ;;
    "info")
        Bisu::log_msg "For more info please visit $(Bisu::current_util_info_uri)"
        ;;
    "installed")
        printf '%s\n' "true"
        ;;
    "install")
        Bisu::in_target_dir && {
            Bisu::error_exit "Duplicated paths. Aborted."
        }

        local confirm_msg="Are you sure to install $current_filename?"
        local choice="y"
        local force="false"
        local confirmed="false"

        Bisu::in_array "$option_force" "install" "$BISU_EMPTY_EXPR" && force="true"
        Bisu::in_array "$option_yes" "install" "$BISU_EMPTY_EXPR" && confirmed="true"

        if Bisu::is_installed; then
            choice="n"
            confirm_msg="$current_filename has already been installed at: $target_path. Do you want to reinstall it?"

            if [[ "$force" == "false" ]]; then
                Bisu::error_exit "$current_filename has already been installed at: $target_path, \
                please use -f if you want to forcefully override it."
            fi
        fi

        if [[ "$confirmed" == "false" ]] && ! Bisu::confirm "$confirm_msg" "$choice"; then
            Bisu::error_exit "Aborted."
        fi

        Bisu::install_script
        ;;
    "view-log")
        Bisu::command_exists "vi" || Bisu::error_exit "Please install vi first."
        vi "$(Bisu::current_log_file)" 2>/dev/null
        ;;
    "callfunc")
        Bisu::callfunc $(printf '%s ' "$(Bisu::current_args)")
        ;;
    *)
        is_matched_action="false"
        ;;
    esac

    if [[ "$is_matched_action" == "true" ]]; then
        Bisu::quit
    fi
}

# Function: Bisu::install_script
Bisu::install_script() {
    if Bisu::is_installed; then
        Bisu::log_msg "Detected existing installation, backup will be created."
        local date_str=$(date +'%Y%m')
        local uuid=$(Bisu::uuidv4)
        local target_path=$(Bisu::target_path)
        local current_file_path=$(Bisu::current_file_path)
        local bisu_filename=$(Bisu::bisu_filename)
        local current_filename=$(Bisu::current_filename)
        local backup_dir="$(Bisu::user_backup_dir)/$date_str"
        local current_util_version="$(Bisu::exec_command "${target_path} callfunc current_util_version")"
        current_util_version=$(Bisu::strtolower "$current_util_version")
        Bisu::string_starts_with "$current_util_version" "v" || current_util_version="v$current_util_version"
        local backup_path="${backup_dir}/${current_filename}.${current_util_version}_${uuid}"
        Bisu::log_msg "Moving $target_path to path: $backup_path"
        Bisu::mkdir_p "$backup_dir"
        Bisu::move_file "$target_path" "$backup_path"
        Bisu::log_msg "Your previous installation has been backed up to: $backup_path"
    fi

    local verify_sig sig_file sig_file_target_path sig_filename
    if Bisu::is_bisu_file; then
        verify_sig="$BISU_VERIFY_SIG"
    else
        verify_sig="$BISU_CURRENT_UTIL_VERIFY_SIG"
    fi

    Bisu::normalize_bool "verify_sig" "false"
    if [[ "$verify_sig" == "true" ]]; then
        sig_file="${current_file_path}.asc"
        sig_filename=$(basename "$sig_file")
        sig_file_target_path="${target_path}.asc"
        if ! Bisu::is_file "$sig_file"; then
            local sig_file_url
            if Bisu::is_bisu_file; then
                sig_file_url=$(Bisu::trim "$BISU_ASC_FILE_URL")
            else
                sig_file_url=$(Bisu::trim "$BISU_CURRENT_UTIL_ASC_FILE_URL")
            fi

            if Bisu::is_valid_url "$sig_file_url"; then
                CURL_RETRIES=5
                CURL_RETRY_DELAY=3
                local status_code=$(Bisu::reliable_curl "$sig_file_url" "./${sig_file}")
                [[ "$status_code" == "200" ]] || Bisu::error_exit "Failed to install $current_filename"
            fi
        fi
    fi

    if [[ "$verify_sig" == "true" ]]; then
        Bisu::is_file "$sig_file" || Bisu::error_exit "Failed to install $current_filename"
        Bisu::verify_sig
        Bisu::log_msg "Moving $sig_filename to path: $sig_file_target_path"
        Bisu::move_file "$sig_file" "$sig_file_target_path" || Bisu::error_exit "Failed to install ${current_filename}[2], please check for permissions."
    fi
    Bisu::log_msg "Moving $current_filename to path: $target_path"
    Bisu::move_file "$current_file_path" "$target_path" || Bisu::error_exit "Failed to install ${current_filename}[1], please check for permissions."
    Bisu::log_msg "Done."
}

# Initialization
Bisu::initialize
########################################################################### BISU_END ###########################################################################
