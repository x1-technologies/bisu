################################# BISU_START: Bash Internal Simple Utils #################################
# Recommended BISU PATH: /usr/local/sbin/bisu.bash
# Official Web Site: https://x-1.tech
# Define BISU VERSION
export BISU_VERSION="3.0.0"

# Set PS4 to include the script name and line number
trap "wait" SIGCHLD
trap "cleanup" EXIT INT TERM HUP
export PS4='+${BASH_SOURCE}:${LINENO}: '

# BISU path
export BISU_FILE_PATH="${BASH_SOURCE[0]}"
# The current file path
export CURRENT_FILE_PATH=""
# Default title
export DEFAULT_TITLE="-bash"
# Required files
export REQUIRED_SCRIPT_FILES=()

# Subprocesses pids to cleanup
SUBPROCESSES_PIDS=()
# Required external commands list
BISU_REQUIRED_EXTERNAL_COMMANDS=('uuidgen' 'md5sum' 'awk' 'yq' 'xxd' 'bc')
REQUIRED_EXTERNAL_COMMANDS=()
# Global Variables
ROOT_LOCK_FILE_DIR="/var/run"
USER_LOCK_FILE_DIR="$HOME/.local/var/run"
LOCK_FILE_DIR=""
ROOT_LOG_FILE_DIR="/var/log"             # Root Log file location
USER_LOG_FILE_DIR="$HOME/.local/var/log" # User Log file location
LOG_FILE=""
BISU_TARGET_PATH="/usr/local/sbin/bisu.bash" # Default target path for moving scripts
REQUIRED_BASH_VERSION="5.0.0"                # Minimum required Bash version (configurable)

# Universal function to trim whitespace
trim() {
    echo "$1" | awk '{$1=$1}1'
}

# BISU file path
bisu_file() {
    echo "$BISU_FILE_PATH"
}

# Function: current_file
# Description: According to its naming
current_file() {
    local current_file_path=$(trim "$1")

    if [[ -z "$CURRENT_FILE_PATH" ]]; then
        CURRENT_FILE_PATH="${BASH_SOURCE[0]}"
    fi

    if [[ -n "$current_file_path" ]]; then
        if ! is_file "$current_file_path"; then
            echo -e "Error: Invalid file path provided: $current_file_path" >&2
            exit 1
        fi
        CURRENT_FILE_PATH="$current_file_path"
    fi

    echo "$CURRENT_FILE_PATH"
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
    echo "${1:$(($2 < 0 ? ${#1} + $2 : $2)):$3}"
}

# Function: md5_sign
# Description: According to its naming
md5_sign() {
    echo -n "$1" | md5sum | awk '{print $1}'
}

# Function: current_dirname
# Description: According to its naming
current_dirname() {
    local filepath=$(trim "$1")
    if [[ -z "$filepath" || ! -e "$filepath" || (! -d "$filepath" && ! -f "$filepath") ]]; then
        echo ""
    else
        echo $(basename "$(dirname $filepath)")
    fi
}

# Check string start with
string_starts_with() {
    local input_string=$1
    local start_string=$2

    if [[ -z "$input_string" || -n "$start_string" && "$input_string" != "$start_string"* ]]; then
        return 1
    fi

    return 0
}

# Check string end with
string_end_with() {
    [[ "${1: -${#2}}" == "$2" ]]
}

# Check if the current user is root (UID 0)
is_root_user() {
    if [ "$(id -u)" != 0 ]; then
        return 1
    fi
    return 0
}

# Function: is_valid_date
# Description: According to its naming
is_valid_date() {
    local date_str=$(trim "$1")

    # Check if the date matches any valid format using regular expressions
    if [[ "$date_str" =~ ^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}$ ||
        "$date_str" =~ ^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}\ ([0-9]{1,2}):([0-9]{2})$ ||
        "$date_str" =~ ^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}\ ([0-9]{1,2}):([0-9]{2})\ (AM|PM)$ ||
        "$date_str" =~ ^[0-9]{4}-[0-9]{1,2}-[0-9]{1,2}\ ([0-9]{1,2}):([0-9]{2})\ [APap][Mm]$ ]]; then
        return 0 # Valid date
    else
        return 1 # Invalid date
    fi
}

