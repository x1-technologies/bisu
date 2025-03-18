#!/bin/bash
############################################### BISU_START: Bash Internal Simple Utils ###############################################
## Official Web Site: https://bisu.x-1.tech
## Recommended BISU PATH: /usr/local/sbin/bisu.bash
## Have a fresh installation for BISU with copy and paste the command below
## sudo curl -sL https://go2.vip/bisu-file -o ./bisu.bash && sudo chmod 755 ./bisu.bash && sudo ./bisu.bash -f install
# Define BISU VERSION
export BISU_VERSION="5.6.0"
# Minimal Bash Version
export MINIMAL_BASH_VERSION="5.0.0"
export _ASSOC_KEYS=()   # Core array for the common associative array keys, no modification
export _ASSOC_VALUES=() # Core array for the common associative array values, no modification
export PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
export PS4='+${BASH_SOURCE}:${LINENO}:${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
export AUTORUN=(
    'trap "wait" SIGCHLD'
    'trap "set_title \"$DEFAULT_TITLE\"" EXIT'
    'acquire_lock'
    'trap "cleanup" EXIT INT TERM HUP'
)
export HOME=$(eval echo ~${SUDO_USER:-$USER})
# BISU path
export BISU_FILE_PATH="${BASH_SOURCE[0]}"
# Default title
export DEFAULT_TITLE="-bash"
# Auto line-break length
export LINE_BREAK_LENGTH=160
# Required files
export REQUIRED_SCRIPT_FILES=()
# Required external commands list
export BISU_REQUIRED_EXTERNAL_COMMANDS=('getopt' 'awk' 'xxd' 'bc' 'uuidgen' 'md5sum' 'tee')
# Required external commands list
export REQUIRED_EXTERNAL_COMMANDS=()
# Exit with commands
export EXIT_WITH_COMMANDS=()
# Current Process ID
export CURRENT_PID=""
# Processes pids to cleanup
export EXIT_ROCESSES_PIDS=()
# Global Variables
export ROOT_LOCK_FILE_DIR="/var/run"
export USER_LOCK_FILE_DIR="$HOME/.local/var/run"
export LOCK_FILE_DIR="/tmp"
export LOCK_ID=""
export LOCK_FILE=""
export CURRENT_LOG_FILE_DIR=""                  # Current Log file dir
export ROOT_LOG_FILE_DIR="/var/log"             # Root Log file dir
export USER_LOG_FILE_DIR="$HOME/.local/var/log" # User Log file dir
export TARGET_PATH_PREFIX="/usr/local/sbin"     # Default target path for moving scripts
export PROMPT_COMMAND="set_title"
# The current file path
export CURRENT_FILE_PATH=""
# The current file name
export CURRENT_FILE_NAME=""
# The current command by the actual script
export CURRENT_COMMAND=""
# The current args by the actual script
export CURRENT_ARGS=()
# Specific Empty Expression
export EMPTY_EXPR="0x00"
# Debug Switch
export DEBUG_MODE="false"

# Universal function to trim whitespace
trim() {
    echo "$1" | awk '{$1=$1}1'
}

# BISU file path
bisu_file() {
    echo "$BISU_FILE_PATH"
}

# BISU file name
bisu_filename() {
    echo $(basename $(bisu_file))
}

# Function: output a message
output() {
    local message="$1"
    local use_newline=$(trim "$2")
    use_newline=${use_newline:-"true"}
    local redirect_stdout=$(trim "$3")
    redirect_stdout=${redirect_stdout:-"true"}

    use_newline=${use_newline:-"true"}
    if [[ "$use_newline" == "true" ]]; then
        echo -e "$message" | fold -s -w $LINE_BREAK_LENGTH >&2 || return 1
    else
        echo -en "$message" | fold -s -w $LINE_BREAK_LENGTH >&2 || return 1
    fi

    return 0
}

# Function to check if a command is existent
command_exists() {
    local command=$(trim "$1")
    if [[ -z "$command" ]]; then
        return 0
    fi
    if ! command -v "$command" &>/dev/null; then
        return 1
    fi
    return 0
}

# Quit the current command with a protocol-based signal
quit() {
    eval "kill -TERM \"$CURRENT_PID\" &" &>/dev/null
}

# Quit the specified process with a protocol-based signal
quit_process() {
    local pid=$(trim "$1")
    [[ -n "$pid" ]] || return 1
    is_posi_int "$pid" || return 1
    eval "kill -TERM \"$pid\" &" &>/dev/null
}

# Dump
dump() {
    local msg=$(trim "$1")
    local use_newline=$(trim "$2")
    use_newline=${use_newline:-"true"}

    output "$msg" "$use_newline" "true"
    quit
}

# Function: current_command
# Description: According to its naming
current_command() {
    if [[ -z "$CURRENT_COMMAND" ]]; then
        output "Invalid current command"
        quit
    fi

    echo "$CURRENT_COMMAND"
}

# Function: current_args
# Description: According to its naming
current_args() {
    echo "$CURRENT_ARGS"
}

# Function: current_file
# Description: According to its naming
current_file() {
    if [[ -z $CURRENT_FILE_PATH ]] || ! is_file "$CURRENT_FILE_PATH"; then
        output "Invalid current file path: $CURRENT_FILE_PATH"
        quit
    fi

    echo "$CURRENT_FILE_PATH"
}

# Function: current_filename
# Description: According to its naming
current_filename() {
    if [[ -z $CURRENT_FILE_NAME ]]; then
        output "Invalid current file name"
        quit
    fi
    echo "$CURRENT_FILE_NAME"
}

# Function: current_dir
# Description: According to its naming
current_dir() {
    echo $(dirname $(current_file)) || {
        output "Invalid current file path: $CURRENT_FILE_PATH"
        quit
    }
}

# The current log file
current_log_file() {
    local log_file_dir=""
    local log_file=""
    local filename=$(current_filename)

    [ -n "$filename" ] || {
        output "Invalid log file path."
        quit
    }

    if [[ -z "$CURRENT_LOG_FILE_DIR" ]]; then
        if is_root_user; then
            log_file_dir="$ROOT_LOG_FILE_DIR"
        else
            log_file_dir="$USER_LOG_FILE_DIR"
        fi

        [ -n "$log_file_dir" ] || {
            log_file_dir="$HOME/.local/var/run"
        }

        CURRENT_LOG_FILE_DIR="$log_file_dir"
    fi

    log_file_dir="$CURRENT_LOG_FILE_DIR"

    local date_str=$(date +'%Y%m%d')
    is_valid_datetime "$date_str" "date" || {
        output "Failed to get date for log directory"
        quit
    }
    local month_str="$date_str" | awk '{print substr($0, 1, 6)}'
    log_file_dir="$log_file_dir/$filename/$month_str"
    log_file="$log_file_dir/$date_str.log"

    if [[ ! -d "$log_file_dir" ]]; then
        mkdir -p "$log_file_dir" &>/dev/null || {
            output "Failed to create or set permissions for $log_file_dir"
            quit
        }
        chmod -R 755 "$log_file_dir" &>/dev/null || {
            output "Failed to create or set permissions for $log_file_dir"
            quit
        }
    fi

    touch "$log_file" || {
        output "Failed to create log file $log_file"
        quit
    }

    if [ ! -f "$log_file" ]; then
        output "Failed to create log file $log_file"
        quit
    fi

    echo "$log_file"
}

