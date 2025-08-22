#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
# shellcheck disable=SC2170,SC2219,SC2090,SC2190,SC2145,SC2294,SC2124
################################################################# BISU Archived Functions ######################################################################
# Version: v1-20250822Z1

# not completely works, can not preserve quoted string as an entity
# string to indexed array
string_to_indexed_array_v1() {
    local array_name=$(trim "$2")
    is_valid_var_name "$array_name" || return 1

    local input="$1"
    local delim="${3-" "}"

    declare -n arr_ref="$array_name"
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
        ) 2>/dev/null || return 1
    else
        arr_ref=()
    fi

    return 0
}

# archived work, completely works
# Convert a string into an indexed array (lossless, robust)
string_to_indexed_array_v2() {
    local input="$1"
    local array_name=$(trim "$2")
    is_valid_var_name "$array_name" || return 1

    declare -n arr_ref="$array_name"
    arr_ref=()

    # Empty input → nothing
    [ -n "$input" ] || return 0

    # If input contains newline (from current_args), use mapfile directly
    if [[ "$input" == *$'\n'* ]]; then
        mapfile -t arr_ref <<<"$input"
        return 0
    fi

    # Else split by delimiter (default = space, can be customized)
    local delim="${3-" "}"
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

# archived work
# lack of performance
# Function to count an array's element number
array_count_v1() {
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

# archived work
# lack of performance
# Robust and POSIX-compliant isset function
isset_v1() {
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

# archived work
# string to array
string_to_array_v1() {
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

# not completely works
# Function to check if a variable is an indexed array
is_indexed_array_v1() {
    local name=$(trim "$1")
    is_valid_var_name "$name" || return 1
    local decl
    decl=$(declare -p "$name" 2>/dev/null)
    # Indexed arrays: have -a but not -A
    [[ $decl =~ ^[[:space:]]*declare[[:space:]]+(-[a-zA-Z]*a[a-zA-Z]*)[[:space:]]* ]] || return 1
    return 0
}

# not completely works
is_array_v1() {
    local name=$(trim "$1")
    is_valid_var_name "$name" || return 1
    # Check if variable is declared as an array (indexed or associative)
    declare -p "$name" 2>/dev/null | grep -qE 'declare -a|declare -A' &>/dev/null || return 1
    return 0
}

# archived work
# only effective for indexed arrays
array_merge_v1() {
    local src1=$(trim "$1")
    local src2=$(trim "$2")
    local dest_name=$(trim "$3")

    # Validate arguments
    if ! is_array "$src1" || ! is_array "$src2" || ! is_valid_var_name "$dest_name"; then
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