# The current log file
current_log_file() {
    local log_file_dir="$LOG_FILE_DIR"
    local log_file=""
    local filename=$(basename "$(current_file)")
    local current_dirname=""

    # Check if log file directory is valid, otherwise set based on user privileges
    if ! [[ -n "$log_file_dir" && -e "$log_file_dir" && -d "$log_file_dir" ]]; then
        log_file_dir=$(if is_root_user; then echo "$ROOT_LOG_FILE_DIR"; else echo "$USER_LOG_FILE_DIR"; fi)
    fi

    # Default to $HOME if no valid directory found
    log_file_dir="${log_file_dir:-$HOME/.local/var/run}"

    # Remove trailing slash if exists
    [[ "$log_file_dir" =~ /$ ]] && log_file_dir="${log_file_dir%/}"

    # Construct log file directory with current date, ensuring it's only appended once
    log_file_dir="$log_file_dir/$filename"
    log_file_dir="$log_file_dir/$(date +'%Y-%m')"

    # Create directory if it doesn't exist
    if [[ ! -d "$log_file_dir" ]]; then
        mkdir -p "$log_file_dir" && chmod -R 755 "$log_file_dir" || {
            echo -e "Error: Failed to create or set permissions for $log_file_dir" >&2
            exit 1
        }
    fi

    # Final checks and log file creation
    LOG_FILE_DIR="$log_file_dir"
    log_file="$log_file_dir/$filename.log"

    touch "$log_file" || {
        echo -e "Error: Failed to create log file $log_file" >&2
        exit 1
    }

    # Validate log file creation
    if ! [[ -e "$log_file" && -f "$log_file" ]]; then
        echo -e "Error: Log file $log_file creation failed" >&2
        exit 1
    fi

    echo "$log_file"
}

# Function: log_message
# Description: Logs messages with timestamps to a specified log file, with fallback options.
# Arguments:
#   $1 - Message to log.
# Returns: None (logs message to file).
log_message() {
    local msg="$1"
    local stderr_flag="${2:-true}"
    local log_file="$(current_log_file)"
    local log_dir=$(dirname "$log_file")

    # Ensure the log directory exists
    mkdir -p "$log_dir" || {
        echo -e "Failed to create log directory: $log_dir" >&2
        exit 1
    }

    # Create the log file if it doesn't exist
    if [[ ! -f "$log_file" ]]; then
        touch "$log_file" || {
            echo -e "Failed to create log file $log_file" >&2
            exit 1
        }
    fi

    # Log the message with a timestamp to the log file and optionally to stderr
    if [[ "$stderr_flag" == "true" ]]; then
        # Log to both log file and stderr
        echo -e "$(date +'%Y-%m-%d %H:%M:%S') - $msg" | tee -a "$log_file" >&2
    else
        # Log to the log file only
        echo -e "$(date +'%Y-%m-%d %H:%M:%S') - $msg" | tee -a "$log_file" >/dev/null
    fi

    return 0
}

# Function to handle errors
error_exit() {
    local msg=$(trim "$1")
    log_message "Error: $msg" "true"
    exit 1
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
    [[ "$1" =~ ^-?[0-9]+(\.[0-9]+)?$ ]] && return 0 || return 1
}

# Function: is_file
# Description: According to its naming
is_file() {
    local filepath=$(trim "$1")
    [[ -z "$filepath" || ! -f "$filepath" || ! -e "$filepath" ]] && return 1 || return 0
}

# Function: is_dir
# Description: According to its naming
is_dir() {
    local dirpath=$(trim "$1")
    [[ -z "$dirpath" || ! -d "$dirpath" || ! -e "$dirpath" ]] && return 1 || return 0
}

# Function: file_exists
# Description: According to its naming
file_exists() {
    local filepath=$(trim "$1")
    if ! (is_file "$filepath" || is_dir "$filepath"); then
        log_message "File or dir $filepath does not exist."
        return 1
    fi
    return 0
}