# Function: log_message
# Description: Logs messages with timestamps to a specified log file, with fallback options.
log_message() {
    local msg="$1"
    local use_newline=$(trim "$2")
    use_newline=${use_newline:-"true"}
    local log_only=$(trim "$3")
    log_only=${log_only:-"false"}

    local log_file=$(current_log_file)
    local log_dir=$(dirname "$log_file")

    # Log the message with a timestamp to the log file and optionally to stderr
    if [[ "$log_only" == "true" ]]; then
        # Log to both log file and stderr
        output "$(date +'%Y-%m-%d %H:%M:%S') - $msg" "$use_newline" "false" | tee -a "$log_file" &>/dev/null || return 1
    else
        # Log to the log file only
        output "$(date +'%Y-%m-%d %H:%M:%S') - $msg" "$use_newline" "false" | tee -a "$log_file" >&2 || return 1
    fi

    return 0
}

# Function to handle errors
error_exit() {
    local msg=$(trim "$1")
    local use_newline=$(trim "$2")
    use_newline=${use_newline:-"true"}
    local log_only=$(trim "$3")
    log_only=${log_only:-"false"}

    log_message "Error:( $msg" "$use_newline" "$log_only"
    quit
}

# The current file's run lock by signed md5 of full path
current_lock_file() {
    if [[ -z "$LOCK_ID" ]]; then
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
            error_exit "Lock file creation failed."
        fi

        if string_ends_with "$lock_file_dir" "/"; then
            lock_file_dir=$(substr "$lock_file_dir" -1)
        fi

        LOCK_FILE_DIR="$lock_file_dir"
        LOCK_ID=$(md5_sign "$(current_command)")
        LOCK_FILE="$LOCK_FILE_DIR/$(current_filename)_$LOCK_ID.lock" || {
            error_exit "Failed to set LOCK_FILE."
        }
    fi

    if [[ -z "$LOCK_ID" ]]; then
        error_exit "Could not set LOCK_ID."
    fi

    echo "$LOCK_FILE"
}

# Function: target_path
# Description: According to its naming
target_path() {
    local target_path="$TARGET_PATH_PREFIX"
    if [ -n "$(current_file)" ]; then
        local current_file=$(current_file)
    else
        local current_file=$(bisu_file)
    fi
    target_path="$target_path/$(current_filename)"
    target_path=$(file_real_path "$target_path")
    echo "$target_path"
}

