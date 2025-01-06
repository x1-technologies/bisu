######################## BISU_START: Bash Internal Simple Utils | Version: v1.1.0 ########################
# Recommended PATH: /usr/local/sbin/bisu.bash

# Set PS4 to include the script name and line number
trap "wait" SIGCHLD
trap "cleanup" EXIT INT TERM HUP
export PS4='+${BASH_SOURCE}:${LINENO}: '

# Subprocesses pids to cleanup
SUBPROCESSES_PIDS=()
# Required external commands list
REQUIRED_EXTERNAL_COMMANDS=()

# Universal function to trim whitespace
trim() {
    echo "$1" | xargs
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

# Universal function to validate IP address
validate_ip() {
    local ip=$(trim "$1")
    if [[ $ip =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; then
        local IFS=.
        read -r i1 i2 i3 i4 <<< "$ip"
        if [[ $i1 -le 255 && $i2 -le 255 && $i3 -le 255 && $i4 -le 255 ]]; then
            return 0
        fi
    fi
    return 1
}

# Universal function to validate port number
validate_port() {
    local port=$(trim "$1")
    if [[ $port =~ ^[0-9]+$ ]] && (( port >= 0 && port <= 65535 )); then
        return 0
    else
        return 1
    fi
}

# mkdir_p
mkdir_p() {
    local dir=$1
    local dir_frill=${2:-""}
    local start_string=${3:-""}

    # Validate input directory name
    [[ -n "$dir" ]] || { echo -e "Error: No directory name provided."; return 1; }
    string_starts_with "$dir" "$start_string" || { echo -e "Error: No directory name provided."; return 1; }

    # Prepare the directory description with a frill if provided
    local dir_description="${dir_frill:+ $dir_frill}dir: $dir"
    
    # Check if the directory exists, if not, create it
    if [[ ! -d "$dir" ]]; then
        mkdir -p "$dir" || { echo -e "Error: Failed to create $dir_description"; return 1; }
        chmod -R 755 "$dir" || { echo -e "Error: Failed to change permissions for $dir_description"; return 1; }
    fi

    return 0
}

# Function to log messages with timestamps
log_message() {
    local fallback_log_file="/var/log/bsiu.log"
    local msg="$1"
    local log_file=$(log_file_def)
    local log_dir=$(dirname "$log_file")

    # Fallback to default log file if the file is empty or doesn't exist
    if [[ -z "$log_file" ]]; then
        log_file="$fallback_log_file"
        log_dir=$(dirname "$log_file")
    fi

    # Ensure the log directory exists
    mkdir_p "$log_dir" "log" || { exit 1; }

    if [[ ! -f "$log_file" ]]; then
        touch "$log_file" || { echo -e "Failed to create log file $log_file"; exit 1; }
    fi

    # Log the message with a timestamp
    echo "$(date +'%Y-%m-%d %H:%M:%S') - $msg" | tee -a "$log_file"
}

# Function to add an element to a specified global array
array_unique_push() {
    local array_name=$1
    local new_value=$2
    local value_type=${3:-STRING}  # Default to STRING if not provided

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

# Function to check existence of external commands
check_commands_existence() {
    local commands=("${REQUIRED_EXTERNAL_COMMANDS[@]}")

    # Initialize counters
    local invalid_commands_count=0
    local invalid_commands=""
    
    # Check if the array is empty
    if [[ ${#commands[@]} -eq 0 ]]; then
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
        if ! command -v "$command" &> /dev/null; then
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

# Function to acquire a lock to prevent multiple instances
acquire_lock() {
    local lock_file=$1
    [[ -n "$lock_file" ]] && exec 200>"$lock_file"
    if ! flock -n 200; then
        error_exit "Another instance is running."
    fi
    log_message "Lock acquired."
}

# Function to release the lock
release_lock() {
    if [[ -n "$lock_file" && -f "$lock_file" ]]; then
        flock -u 200
        rm -f "$lock_file"
        log_message "Lock released and removed."
    fi
}

# Trap function to handle script termination
cleanup() {
    log_message "Script terminated. Cleaning up."

    for pid in "${SUBPROCESSES_PIDS[@]}"; do
        kill -SIGTERM "$pid" 2>/dev/null
    done
    
    release_lock
    exit 0
}
################################################ BISU_END ################################################