# mkdir_p
mkdir_p() {
    local dir=$1
    local dir_frill=${2:-""}
    local start_string=${3:-""}

    # Validate input directory name
    [[ -n "$dir" ]] || {
        log_message "No directory name provided."
        return 1
    }
    string_starts_with "$dir" "$start_string" || {
        log_message "No directory name provided."
        return 1
    }

    # Prepare the directory description with a frill if provided
    local dir_description="${dir_frill:+ $dir_frill}dir: $dir"

    # Check if the directory exists, if not, create it
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            log_message "Failed to create $dir_description"
            return 1
        }
        chmod -R 755 "$dir" || {
            log_message "Failed to change permissions for $dir_description"
            return 1
        }
    fi

    return 0
}

# Function: touch_dir
# Description: According to its naming
touch_dir() {
    local target_dir=$(trim "$1")

    # Check if the directory path is valid and non-empty
    if [[ -z "$target_dir" ]]; then
        log_message "Invalid directory path provided."
        return 1
    fi

    mkdir_p "$target_dir"
    return 0
}

# Function: move_file
# Description: Moves any file to the specified target path.
# Arguments:
#   $1 - File to move (source path).
#   $2 - Target path (destination directory).
# Returns: 0 if successful, 1 if failure.
move_file() {
    local source_file=$(trim "$1")
    local target_dir=$(trim "$2")

    # Check if the source file exists
    if [[ ! -f "$source_file" ]]; then
        log_message "Source file $source_file does not exist."
        return 1
    fi

    # Touch dir
    touch_dir "$target_dir"

    # Move the file to the target path
    mv "$source_file" "$target_dir"

    # Check if the move was successful
    if [[ $? != 0 ]]; then
        log_message "Failed to move file $source_file to $target_dir"
        return 1
    fi
    return 0
}

# Function: move_current_script
# Description: Moves the current script to a specified target path using the move_file function.
# Arguments: None
# Returns: 0 if successful, 1 if failure.
move_current_script() {
    local current_script=$(current_file)
    local target_path=$(trim "$1")

    log_message "Moving current script: $current_script"
    move_file "$current_script" "$target_path"
}

