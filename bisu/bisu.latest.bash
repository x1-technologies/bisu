######################## BISU_START: Bash Internal Simple Utils | Version: v2.0.1 ########################
# Recommended BISU PATH: /usr/local/sbin/bisu.bash
# Official Web Site: https://x-1.tech

# Set PS4 to include the script name and line number
trap "wait" SIGCHLD
trap "cleanup" EXIT INT TERM HUP
export PS4='+${BASH_SOURCE}:${LINENO}: '

# Define BISU VERSION
export BISU_VERSION="2.0.1"

# Subprocesses pids to cleanup
SUBPROCESSES_PIDS=()
# Required external commands list
BISU_REQUIRED_EXTERNAL_COMMANDS=('uuidgen' 'md5sum' 'awk')
REQUIRED_EXTERNAL_COMMANDS=()
# Global Variables
LOCK_FILE_DIR="/var/run"
ROOT_LOG_FILE="/var/log/bisu.log"             # Root Log file location
USER_LOG_FILE="$HOME/.local/var/log/bisu.log" # User Log file location
LOG_FILE="$ROOT_LOG_FILE"
BISU_TARGET_PATH="/usr/local/sbin/bisu.bash" # Default target path for moving scripts
REQUIRED_BASH_VERSION="5.0.0"                # Minimum required Bash version (configurable)

# Universal function to trim whitespace
trim() {
    echo "$1" | awk '{$1=$1}1'
}

# Function: current_file
# Description: According to its naming
current_file() {
    echo "${BASH_SOURCE[0]}"
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
  echo "${1:$(($2<0?${#1}+$2:$2)):$3}"
}

# Function: md5_sign
# Description: According to its naming
md5_sign() {
    echo -n "$1" | md5sum | awk '{print $1}'
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

# Function: log_message
# Description: Logs messages with timestamps to a specified log file, with fallback options.
# Arguments:
#   $1 - Message to log.
# Returns: None (logs message to file).
log_message() {
    local msg="$1"
    local stderr_flag="${2:-false}"  # Default is false if not provided
    local log_file="$LOG_FILE"
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

# Check if the current user is root (UID 0)
is_root_user() {
    if [ "$(id -u)" != 0 ]; then
        return 1
    fi
    return 0
}

# Function: add_env_path
# Description: To robustly add new path to append
add_env_path() {
    local new_path=$(trim "$1")

    # Check if the argument is provided
    if [ -z "$new_path" ]; then
        log_message "Error: No path provided to append."
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
        log_message "Error: No directory name provided."
        return 1
    }
    string_starts_with "$dir" "$start_string" || {
        log_message "Error: No directory name provided."
        return 1
    }

    # Prepare the directory description with a frill if provided
    local dir_description="${dir_frill:+ $dir_frill}dir: $dir"

    # Check if the directory exists, if not, create it
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || {
            log_message "Error: Failed to create $dir_description"
            return 1
        }
        chmod -R 755 "$dir" || {
            log_message "Error: Failed to change permissions for $dir_description"
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
    move_current_script "$BISU_TARGET_PATH"
}

# Function: is_valid_version
# Description: Validates a version number in formats vX.Y.Z, X.Y.Z, X.Y, or X/Y/Z.
# Arguments:
#   $1 - Version number to validate.
# Returns: 0 if valid, 1 if invalid.
is_valid_version() {
    local version="$1"

    # Check for version formats: v1.1.0, 1.1.0, 1.1, 1/2/3
    if [[ "$version" =~ ^[v]?[0-9]+(\.[0-9]+)*(/[0-9]+)*$ ]]; then
        log_message "Valid version format: $version"
        return 0
    else
        log_message "Invalid version format detected: $version"
        return 1
    fi
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
            log_message "Error: Value must be an integer."
            return 1
        fi
        ;;
    FLOAT)
        if ! [[ "$new_value" =~ ^-?[0-9]*\.[0-9]+$ ]]; then
            log_message "Error: Value must be a float."
            return 1
        fi
        ;;
    STRING)
        # No specific validation for STRING
        ;;
    *)
        log_message "Error: Invalid type specified. Use STRING, INT, or FLOAT."
        return 1
        ;;
    esac

    # Ensure the global array exists
    if ! declare -p "$array_name" &>/dev/null; then
        log_message "Error: Array $array_name does not exist."
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
        log_message "Error: Item already exists in array."
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
        log_message "Error: Requires exactly three arguments (two array names and one result name)."
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

# Function: check_bash_version
# Description: Verifies that the installed Bash version is greater than or equal to the specified required version.
# Returns: 0 if Bash version is valid, 1 if not.
check_bash_version() {
    if ! is_valid_version "$REQUIRED_BASH_VERSION" ; then
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
    if ! is_dir "$lock_file_dir" ; then
        lock_file_dir="/var/run"
    fi
    if string_end_with "$lock_file_dir" "/" ; then
        lock_file_dir=$(substr "$lock_file_dir" -1)
    fi
    LOCK_FILE_DIR="$lock_file_dir"
    echo "$lock_file_dir/$(md5_sign "$(current_file)").lock"
}

# Function to acquire a lock to prevent multiple instances
acquire_lock() {
    local lock_file=$(current_lock_file)
    [[ -n "$lock_file" ]] && exec 200>"$lock_file"
    if ! flock -n 200; then
        error_exit "Another instance is running."
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
    shift  # Remove the function name from the parameter list
    if declare -f "$func_name" > /dev/null; then
        "$func_name" "$@"  # Call the function with the remaining parameters
    else
        log_message "Error: Function '$func_name' not found."
    fi
}

# Confirm to install BISU
confirm_to_install_bisu() {
    local arg
    # Trim and convert input to lowercase
    arg=$(strtolower "$(trim "$1")")
    
    # Only proceed if the input matches "bisu_install"
    if [[ "$arg" == "bisu_install" ]]; then
        read -p "Are you sure to install BISU? (Y/n): " c
        c="${c:-y}"  # Default to 'y' if input is empty
        if [[ "$c" =~ ^[Yy]$ ]]; then
            move_bisu
        fi
    fi
}

# bisu autorun function
bisu_main() {
    is_root_user || LOG_FILE="$USER_LOG_FILE"
    array_merge BISU_REQUIRED_EXTERNAL_COMMANDS REQUIRED_EXTERNAL_COMMANDS REQUIRED_EXTERNAL_COMMANDS
    confirm_to_install_bisu "$1"
}

bisu_main "$@"
################################################ BISU_END ################################################
