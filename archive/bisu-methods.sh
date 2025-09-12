#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
# shellcheck disable=SC2170,SC2219,SC2090,SC2190,SC2145,SC2294,SC2124,SC2139,SC2163,SC2043
################################################################# BISU Archived Functions ######################################################################
# Version: v1-20250912Z1

# archived work, works correctly, lack of performance
# Get the file's real path and verify the base folder's existence
Bisu::file_real_path_v1() {
    # Trim spaces and handle parameters
    local file=$(Bisu::trim "$1")
    local check_base_existence=$(Bisu::trim "${2:-false}")
    Bisu::in_array "${check_base_existence}" "true" "false" || check_base_existence="false"

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

# archived work, works correctly
# Set the specified key/value pairs in either indexed or associative arrays
# Usage: Bisu::array_set arr key1 val1 [key2 val2 ...]
# Returns 0 on success, 1 on failure
Bisu::array_set_v1() {
    local array_name key value is_assoc tmp_var tmp_ref ref numeric_indices sorted_idx idx i

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
            ref[$key]="$value"
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
            IFS=$'\n' sorted_idx=($(printf '%s\n' "${numeric_indices[@]}" | sort -n))
            unset IFS
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