# Function: move_bisu
move_bisu() {
    local current_script=$(bisu_file)
    local target_path=$(trim "$1")

    log_message "Moving BISU script to path: $target_path"
    move_file "$current_script" "$target_path"
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
    if ! declare -p "$array_name" &>/dev/null; then
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
    if [[ $# -ne 3 || -z "$1" || -z "$2" || -z "$3" ]]; then
        log_message "Requires exactly three arguments (two array names and one result name)."
        return 1
    fi

    local array1="$1" array2="$2" result="$3"

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
    if [[ $# -ne 1 || -z "$1" ]]; then
        log_message "Requires exactly one argument (array name)."
        return 1
    fi

    local array_name="$1"
    eval "$array_name=($(echo \${$array_name[@]} | tr ' ' '\n' | sort -u | tr '\n' ' '))"
}

# Function: is_valid_version
# Description: Validates a version number in formats vX.Y.Z, X.Y.Z, X.Y, or X/Y/Z.
# Arguments:
# $1 - Version number to validate.
# Returns: 0 if valid, 1 if invalid.
is_valid_version() {
    local version="$1"

    # Check for version formats
    if [[ "$version" =~ ^[v]?[0-9]+(\.[0-9]+)*(/[0-9]+)*$ ]]; then
        return 0
    else
        log_message "Invalid version format: $version"
        return 1
    fi
}

# Function: check_bash_version
# Description: Verifies that the installed Bash version is greater than or equal to the specified required version.
# Returns: 0 if Bash version is valid, 1 if not.
check_bash_version() {
    if ! is_valid_version "$REQUIRED_BASH_VERSION"; then
        log_message "Illegal version number of required Bash"
        return 1
    fi

    local bash_version=$(bash --version | head -n 1 | awk '{print $4}')

    # Extract the major, minor, and patch version components
    local major=$(echo "$bash_version" | cut -d '.' -f 1)
    local minor=$(echo "$bash_version" | cut -d '.' -f 2)
    local patch=$(echo "$bash_version" | cut -d '.' -f 3)

    # Log the current Bash version
    log_message "Detected Bash version: $bash_version"

    # Compare the version with the required version
    IFS='.' read -r req_major req_minor req_patch <<<"$REQUIRED_BASH_VERSION"

    if [[ "$major" -gt "$req_major" ]] ||
        { [[ "$major" == "$req_major" && "$minor" -gt "$req_minor" ]] ||
            { [[ "$major" == "$req_major" && "$minor" == "$req_minor" && "$patch" -ge "$req_patch" ]]; }; }; then
        log_message "Bash version is sufficient: $bash_version"
        return 0
    else
        log_message "Bash version is too old. Requires version $REQUIRED_BASH_VERSION or greater. Detected version: $bash_version"
        return 1
    fi
}

# Universal function to validate IP address
is_valid_ip() {
    local ip=$(trim "$1")
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        local IFS=.
        read -r i1 i2 i3 i4 <<<"$ip"
        if [[ $i1 -le 255 && $i2 -le 255 && $i3 -le 255 && $i4 -le 255 ]]; then
            return 0
        fi
    fi
    return 1
}

# Universal function to validate port number
is_valid_port() {
    local port=$(trim "$1")
    if [[ $port =~ ^[0-9]+$ ]] && ((port >= 0 && port <= 65535)); then
        return 0
    fi
    return 1
}

# Function to convert YAML to JSON
yaml_to_json() {
    local yaml="$(trim "$1")"
    if ! command -v yq &>/dev/null; then
        echo "{}"
        return
    fi
    yq -o json 2>/dev/null <<<"$yaml" || echo "{}"
}

# Private global variables to simulate associative array behavior
declare -a _ASSOC_KEYS=()
declare -a _ASSOC_VALUES=()

# Convert plaintext YAML-like key:value pairs into global variables simulating an associative array
yaml_to_array() {
    local input
    if [ $# -eq 0 ]; then
        input=$(cat)
    else
        input="$(trim "$1")"
    fi

    _ASSOC_KEYS=()   # Clear existing keys
    _ASSOC_VALUES=() # Clear existing values

    while IFS=':' read -r key value; do
        if [ -z "$key" ]; then
            continue # Skip empty lines or keys
        fi

        key=$(echo "$key" | tr -d '"' | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print}')
        value=$(echo "$value" | awk '{gsub(/^[[:space:]]+|[[:space:]]+$/, ""); print}')

        # Handle value types
        case "$value" in
        "true" | "false") ;;
        [0-9]* | [0-9]*.[0-9]*) ;;
        *) value="$(echo "$value" | awk '{gsub(/"/, ""); print}')" ;; # Escape double quotes within strings
        esac

        _ASSOC_KEYS+=("$key")
        _ASSOC_VALUES+=("$value")
    done <<<"$input"
}