# Function: strtolower
# Description: According to its naming
strtolower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Function: strtoupper
# Description: According to its naming
strtoupper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Function: substr
# Description: According to its naming
substr() {
    local string="$1"
    local offset="$2"
    local length="${3:-${#string}}"

    if ((offset < 0)); then
        offset=$((${#string} + offset))
    fi

    if ((offset < 0 || offset >= ${#string})); then
        echo ""
        return
    fi

    if ((length < 0)); then
        length=$((${#string} - offset + length))
    fi

    echo "${string:offset:length}"
}

# Description: Normalise a string
normalise_string() {
    # Ensure input is not empty
    if [ -z "$1" ]; then
        echo ""
        return 1
    fi

    # Process input using `while IFS` and `awk` for robustness
    while IFS= read -r input_string; do
        # POSIX compliant 'awk' to remove leading/trailing spaces and quotes
        normalised=$(echo "$input_string" | awk '
            {
                # Trim leading and trailing whitespace
                gsub(/^[ \t]+|[ \t]+$/, "", $0);
                
                # Remove leading and trailing quotes (both single and double)
                gsub(/^["'\''"]|["'\''"]$/, "", $0);
                
                # Replace multiple spaces/tabs with a single space
                gsub(/[ \t]+/, " ", $0);
                
                print $0;  # Return the normalised string
            }
        ')

        # If the normalised string is empty, return empty
        if [ -z "$normalised" ]; then
            echo ""
            return 1
        fi

        # Output the normalised string
        echo "$normalised"
    done <<<"$1" || {
        echo ""
        return 1
    }

    return 0
}

# Function: md5_sign
# Description: According to its naming
md5_sign() {
    echo $(trim "$1") | md5sum | awk '{print $1}'
}

# PHP-like function as its naming
strpos() {
    local string=$(trim "$1")
    local phrase=$(trim "$2")

    # Check for encoding failure
    if ! printf '%s' "$string" | awk '1' >/dev/null 2>&1 ||
        ! printf '%s' "$phrase" | awk '1' >/dev/null 2>&1; then
        echo "false"
        return 1
    fi

    # Check if string or phrase is empty
    if [ -z "$string" ] || [ -z "$phrase" ]; then
        echo "false"
        return 1
    fi

    # Use awk to find position and capture output directly
    local result
    result=$(printf '%s' "$string" | awk -v p="$phrase" '
    {
        pos = index($0, p);
        if (pos > 0) print pos - 1;  # 0-based index
        else print "";
    }' 2>/dev/null)

    # Immediate return based on result
    if [ -z "$result" ]; then
        echo "false"
        return 1
    fi

    printf '%s' "$result"
    return 0
}

# PHP-like function as its naming
stripos() {
    local string=$(trim "$1")
    local phrase=$(trim "$2")

    # Check for encoding failure
    if ! printf '%s' "$string" | awk '1' >/dev/null 2>&1 ||
        ! printf '%s' "$phrase" | awk '1' >/dev/null 2>&1; then
        echo "false"
        return 1
    fi

    # Check if string or phrase is empty
    if [ -z "$string" ] || [ -z "$phrase" ]; then
        echo "false"
        return 1
    fi

    # Use awk to find position and capture output directly
    local result
    result=$(printf '%s' "$string" | awk -v p="$phrase" '
    {
        s = tolower($0);
        p = tolower(p);
        pos = index(s, p);
        if (pos > 0) print pos - 1;  # 0-based index
        else print "";
    }' 2>/dev/null)

    # Immediate return based on result
    if [ -z "$result" ]; then
        echo "false"
        return 1
    fi

    printf '%s' "$result"
    return 0
}

# PHP-like function as its naming
strrpos() {
    local string phrase result last_pos temp_pos
    string=$(trim "$1")
    phrase=$(trim "$2")

    # Encoding failure check
    if ! printf '%s' "$string" | awk '1' >/dev/null 2>&1 ||
        ! printf '%s' "$phrase" | awk '1' >/dev/null 2>&1; then
        echo "false"
        return 1
    fi

    # Check if either string or phrase is empty
    if [ -z "$string" ] || [ -z "$phrase" ]; then
        echo "false"
        return 1
    fi

    last_pos=-1 # Default to -1 (not found)

    # Use awk with IFS while loop for best efficiency
    while IFS= read -r -n1 char; do
        result+="$char"
        temp_pos=$(printf '%s' "$result" | awk -v p="$phrase" '
        {
            pos = index($0, p);
            if (pos > 0) print pos - 1;
            else print -1;
        }' 2>/dev/null)

        if [ "$temp_pos" -ge 0 ]; then
            last_pos=$temp_pos
        fi
    done < <(printf '%s' "$string")

    if [ "$last_pos" -lt 0 ]; then
        echo "false"
        return 1
    fi

    printf '%s' "$last_pos"
    return 0
}

# PHP-like function as its naming
strrippos() {
    local string phrase result last_pos temp_pos
    string=$(trim "$1")
    phrase=$(trim "$2")

    # Encoding failure check
    if ! printf '%s' "$string" | awk '1' >/dev/null 2>&1 ||
        ! printf '%s' "$phrase" | awk '1' >/dev/null 2>&1; then
        echo "false"
        return 1
    fi

    # Check if either string or phrase is empty
    if [ -z "$string" ] || [ -z "$phrase" ]; then
        echo "false"
        return 1
    fi

    last_pos=-1 # Default to -1 (not found)

    # Use awk with IFS while loop for best efficiency (case-insensitive)
    while IFS= read -r -n1 char; do
        result+="$char"
        temp_pos=$(printf '%s' "$result" | awk -v p="$phrase" '
        {
            s = tolower($0);
            p = tolower(p);
            pos = index(s, p);
            if (pos > 0) print pos - 1;
            else print -1;
        }' 2>/dev/null)

        if [ "$temp_pos" -ge 0 ]; then
            last_pos=$temp_pos
        fi
    done < <(printf '%s' "$string")

    if [ "$last_pos" -lt 0 ]; then
        echo "false"
        return 1
    fi

    printf '%s' "$last_pos"
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
        length=${#input}
    fi

    # Validate length is non-negative (should always be true, but for robustness)
    if [ "$length" -lt 0 ] 2>/dev/null; then
        echo "0"
        return 1
    fi

    # Output length or empty string on failure
    echo "$length"
    return 0
}

# PHP-like function as its naming
strstr() {
    local haystack="$1"
    local needle="$2"
    local result=""

    # Check if inputs are provided and valid
    if [ -z "$needle" ]; then
        echo "false"
        return 1
    fi

    # If haystack is empty and needle is non-empty, no match possible
    if [ -z "$haystack" ]; then
        echo "false"
        return 1
    fi

    # Use awk to find the substring, POSIX-compliant and robust
    result=$(printf '%s\n' "$haystack" | awk -v needle="$needle" '
        {
            pos = index($0, needle)
            if (pos > 0) {
                print substr($0, pos)
            }
        }
    ')

    # If no match found, result will be empty
    if [ -z "$result" ]; then
        echo "false"
        return 1
    fi

    # Output the result
    echo "$result"
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
        echo "false"
        return 1
    fi

    # If haystack is empty and needle is non-empty, no match possible
    if [ -z "$haystack" ]; then
        echo "false"
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
    ')

    # If no match found, result will be empty
    if [ -z "$result" ]; then
        echo "false"
        return 1
    fi

    # Output the result
    echo "$result"
    return 0
}

# Check string start with
string_starts_with() {
    local string=$1
    local phrase=$2
    local ignore_case=$(trim "$3")
    ignore_case=${ignore_case:-"true"}
    local pos=""

    if [ "$ignore_case" = "true" ]; then
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
    local input_string=$1
    local end_string=$2

    # Ensure input_string is not empty and end_string is not longer than input_string
    if [[ -z "$input_string" || -n "$end_string" && ${#end_string} -gt ${#input_string} ]]; then
        return 1
    fi

    # Use pattern matching like string_starts_with
    if [[ "$input_string" != *"$end_string" ]]; then
        return 1
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

# Execute command
exec_command() {
    local command=$(trim "$1")
    local output=$(trim "$2")
    output=${output:-true}

    if [[ -z "$command" ]]; then
        return 1
    fi

    if [[ "$DEBUG_MODE" == "true" ]]; then
        log_message "*** Using Debug Mode ***"
        log_message "* Raw Command: $command"
    else
        # Execute SSH command
        if [[ "$output" == "true" ]]; then
            eval "$command" 2>/dev/null || {
                error_exit "Failed to execute command: $command"
            }
        else
            eval "$command" &>/dev/null >&2 || {
                error_exit "Failed to execute command: $command"
            }
        fi
    fi

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

    while true; do
        log_message "$message" "false"
        read -r -p " $prompt " response

        # If user just presses Enter, use default
        response=$(trim "$response")
        if [ -z "$response" ]; then
            response="$default"
        fi

        case "$response" in
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
    check_base_existence=${check_base_existence:-false}

    # Expand shell variables and tilde (~) safely
    file=$(eval echo "$file")
    file=$(echo "$file" | awk '{gsub(/^~/, ENVIRON["HOME"]); print $0}')

    # Convert relative paths to absolute paths
    case "$file" in
    /*) : ;;                                              # Already absolute
    .) file="$(pwd)" ;;                                   # Convert "." to PWD
    ..) file="$(cd .. && pwd)" ;;                         # Convert ".." to absolute path
    ./*) file="$(pwd)/${file#./}" ;;                      # Handle "./file"
    ../*) file="$(cd "${file%/*}" && pwd)/${file##*/}" ;; # Handle "../file"
    *) file="$(pwd)/$file" ;;                             # Convert other relative paths
    esac

    # Normalise redundant slashes and remove `./` safely using POSIX awk
    file=$(echo "$file" | awk '{gsub(/\/+/, "/"); gsub(/\/\.$/, ""); gsub(/\/\.\//, "/"); print $0}')

    # Remove trailing slashes (except root "/") and spaces
    file=$(echo "$file" | awk '{
        if (length($0) > 1) gsub(/\/+$/, ""); 
        gsub(/ *$/, ""); 
        print $0
    }')

    # Ensure the root path is handled correctly, i.e., "/" should not be turned into ""
    if [ "$file" = "/" ]; then
        file="/"
    fi

    # If `check_base_existence` is true, verify the file or directory exists
    if [ "$check_base_existence" = "true" ]; then
        [ -e "$file" ] && echo "$file" || echo ""
    else
        echo "$file"
    fi
}

# Function: add_env_path
# Description: To robustly add new path to append
add_env_path() {
    local new_path=$(trim "$1")

    # Check if the argument is provided
    if [ -z "$new_path" ]; then
        log_message "No path provided to append."
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

# Check if it's numeric
is_numeric() {
    local num=$(trim "$1")
    # Check for no/empty input
    [ -n "$1" ] || return 1

    # Validate numeric format using awk
    printf '%s\n' "$num" | awk '
        BEGIN { status = 1 }
        # Match: optional minus, digits, optional decimal with digits
        # No leading zeros unless followed by decimal or zero itself
        /^-?0$|^-?[1-9][0-9]*$|^-?0\.[0-9]+$|^-?[1-9][0-9]*\.[0-9]+$/ { status = 0 }
        END { exit status }
    ' || return 1

    # Success - print the number
    printf '%s' "$num"
    return 0
}

# positive numeric validator
is_posi_numeric() {
    local num=$(trim "$1")
    # Check for no/empty input
    [ -n "$1" ] || return 1

    # Validate positive numeric format using awk
    printf '%s' "$num" | awk '
        BEGIN { status = 1 }
        # Match: digits, optional decimal with digits
        # No leading zeros unless followed by decimal or zero itself
        /^0$|^[1-9][0-9]*$|^0\.[0-9]+$|^[1-9][0-9]*\.[0-9]+$/ { status = 0 }
        END { exit status }
    ' || return 1

    # Success - print the number
    printf '%s' "$num"
    return 0
}

# negative numeric validator
is_nega_numeric() {
    local num=$(trim "$1")
    # Check for no/empty input
    [ -n "$1" ] || return 1

    # Validate negative numeric format using awk
    printf '%s' "$num" | awk '
        BEGIN { status = 1 }
        # Match: minus sign, digits, optional decimal with digits
        # No leading zeros after minus unless followed by decimal
        /^-[1-9][0-9]*$|^-[1-9][0-9]*\.[0-9]+$/ { status = 0 }
        END { exit status }
    ' || return 1

    # Success - print the number
    printf '%s' "$num"
    return 0
}

# Check if it's int
is_int() {
    local num=$(trim "$1")
    # Check for no/empty input
    [ -n "$1" ] || return 1

    # Validate integer format using awk
    printf '%s\n' "$num" | awk '
        BEGIN { status = 1 }
        # Match optional minus sign followed by digits, no leading zeros unless zero itself
        /^-?0$|^-?[1-9][0-9]*$/ { status = 0 }
        END { exit status }
    ' || return 1

    return 0
}

# positive int validator
is_posi_int() {
    local num=$(trim "$1")
    # Check for no/empty input
    [ -n "$1" ] || return 1

    # Validate unsigned integer format using awk
    printf '%s' "$num" | awk '
        BEGIN { status = 1 }
        # Match digits, no leading zeros unless zero itself
        /^0$|^[1-9][0-9]*$/ { status = 0 }
        END { exit status }
    ' || return 1

    return 0
}

# negative int validator
is_nega_int() {
    local num=$(trim "$1")
    # Check for no/empty input
    [ -n "$1" ] || return 1

    # Validate negative integer format using awk
    printf '%s' "$num" | awk '
        BEGIN { status = 1 }
        # Match minus sign followed by digits, no leading zeros
        /^-[1-9][0-9]*$/ { status = 0 }
        END { exit status }
    ' || return 1

    # Success - print the number
    printf '%s' "$num"
    return 0
}

# positive int validator
is_unsigned_int() {
    ! is_posi_int "$1" && return 1
    return 0
}

# Function: is_file
# Description: According to its naming
is_file() {
    local filepath=$(trim "$1")
    [[ -z "$filepath" || ! -f "$filepath" ]] && return 1 || return 0
}

# Function: is_dir
# Description: According to its naming
is_dir() {
    local dirpath=$(trim "$1")
    [[ -z "$dirpath" || ! -d "$dirpath" ]] && return 1 || return 0
}

# Function: file_exists
# Description: According to its naming
file_exists() {
    local filepath=$(trim "$1")
    if ! (is_file "$filepath" || is_dir "$filepath"); then
        return 1
    fi
    return 0
}

# Get file's extension
fileext() {
    # Ensure the input is a valid filename
    local filename="$1"

    # Check if the filename is empty
    if [ -z "$filename" ]; then
        echo ""
        return 1
    fi

    # Extract the file extension using POSIX awk
    local ext
    ext=$(echo "$filename" | awk -F. '{if (NF > 1) {print $NF}}')
    ext=$(trim "$ext")

    # Output the extension, or an empty string if no extension is found
    if [ -z "$ext" ]; then
        echo ""
    fi

    echo "$ext"
    return 0
}

# Get file info
get_file_info() {
    local file=$(trim "$1")
    file=$(file_real_path "$file")
    if [ -z "$file" ]; then
        return 1
    fi

    arr_reset || return 1

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

    arr_set_val "FILE_NAME" "$filename"
    arr_set_val "FILE_EXT" "$file_ext"
    arr_set_val "FILE_PATH" "$file_path"
    arr_set_val "FILE_DIR" "$file_dir"
    arr_set_val "FILE_EXISTS" "$file_exists"
    arr_set_val "FILE_IS_DIR" "$file_is_dir"
    arr_set_val "FILE_IS_FILE" "$file_is_file"
    arr_set_val "FILE_HAS_EXT" "$file_has_ext"

    return 0
}

# mkdir_p
mkdir_p() {
    local dir=$(trim "$1")
    dir=$(file_real_path "$dir")

    # Check if the directory exists, if not, create it
    if ! file_exists "$dir"; then
        exec_command "mkdir -p \"$dir\"" || {
            log_message "Failed to mkdir: $dir"
            return 1
        }
        exec_command "chmod -R 755 \"$dir\"" || {
            log_message "Failed to change permissions for $dir"
            return 1
        }
    fi

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
    force_override=${force_override:-"true"}

    # Check if the source_path exists
    if [[ ! -e "$source_path" ]]; then
        log_message "Source $source_path does not exist."
        return 1
    fi

    get_file_info "$target_path"
    local filename=$(arr_get_val "FILE_NAME")
    local file_path=$(arr_get_val "FILE_PATH")
    local file_ext=$(arr_get_val "FILE_EXT")
    local file_dir=$(arr_get_val "FILE_DIR")
    local file_exists=$(arr_get_val "FILE_EXISTS")
    local file_is_dir=$(arr_get_val "FILE_IS_DIR")
    local file_is_file=$(arr_get_val "FILE_IS_FILE")
    local file_has_ext=$(arr_get_val "FILE_HAS_EXT")

    target_path="$file_path"
    target_dir="$file_dir"

    if [[ "$force_override" == "false" ]] && [[ -e "$target_path" ]]; then
        return 1
    fi

    mkdir_p "$target_dir"
    exec_command "mv \"$source_path\" \"$target_path\""

    # Check if the move was successful
    if [[ $? != 0 ]]; then
        log_message "Failed to move file $source_path to $target_path"
        return 1
    fi

    return 0
}

# Function to check if a variable is an array
is_array() {
    local array_name=$(trim "$1")

    if ! declare -p "$array_name" 2>/dev/null | grep -q 'declare -a'; then
        return 1
    fi

    return 0
}

# Function to check if an array is available
array_is_available() {
    local array_name=$(trim "$1")

    is_array "$array_name" || return 1

    [ -n "${array_name[*]}" ] || return 1

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
    printf "%s\n" "$@" | awk -v needle="$needle" '
        BEGIN { found = 0 }
        $0 == needle { found = 1; exit }
        END { exit found ? 0 : 1 }
    ' || return 1

    return $?
}

# Array values as string
array_copy() {
    local array_name=$(trim "$1")
    local var_name=$(trim "$2")

    if ! is_array "$array_name" || ! is_valid_var_name "$var_name"; then
        return 1
    fi

    eval "$var_name=(\"\${$array_name[@]}\")" || return 1

    return 0
}

# Function to add an element to a specified global array
array_unique_push() {
    local array_name=$1
    local new_value=$2
    local value_type=${3:-STRING} # Default to STRING if not provided

    # Validate the type parameter and input value
    case "$value_type" in
    INT)
        if ! [[ "$new_value" =~ ^-?[0-9]+$ ]]; then
            log_message "Value must be an integer."
            return 1
        fi
        ;;
    FLOAT)
        if ! [[ "$new_value" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
            log_message "Value must be a float."
            return 1
        fi
        ;;
    STRING)
        # No specific validation for STRING
        ;;
    *)
        log_message "Invalid type specified. Use STRING, INT, or FLOAT."
        return 1
        ;;
    esac

    # Ensure the global array exists
    if ! is_array "$array_name"; then
        log_message "Array $array_name does not exist."
        return 1
    fi

    # Access the global array using indirect reference
    eval "array=(\"\${$array_name[@]}\")"

    # Function to check if item exists in an array
    item_exists() {
        local item=$1
        shift
        local element
        for element in "$@"; do
            if [[ "$element" == "$item" ]]; then
                return 0
            fi
        done
        return 1
    }

    # Check if the value is already in the array
    if item_exists "$new_value" "${array[@]}"; then
        log_message "Item already exists in array."
        return 1
    fi

    # Append the new value to the array
    # Using indirect reference to modify the global array
    eval "$array_name+=(\"$new_value\")"

    return 0
}

# Function: array_merge
# Description: Function to merge 2 global arrays
array_merge() {
    local array1="$1" array2="$2" result="$3"
    if [[ $# -ne 3 ]] || ! is_array "$array1" || ! is_array "$array2" || ! is_array "$array3"; then
        log_message "Requires exactly three arguments (two array names and one result name)."
        return 1
    fi

    # Initialize result array as empty
    eval "$result=()"

    # Add unique elements from array1 and array2
    for array in "$array1" "$array2"; do
        eval "for item in \${$array[@]}; do
        [[ ! \${result[@]} =~ \"\$item\" ]] && result+=(\"\$item\")
    done"
    done
}

# Function: array_unique
# Description: To remove duplicates from a global array
array_unique() {
    local array_name="$1"
    if [[ $# -ne 1 ]] || ! is_array "$array_name"; then
        log_message "Requires exactly one argument (array name)."
        return 1
    fi
    eval "$array_name=($(echo \${$array_name[@]} | tr ' ' '\n' | sort -u | tr '\n' ' '))"
}

# Function to dynamically set or update a key-value pair for the common array
arr_set_val() {
    local key value found=0

    key=$(echo "$1" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print}')
    value=$(echo "$2" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print}')

    # Validate input
    [ -z "$key" ] && return # Ignore empty keys

    # Type handling (preserve numbers and booleans correctly)
    case "$value" in
    "true" | "false") ;;                                        # Keep booleans unchanged
    '' | [0-9]* | *[.][0-9]*) ;;                                # Keep numbers (integers & floats)
    *) value=$(echo "$value" | awk '{gsub(/"/, ""); print}') ;; # Strip double quotes from strings
    esac

    # Search for existing key and update if found
    for ((i = 0; i < ${#_ASSOC_KEYS[@]}; i++)); do
        if [[ "${_ASSOC_KEYS[$i]}" == "$key" ]]; then
            _ASSOC_VALUES[$i]="$value"
            found=1
            break
        fi
    done

    # Append new key-value pair if not found
    if [ "$found" -eq 0 ]; then
        _ASSOC_KEYS+=("$key")
        _ASSOC_VALUES+=("$value")
    fi
}

# Function to access elements for the common associative array and looping search for the first populated value
arr_get_val() {
    # Loop through all passed arguments
    for search_key in "$@"; do
        # Trim whitespace from the search key
        search_key=$(trim "$search_key")

        # Check if the search_key is empty
        if [[ -z "$search_key" ]]; then
            continue
        fi

        # Find matching key in the list of keys
        idx=$(printf "%s\n" "${_ASSOC_KEYS[@]}" | awk -v key="$search_key" '$0 == key {print NR; exit}')

        # If no match is found, continue to the next key
        if [[ -z "$idx" ]]; then
            continue
        fi

        # Return corresponding value from _ASSOC_VALUES
        echo "${_ASSOC_VALUES[$((idx - 1))]}"
        return 0
    done

    echo ""
    return 0
}

# Function to reset the common associative array
arr_reset() {
    # Ensure arrays exist before resetting
    if ! is_array "_ASSOC_KEYS" || ! is_array "_ASSOC_VALUES"; then
        return 1
    fi

    # Clear the keys and values arrays
    _ASSOC_KEYS=() || return 1
    _ASSOC_VALUES=() || return 1

    return 0
}

# Convert JSON array to bash array
array_to_json() {
    local array_data=$(trim "$1")
    local use_private_array=$(trim "$2")
    use_private_array=${use_private_array:-"false"}
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
        echo ""
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
        line=$(echo "$line" | awk -v arr="$array_name" '
        match($0, arr"\\[\"([^\"]+)\"\\]=\"([^\"]+)\"", m) {
            key = m[1]
            value = m[2]

            # Escape quotes in key and value
            gsub(/"/, "\\\"", key)
            gsub(/"/, "\\\"", value)

            # Return key-value pair in JSON format
            print "\"" key "\": \"" value "\""
        }
        ')

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
        echo ""
        return 1
    }

    echo "$result"
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

    # Normalise version input (strip leading 'v' or spaces)
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

        # Normalise version parts (replace '~' with '0.' and remove '^' since they're not part of the actual version)
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
            [[ -z "$s1" ]] && s1=0
            [[ -z "$s2" ]] && s2=0

            # Numeric comparison of each segment
            if [[ "$s1" =~ ^[0-9]+$ && "$s2" =~ ^[0-9]+$ ]]; then
                if ((10#$s1 > 10#$s2)); then
                    echo 1
                    return
                fi
                if ((10#$s1 < 10#$s2)); then
                    echo -1
                    return
                fi
            else
                # Compare pre-release versions (like alpha, beta)
                s1=${version_labels[$s1]:-$s1}
                s2=${version_labels[$s2]:-$s2}

                if [[ "$s1" > "$s2" ]]; then
                    echo 1
                    return
                fi
                if [[ "$s1" < "$s2" ]]; then
                    echo -1
                    return
                fi
            fi

            ((i++))
        done
        echo 0
    }

    # Perform comparison based on operator
    local cmp_result=$(compare_raw_versions "$version" "$constraint")

    case "$operator" in
    "=")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -eq 0 ] && echo 1 || echo 0
        else
            echo 0
        fi
        ;;
    "!=")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -ne 0 ] && echo 1 || echo 0
        else
            echo 0
        fi
        ;;
    "<")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -lt 0 ] && echo 1 || echo 0
        else
            echo 0
        fi
        ;;
    "<=")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -le 0 ] && echo 1 || echo 0
        else
            echo 0
        fi
        ;;
    ">")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -gt 0 ] && echo 1 || echo 0
        else
            echo 0
        fi
        ;;
    ">=")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            [ "$cmp_result" -ge 0 ] && echo 1 || echo 0
        else
            echo 0
        fi
        ;;
    "~" | "^")
        if [[ "$cmp_result" =~ ^-?[0-9]+$ ]]; then
            version_check=$(compare_raw_versions "$version" "${constraint%.*}.999")

            if [[ "$version_check" =~ ^-?[0-9]+$ ]]; then
                if [ "$cmp_result" -ge 0 ] && [ "$version_check" -le 0 ]; then
                    echo 1
                else
                    echo 0
                fi
            else
                echo 0
            fi
        else
            echo 0
        fi
        ;;
    *)
        echo 0
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
    version=$(echo "$version_string" | awk '{print $4}' | cut -d'(' -f1)

    # Ensure it has a valid format (vX.X.X)
    if [[ "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        # Prefix with 'v' to match the desired format 'vX.X.X'
        echo "v$version"
    else
        error_exit "Bash version format not recognised"
    fi
}

# Function: check_bash_version
# Description: Verifies that the installed Bash version is greater than or equal to the specified required version.
# Returns: 0 if Bash version is valid, 1 if not.
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
# Returns: 0 if Bash version is valid, 1 if not.
check_bisu_version() {
    local expr="$THIS_REQUIRED_BISU_VERSION"
    local result=$(compare_version "$expr" "$BISU_VERSION")

    if [[ $result == 0 ]] && [[ $(current_filename) != $(bisu_filename) ]]; then
        error_exit "BISU version ($BISU_VERSION) is not as the satisfactory ($THIS_REQUIRED_BISU_VERSION)."
    fi
}

# Function: is_valid_datetime
# Description: According to its naming
is_valid_datetime() {
    local input=$(trim "$1")
    local type=$(trim "$2")
    type=${type:-"datetime"}
    local year month day hour minute second

    # Extract date or timestamp
    if [[ "$type" == "date" || "$type" == "datetime" ]]; then
        # Handle year, month, day parsing
        if [[ "$input" =~ ^([0-9]{4})([0-9]{2})([0-9]{2})$ ]]; then
            # Format: YYYYMMDD
            year="${BASH_REMATCH[1]}"
            month="${BASH_REMATCH[2]}"
            day="${BASH_REMATCH[3]}"
        elif [[ "$input" =~ ^([0-9]{4})([0-9]{2})$ ]]; then
            # Format: YYYYMM
            year="${BASH_REMATCH[1]}"
            month="${BASH_REMATCH[2]}"
            day="01"
        elif [[ "$input" =~ ^([0-9]{2})([0-9]{2})$ ]]; then
            # Format: MMDD
            year=$(date +"%Y")
            month="${BASH_REMATCH[1]}"
            day="${BASH_REMATCH[2]}"
        elif [[ "$input" =~ ^([0-9]{4})-([0-9]{1,2})-([0-9]{1,2})$ ]]; then
            # Format: YYYY-MM-DD
            year="${BASH_REMATCH[1]}"
            month="${BASH_REMATCH[2]}"
            day="${BASH_REMATCH[3]}"
        elif [[ "$input" =~ ^([0-9]{1,2})-([0-9]{1,2})$ ]]; then
            # Format: MM-DD
            year=$(date +"%Y")
            month="${BASH_REMATCH[1]}"
            day="${BASH_REMATCH[2]}"
        else
            return 1
        fi
    fi

    # Validate the date's existence
    if ! validate_date "$year" "$month" "$day"; then
        return 1
    fi

    # Handle time validation if type is time or datetime
    if [[ "$type" == "time" || "$type" == "datetime" ]]; then
        if [[ "$input" =~ ^([0-9]{2}):([0-9]{2})$ ]]; then
            # Format: HH:MM
            hour="${BASH_REMATCH[1]}"
            minute="${BASH_REMATCH[2]}"
            second="00"
        elif [[ "$input" =~ ^([0-9]{1,2}):([0-9]{2})$ ]]; then
            # Format: H:MM (single digit hour)
            hour="${BASH_REMATCH[1]}"
            minute="${BASH_REMATCH[2]}"
            second="00"
        else
            return 1
        fi
    fi

    # Validate time ranges
    if ! validate_time "$hour" "$minute" "$second"; then
        return 1
    fi

    return 0
}

validate_date() {
    local year="$1"
    local month="$2"
    local day="$3"

    # Check if month and day are valid
    if ((month < 1 || month > 12)); then
        return 1
    fi

    local days_in_month
    case "$month" in
    01 | 03 | 05 | 07 | 08 | 10 | 12)
        days_in_month=31
        ;;
    04 | 06 | 09 | 11)
        days_in_month=30
        ;;
    02)
        # Check for leap year
        if ((year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))); then
            days_in_month=29
        else
            days_in_month=28
        fi
        ;;
    *)
        return 1 # Invalid month
        ;;
    esac

    if ((day < 1 || day > days_in_month)); then
        return 1
    fi

    return 0 # Valid date
}

validate_time() {
    local hour="$1"
    local minute="$2"
    local second="$3"

    # Validate hour, minute, second ranges
    if ((hour < 0 || hour > 23)); then
        return 1
    fi
    if ((minute < 0 || minute > 59)); then
        return 1
    fi
    if ((second < 0 || second > 59)); then
        return 1
    fi

    return 0 # Valid time
}

# Function to validate a variable name
is_valid_var_name() {
    local var_name=$(trim "$1")
    if [[ -z "$var_name" || ! "$var_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        return 1
    fi
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
    length=$(printf '%s' "$filename" | awk '{print length($0)}' 2>/dev/null) || {
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
        }' 2>/dev/null) || {
        return 1
    }

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
        '; then
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
        '; then
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
    echo "$input" | awk '
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
    }' || {
        return 1
    }

    # Return the result of validation
    return $?
}

# Function to convert YAML to JSON
yaml_to_json() {
    local yaml=$(trim "$1")

    [ -n "$yaml" ] || {
        echo ""
        return 1
    }

    # Convert YAML to JSON using AWK + while IFS
    echo "$yaml" | awk '
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
    ' || {
        echo ""
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
    arr_reset || return 1

    # Read the input line by line
    while IFS=':' read -r key value; do
        # Trim spaces and remove quotes from key and value using POSIX awk
        key=$(echo "$key" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); gsub(/"/, ""); gsub(/'\''/, ""); print}')
        value=$(echo "$value" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); gsub(/"/, ""); gsub(/'\''/, ""); print}')

        # Skip if the key is empty (or invalid)
        [ -z "$key" ] && continue

        # Set the key-value pair
        arr_set_val "$key" "$value" || return 1
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
    arr_reset || return 1

    # Read the input line by line
    while IFS= read -r line; do
        # Trim spaces around the line
        line=$(echo "$line" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print}')

        # Skip empty lines and braces (starting or ending JSON object)
        if [[ -z "$line" || "$line" =~ ^[\{\}]$ ]]; then
            continue
        fi

        # Handle key-value pairs
        if [[ "$line" =~ ^\"([^\"]+)\"\:\s*\"([^\"]+)\"$ ]]; then
            key="${BASH_REMATCH[1]}"
            value="${BASH_REMATCH[2]}"

            # Remove quotes from key and value using POSIX awk
            key=$(echo "$key" | awk '{gsub(/"/, ""); print}')
            value=$(echo "$value" | awk '{gsub(/"/, ""); print}')

            # Skip if the key is empty (or invalid)
            [ -z "$key" ] && continue

            # Set the key-value pair
            arr_set_val "$key" "$value" || return 1
        fi
    done <<<"$input" || return

    return 0
}

# urlencode
urlencode() {
    local str=$(trim "$1")

    [ -n "$str" ] || {
        echo ""
        return 1
    } # Empty input -> return empty string

    echo "$str" | awk '
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
    }'

    return 0
}

# Decode URL-encoded string
urldecode() {
    local str=$(trim "$1")
    [ -n "$str" ] || {
        echo ""
        return 1
    } # Return empty string if input is empty

    echo "$str" | awk '
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
    }'

    return 0
}

# Check if a URL is encoded
url_is_encoded() {
    local segment=$(trim "$1")

    [ -n "$segment" ] || {
        echo "Segment is empty"
        return 1
    } # Handle empty input safely

    # Check for correctly formatted percent-encoded sequences
    if ! echo "$segment" | awk 'BEGIN { valid=1 } /%[0-9A-Fa-f]{2}/ { if (!match($0, /%[0-9A-Fa-f]{2}/)) valid=0 } END { exit !valid }'; then
        return 1 # False, it's not encoded
    fi

    return 0 # True, it's encoded
}

# Normalise a URL and analyse its info
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
    if echo "$url" | awk -F "://" '{if (NF > 1) print $1}' | grep -q '[a-zA-Z]'; then
        # Extract scheme and remaining URL
        scheme=$(echo "$url" | awk -F "://" '{print $1}')
        remaining_url=$(echo "$url" | awk -F "://" '{print $2}')
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
        echo ""
        return 1
    fi

    # Step 4: Validate domain (basic check for alphanumeric and dots/hyphens)
    if [[ -z "$domain" || ! "$domain" =~ ^[a-zA-Z0-9.-]+$ ]]; then
        echo ""
        return 1
    fi

    # Step 5: Normalize the path (handle multiple '?' and missing root '/')
    path=$(echo "$path" | awk '{gsub(/\?/, "&"); print}')

    # If the path is empty or doesn't start with '/', add the root '/'
    if [ -z "$path" ] || ! string_starts_with "$path" "/"; then
        path="/$path"
    fi

    # Remove extra '?' in the path (only keep the first one)
    path=$(echo "$path" | awk '{if (match($0, /\?.*\?/)) sub(/\?.*/, "?"); print}')

    # Step 6: Output the normalised URL
    normalised_url="$scheme://$domain$path"
    if url_is_encoded "$path"; then
        url_is_encoded="true"
        encoded_req_path="$path"
        encoded_url="$normalised_url"
        unencoded_req_path=$(urldecode "$path")
        unencoded_url="$scheme://$domain$unencoded_req_path"
    else
        url_is_encoded="false"
        unencoded_req_path="$path"
        unencoded_url="$normalised_url"
        encoded_req_path=$(urlencode "$path")
        encoded_url="$scheme://$domain$encoded_req_path"
    fi

    arr_reset || return 1
    arr_set_val "URL_SCHEME" "$scheme"
    arr_set_val "URL_DOMAIN" "$domain"
    arr_set_val "UNENCODED_REQ_PATH" "$unencoded_req_path"
    arr_set_val "UNENCODED_URL" "$unencoded_url"
    arr_set_val "ENCODED_REQ_PATH" "$encoded_req_path"
    arr_set_val "ENCODED_URL" "$encoded_url"

    return 0
}

# Url params to json conversion
urlparams_to_json() {
    local str=$(trim "$1")
    string_starts_with "$str" "/" && {
        str=$(substr "$str" 1)
    }

    [ -n "$str" ] || {
        echo "{}"
        return 1
    } # Return empty JSON if input is empty

    echo "$str" | awk -F '&' '
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
    END { print "}" }' || {
        echo ""
        return 1
    }

    return 0
}

# Convert JSON to URL parameters
json_to_urlparams() {
    local str=$(trim "$1")
    [ -n "$str" ] || {
        echo ""
        return 1
    } # Return empty string if input is empty

    echo "$str" | awk '
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
    }' || {
        echo ""
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
    url=$(arr_get_val "ENCODED_URL")
    local unencoded_req_path=$(arr_get_val "UNENCODED_REQ_PATH")
    local unencoded_url=$(arr_get_val "UNENCODED_URL")
    local encoded_req_path=$(arr_get_val "ENCODED_REQ_PATH")
    local encoded_url=$(arr_get_val "ENCODED_URL")
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
            exec_command "curl $info_option -X GET '$url' -H '$ua' -H 'Content-Type: text/plain' -d '$url_params_json' $save_option --retry-delay $retry_interval" "false"
            ;;
        POST)
            exec_command "curl $info_option -X POST '$url' -H '$ua' -H 'Content-Type: text/plain' -d '$url_params_json' $save_option --retry-delay $retry_interval" "false"
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

# Generate a secure random UUIDv4 (128 bits)
uuidv4() {
    local uuidv4=""
    # Use /dev/urandom to generate random data and format as hex
    uuidv4=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | awk '{print tolower($0)}')
    if [[ -z $(trim "$uuidv4") ]]; then
        uuidv4=$(uuidgen | tr -d '-' | awk '{print tolower($0)}')
    fi
    echo "$uuidv4"
}

# Function to convert hex to string
hex2str() {
    local hex_string=$(trim "$1")
    echo -n "$hex_string" | tr -d '[:space:]' | xxd -r -p || echo ""
}

# Function to convert string to hex
str2hex() {
    local input_string=$(trim "$1")
    local having_space=${2:-true} # Having space as separator for standard hex
    local result=""

    result=$(echo -n "$input_string" | xxd -p | tr -d '[:space:]' || echo "")
    if $having_space && [[ -n "$result" ]]; then
        result=$(echo -n "$result" | awk '{ gsub(/(..)/, "& "); print }')
    fi
    echo "$result"
}

# Generate random string based on uuidv4
random_string() {
    local length="${1:-32}"
    local type="${2:-MIXED}"
    local max_length=1024

    # Validate length
    if ! [[ "$length" =~ ^[0-9]+$ ]] || ((length < 1)); then
        echo ""
        return
    fi

    # Ensure length does not exceed max_length
    if ((length > max_length)); then
        length=$max_length
    fi

    # Define character sets
    local charset_letters="abcdefghijklmnopqrstuvwxyz"
    local charset_numbers="0123456789"

    # Determine the character set based on type
    local charset
    case "$type" in
    LETTERS)
        charset="$charset_letters"
        ;;
    NUMBERS)
        charset="$charset_numbers"
        ;;
    MIXED)
        charset="$charset_letters$charset_numbers"
        ;;
    *)
        echo ""
        return
        ;;
    esac

    # Ensure the charset is large enough
    if ((${#charset} < length)); then
        echo ""
        return
    fi

    # Shuffle the charset to randomize character order
    local shuffled_charset
    shuffled_charset=$(echo "$charset" | fold -w1 | shuf | tr -d '\n')

    # Generate the random string without repeated characters
    echo "$shuffled_charset" | head -c "$length" || echo ""
}

# Function to check existence of external commands
check_commands_list() {
    local array_name=$(trim "$1")
    local invalid_commands_count=0
    local invalid_commands=""

    if ! array_is_available "$array_name"; then
        error_exit "Invalid array name provided."
    fi

    array_copy "$array_name" "vals"

    for val in "${vals[@]}"; do
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

# Function to clean files when exit
exit_with_commands() {
    local array_name="EXIT_WITH_COMMANDS"

    if ! array_is_available "$array_name"; then
        error_exit "Invalid array name provided."
    fi

    array_copy "$array_name" "vals"

    for val in "${vals[@]}"; do
        val=$(trim "$val")
        if [[ -n "$val" ]]; then
            exec_command "$val" &>/dev/null >&2
        fi
    done

    local current_pid="$CURRENT_PID"
    local sub_pids=$(pgrep -P "$current_pid" 2>/dev/null) || sub_pids=""
    # Check if any child PIDs are found
    if [ -n "$sub_pids" ]; then
        # Efficient loop using while IFS for processing each child PID
        while IFS= read -r pid; do
            # Ensure the PID is valid (numeric only)
            if [[ "$pid" =~ ^[0-9]+$ ]]; then
                # Safely terminate child PID with a delay
                quit_process "$pid"
                sleep 0.2
            fi
        done <<<"$sub_pids"
    fi
}

# Function to acquire a lock to prevent multiple instances
acquire_lock() {
    local lock_file=$(current_lock_file)
    [[ -n "$lock_file" ]] || error_exit "Failed to acquire lock."
    exec 200>"$lock_file"
    flock -n 200 || error_exit "An instance is running: $lock_file"
}

# Function to release the lock
release_lock() {
    local lock_file=$(current_lock_file)
    ! is_file "$lock_file" && return 1
    flock -u 200 && revert_title && rm -f "$lock_file"
}

# Trap function to handle script termination
cleanup() {
    exit_with_commands
    release_lock
    exit 0
}

# Function to set the terminal title
set_title() {
    local title=$(trim "$1")

    # Check if the title is valid (only alphanumeric and spaces for simplicity)
    if [ -n "$title" ] && echo "$title" | awk '!/[^a-zA-Z0-9 ]/' &>/dev/null; then
        # Set terminal title (in a POSIX-compliant way)
        echo -ne "\033]0;${title}\007"
    fi
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
    source "$script" || { error_exit "Failed to import script: $script"; }
}

# Automatically import required scripts
load_required_scripts() {
    array_unique "REQUIRED_SCRIPT_FILES"
    if ! is_array "REQUIRED_SCRIPT_FILES"; then
        error_exit "Invalid REQUIRED_SCRIPT_FILES array."
    fi

    for script in "${REQUIRED_SCRIPT_FILES[@]}"; do
        import_script "$script"
    done

    return 0
}

# Function to execute a command robustly
execute_command() {
    local commandString=$(trim "$1")
    eval "$commandString" || error_exit "Failed to execute command: $commandString"
}

# Execute a command when quit
exec_when_quit() {
    local command=$(trim "$1")
    array_unique_push "EXIT_WITH_COMMANDS" "$command" || {
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
    done <<<"$(echo "$input" | awk '{for(i=1;i<=NF;i++) print $i}')" || return 0

    if [ -z "$cmd" ]; then
        return 1
    fi

    arr_reset || return 1

    arr_set_val "CURRENT_COMMAND" "$cmd"
    arr_set_val "CURRENT_ARGS" "$params"

    return 0
}

# Register the current command
register_current_command() {
    CURRENT_PID="$$"
    local params=($(printf '%s ' "$@"))
    local current_file_path=""
    local current_args=""

    for param in "${params[@]}"; do
        if [[ -z "$current_file_path" ]]; then
            current_file_path="$param"
        else
            current_args="$current_args $param"
        fi
    done

    CURRENT_FILE_PATH=$(normalise_string "$current_file_path")
    CURRENT_COMMAND="$CURRENT_FILE_PATH"
    CURRENT_FILE_NAME=$(basename "$CURRENT_FILE_PATH")

    CURRENT_ARGS=$(trim "$current_args")
    [ -n "$CURRENT_ARGS" ] && {
        CURRENT_COMMAND="$CURRENT_COMMAND $CURRENT_ARGS"
    }
}

# Get args and store them in an associative array
get_args() {
    local key value param pos_index=1
    local emptyExpr="$EMPTY_EXPR" # Assign with 0x00
    local args=$(current_args)

    eval "set -- $(printf '%s ' "$args")" 2>/dev/null || return 1

    # Check if there are arguments; reset array or fail
    [ $# -gt 0 ] && arr_reset || return 1

    while [ $# -gt 0 ]; do
        param="$1"

        # Long options (e.g., --key=value)
        if [ "${param#--}" != "$param" ]; then
            key="${param#--}"

            # Check if param contains '='
            case "$param" in
            *=*)
                value="${param#*=}" # Extract value after '='
                ;;
            *)
                if [ -n "$2" ] && [ "${2#-}" = "$2" ]; then
                    value="$2" # Next arg is value if not an option
                    shift
                else
                    value="$emptyExpr" # Standalone flag gets EMPTY_EXPR
                fi
                ;;
            esac
            arr_set_val "$key" "$value"

        # Short options (e.g., -f, -abc)
        elif [ "${param#-}" != "$param" ] && [ "$param" != "-" ]; then
            key="${param#-}"

            # Handle multiple short flags (e.g., -abc)
            if [ ${#key} -gt 1 ]; then
                printf '%s\n' "$key" | while IFS= read -r opt; do
                    # Split into individual characters using awk
                    echo "$opt" | awk '{for(i=1;i<=length($0);i++)print substr($0,i,1)}' | while IFS= read -r single_opt; do
                        [ -n "$single_opt" ] && arr_set_val "$single_opt" "$emptyExpr"
                    done
                done
            else
                # Single short flag (e.g., -f value)
                if [ -n "$2" ] && [ "${2#-}" == "$2" ]; then
                    value="$2"
                    arr_set_val "$key" "$value"
                    shift
                else
                    arr_set_val "$key" "$emptyExpr"
                fi
            fi

        # Explicit separator '--'
        elif [ "$param" == "--" ]; then
            shift
            break

        # Positional arguments
        else
            arr_set_val "$pos_index" "$param"
            pos_index=$((pos_index + 1))
        fi

        shift
    done

    return 0
}

# Start autorun list
autorun_start() {
    if ! is_array "AUTORUN"; then
        error_exit "Invalid AUTORUN array."
    fi

    for command in "${AUTORUN[@]}"; do
        execute_command "$command"
    done

    return 0
}

# Function to initialise BISU
initialise() {
    register_current_command $(printf '%s ' "$@") # Need to be in the fixed 1st order
    check_bash_version
    check_bisu_version
    autorun_start
    check_commands_list "BISU_REQUIRED_EXTERNAL_COMMANDS"
    check_commands_list "REQUIRED_EXTERNAL_COMMANDS"
    load_required_scripts
    # Integrated installation
    confirm_to_install
}

# Function to check if BISU is installed
is_installed() {
    local target_path=$(target_path)
    is_file "$target_path" || return 1
    return 0
}

# Confirm to install
confirm_to_install() {
    get_args
    local param1=$(arr_get_val 1)
    local option_force=$(arr_get_val "f" "force")
    local action="$param1"
    local force="false"
    local choice="y"
    local current_file=$(current_file)
    local current_filename=$(current_filename)
    local target_path=$(target_path)
    local confirm_msg="Are you sure to install $current_filename?"

    [[ -z "$action" ]] && action="$option_force"
    [[ "$action" == "$EMPTY_EXPR" ]] && action=""

    if [[ "$action" == "install" ]]; then
        in_array "$option_force" "install" "$EMPTY_EXPR" && force="true"

        if is_installed; then
            choice="n"
            confirm_msg="$current_filename has already been installed at: $target_path. Do you want to reinstall it?"

            if [[ "$force" == "false" ]]; then
                error_exit "$current_filename has already been installed at: $target_path, \
                please use -f if you want to forcefully override it."
            fi
        fi

        if ! confirm "$confirm_msg" "$choice"; then
            error_exit "Aborted."
        fi

        install_script
    fi
}

# Function: install_script
install_script() {
    local current_script=$(current_file)
    local current_script_name=$(current_filename)
    local target_path=$(target_path)

    log_message "Moving $current_script_name to path: $target_path"
    exec_command "cp \"$current_script\" \"$target_path\""
    log_message "Done."
}

# Initialisation
initialise $(printf '"%s" ' "$0" "$@")
############################################################## BISU_END ##############################################################