# Function to access elements like an associative array using global variables
arr_get_val() {
    local search_key=$(trim "$1")
    for ((i = 0; i < ${#_ASSOC_KEYS[@]}; i++)); do
        if [ "${_ASSOC_KEYS[$i]}" = "$search_key" ]; then
            echo "${_ASSOC_VALUES[$i]}"
            return 0
        fi
    done
    echo "" # Return empty string if key not found or array is empty
    return 0
}

# To validate if a word is in a string
word_exists() {
    local word=$(trim "$1")
    local string=$(trim "$2")
    local match_whole_word=${3:-true}
    [[ "${match_whole_word}" == "true" ]] && [[ " ${string:-} " =~ " $word " ]] || [[ "${string:-}" =~ "$word" ]]
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
check_commands_existence() {
    local commands=("${REQUIRED_EXTERNAL_COMMANDS[@]}")

    # Initialize counters
    local invalid_commands_count=0
    local invalid_commands=""

    # Check if the array is empty
    if [[ ${#commands[@]} == 0 ]]; then
        return 0
    fi

    for command in "${commands[@]}"; do
        # Skip empty or illegal command paths
        if [[ -z "$command" || "$command" =~ ^[[:space:]]*$ ]]; then
            ((invalid_commands_count++))
            invalid_commands+=", $command"
            continue
        fi

        # Check if the command exists
        if ! command -v "$command" &>/dev/null; then
            ((invalid_commands_count++))
            invalid_commands+=", '$command'"
            continue
        fi
    done

    # Report the invalid commands if any
    if [[ $invalid_commands_count -gt 0 ]]; then
        invalid_commands=${invalid_commands:1}
        error_exit "Missing $invalid_commands_count command(s):$invalid_commands"
    fi

    return 0
}

# The current file's run lock by signed md5 of full path
current_lock_file() {
    local lock_file_dir="$LOCK_FILE_DIR"
    local lock_file=""
    if ! is_dir "$lock_file_dir"; then
        if is_root_user; then
            lock_file_dir="$ROOT_LOCK_FILE_DIR"
        else
            lock_file_dir="$USER_LOCK_FILE_DIR"
        fi
    fi

    if ! is_dir "$lock_file_dir"; then
        lock_file_dir="$HOME/.local/var/run"
        touch_dir "$lock_file_dir"
    fi

    if ! is_dir "$lock_file_dir"; then
        error_exit "Lock file creation failed."
    fi

    if string_end_with "$lock_file_dir" "/"; then
        lock_file_dir=$(substr "$lock_file_dir" -1)
    fi

    LOCK_FILE_DIR="$lock_file_dir"
    lock_file="$lock_file_dir/$(md5_sign "$(current_file)").lock"

    echo "$lock_file"
}

# Function to acquire a lock to prevent multiple instances
acquire_lock() {
    local lock_file=$(current_lock_file)
    [[ -n "$lock_file" ]] && exec 200>"$lock_file"
    if ! flock -n 200; then
        error_exit "An instance is running: $(current_lock_file)"
    fi
}

# Function to release the lock
release_lock() {
    local lock_file=$(current_lock_file)
    ! is_file "$lock_file" && return 1
    flock -u 200 && rm -f "$lock_file"
}

# Trap function to handle script termination
cleanup() {
    for pid in "${SUBPROCESSES_PIDS[@]}"; do
        kill -SIGTERM "$pid" 2>/dev/null
    done

    release_lock
    exit 0
}

# Function to dynamically call internal functions
call_func() {
    local func_name="$1"
    shift # Remove the function name from the parameter list
    if declare -f "$func_name" >/dev/null; then
        "$func_name" "$@" # Call the function with the remaining parameters
    else
        log_message "Function '$func_name' not found."
    fi
}

# Function to set the terminal title
set_title() {
    local title=$(trim "$1")
    if [[ -n "$title" ]]; then
        echo -ne "\033]0;${title}\007"
    fi
}

# Function to revert the terminal title
revert_title() {
    set_title "$DEFAULT_TITLE"
}

# Add new element to pending to load script list, param 1 as the to load script file
preload_script() {
    local script=$(trim "$1")
    if ! is_file "$script"; then
        error_exit "Failed to import script: $script"
    fi
    array_unique_push "REQUIRED_SCRIPT_FILES" "$script"
}

# Automatically import required scripts
import_required_scripts() {
    array_unique "REQUIRED_SCRIPT_FILES"
    for script in "${REQUIRED_SCRIPT_FILES[@]}"; do
        if is_file "$script"; then
            source "$script" || { error_exit "Failed to import script: $script"; }
        fi
    done
}

# Confirm to install BISU
confirm_to_install_bisu() {
    local arg
    # Trim and convert input to lowercase
    arg=$(strtolower "$(trim "$1")")

    # Only proceed if the input matches "bisu_install"
    if [[ "$arg" == "bisu_install" ]]; then
        read -p "Are you sure to install BISU? (Y/n): " c
        c="${c:-y}" # Default to 'y' if input is empty
        if [[ "$c" =~ ^[Yy]$ ]]; then
            move_bisu
        fi
    fi
}

# bisu autorun function
bisu_main() {
    local action=$(trim "$1")
    local param=$(trim "$2")

    case "$action" in
    "bisu_install") confirm_to_install_bisu "$action" ;;
    *) ;;
    esac

    array_merge "BISU_REQUIRED_EXTERNAL_COMMANDS" "REQUIRED_EXTERNAL_COMMANDS" "REQUIRED_EXTERNAL_COMMANDS"
    check_commands_existence
    import_required_scripts
}
################################################ BISU_END ################################################
