#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
# shellcheck disable=SC2170,SC2219,SC2090,SC2190,SC2145,SC2294,SC2124
################################################################# BISU Archived Functions ######################################################################
# Version: v1-20250822Z3

# not completely works, can not preserve quoted string as an entity
get_args_v1() {
    local -a args=($(current_args))
    local argc=${#args[@]}
    local i=0
    declare -A target=()

    # order_list records keys in the order they were first set (insertion order)
    local -a order_list=()
    local positional_index=1
    local GETARGS_OVERRIDE_FLAG="${GETARGS_OVERRIDE:-0}"
    local EMPTY_EXPR_literal="$EMPTY_EXPR" # the literal to use for booleans
    local stop_parsing=0

    # Internal function-like inline logic (kept inline as required):
    # - set_key_if_allowed KEY VALUE
    #     respects repetition rules and records insertion order.
    # Implementation uses only array_get/array_set for storage checks/sets.
    #
    # Because subfunctions are disallowed by the spec, implement logic inline via labels
    # (comments) where used.

    while [ $i -lt $argc ]; do
        local token="${args[$i]}"

        if [ "$stop_parsing" -eq 1 ]; then
            # All subsequent args are positional
            local key="$positional_index"
            array_set "target" "$key" "$token"
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
            #  --opt              -> opt="$EMPTY_EXPR"
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
                if [ -z "$val" ]; then val=" "; fi

                # repetition check
                local existing
                existing="$(array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    array_set "target" "$key" "$val"
                    # record order if first set
                    if [ -z "$existing" ]; then order_list+=("$key"); fi
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
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            array_set "target" "$key" "$val"
                            if [ -z "$existing" ]; then order_list+=("$key"); fi
                        fi
                        continue
                    fi

                    # if next does not start with '-', bind it as the value (covers key=value literal too)
                    if [[ ! "$next" == -* ]]; then
                        val="$next"
                        i=$((i + 2))
                        local existing
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            # explicit empty string binding (user wrote --opt "" ) would be an empty arg,
                            # but if val is empty we treat it as explicit empty: store single space " ".
                            if [ -z "$val" ]; then val=" "; fi
                            array_set "target" "$key" "$val"
                            if [ -z "$existing" ]; then order_list+=("$key"); fi
                        fi
                        continue
                    fi
                fi

                # Otherwise, boolean flag
                val="$EMPTY_EXPR_literal"
                i=$((i + 1))
                local existing
                existing="$(array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    array_set "target" "$key" "$val"
                    if [ -z "$existing" ]; then order_list+=("$key"); fi
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
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            array_set "target" "$key" "$val"
                            if [ -z "$existing" ]; then order_list+=("$key"); fi
                        fi
                        continue
                    fi
                    # Bind next as value only if it does NOT start with '-'
                    if [[ ! "$next" == -* ]]; then
                        local val="$next"
                        i=$((i + 2))
                        local existing
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            if [ -z "$val" ]; then val=" "; fi
                            array_set "target" "$key" "$val"
                            if [ -z "$existing" ]; then order_list+=("$key"); fi
                        fi
                        continue
                    fi
                fi

                # Otherwise boolean
                local val="$EMPTY_EXPR_literal"
                i=$((i + 1))
                local existing
                existing="$(array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    array_set "target" "$key" "$val"
                    if [ -z "$existing" ]; then order_list+=("$key"); fi
                fi
                continue
            else
                # Bundled short options or -ovalue: treat every character after '-' as its own boolean.
                # Example: -abc -> a="$EMPTY_EXPR" b="$EMPTY_EXPR" c="$EMPTY_EXPR"
                # Example: -ovalue -> o="$EMPTY_EXPR" v="$EMPTY_EXPR" a="$EMPTY_EXPR" l="$EMPTY_EXPR" u="$EMPTY_EXPR" e="$EMPTY_EXPR"
                local j=1
                while [ $j -lt $token_len ]; do
                    local ch="${token:$j:1}"
                    local key="$ch"
                    local val="$EMPTY_EXPR_literal"
                    local existing
                    existing="$(array_get "target" "$key")"
                    if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                        array_set "target" "$key" "$val"
                        if [ -z "$existing" ]; then order_list+=("$key"); fi
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
            array_set "target" "$key" "$token"
            order_list+=("$key")
            positional_index=$((positional_index + 1))
            i=$((i + 1))
        }
    done

    array_dump "target" || return 1
    return 0
}

# archived work, works correctly, did not fully optimized
get_args_v2() {
    # Load args safely (no splitting on spaces)
    local -a args
    mapfile -t args < <(current_args)

    local argc=${#args[@]}
    local i=0
    declare -A target=()

    local -a order_list=()
    local positional_index=1
    local GETARGS_OVERRIDE_FLAG="${GETARGS_OVERRIDE:-0}"
    local EMPTY_EXPR_literal="$EMPTY_EXPR"
    local stop_parsing=0

    while [ $i -lt $argc ]; do
        local token="${args[$i]}"

        if [ "$stop_parsing" -eq 1 ]; then
            local key="$positional_index"
            array_set "target" "$key" "$token"
            order_list+=("$key")
            positional_index=$((positional_index + 1))
            i=$((i + 1))
            continue
        fi

        if [ "$token" = "--" ]; then
            stop_parsing=1
            i=$((i + 1))
            continue
        fi

        if [[ "$token" == --* ]]; then
            local long_raw="$token"
            local val=""
            local keyraw=""
            if [[ "$long_raw" == *=* ]]; then
                keyraw="${long_raw%%=*}"
                val="${long_raw#*=}"
                while [[ "$keyraw" == -* ]]; do keyraw="${keyraw#-}"; done
                local key="${keyraw//-/_}"
                [ -z "$val" ] && val=" "

                local existing
                existing="$(array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    array_set "target" "$key" "$val"
                    [ -z "$existing" ] && order_list+=("$key")
                fi
                i=$((i + 1))
                continue
            else
                keyraw="$long_raw"
                while [[ "$keyraw" == -* ]]; do keyraw="${keyraw#-}"; done
                local key="${keyraw//-/_}"

                local nextidx=$((i + 1))
                if [ $nextidx -lt $argc ]; then
                    local next="${args[$nextidx]}"
                    if [[ "$next" = "--" ]]; then
                        val="--"
                        i=$((i + 2))
                        local existing
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
                        fi
                        continue
                    fi
                    if [[ ! "$next" == -* ]]; then
                        val="$next"
                        i=$((i + 2))
                        local existing
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            [ -z "$val" ] && val=" "
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
                        fi
                        continue
                    fi
                fi
                val="$EMPTY_EXPR_literal"
                i=$((i + 1))
                local existing
                existing="$(array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    array_set "target" "$key" "$val"
                    [ -z "$existing" ] && order_list+=("$key")
                fi
                continue
            fi
        fi

        if [[ "$token" == -* && "$token" != "-" ]]; then
            local token_len=${#token}
            if [ "$token_len" -eq 2 ]; then
                local ch="${token:1:1}"
                local key="$ch"
                local nextidx=$((i + 1))
                if [ $nextidx -lt $argc ]; then
                    local next="${args[$nextidx]}"
                    if [ "$next" = "--" ]; then
                        local val="--"
                        i=$((i + 2))
                        local existing
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
                        fi
                        continue
                    fi
                    if [[ ! "$next" == -* ]]; then
                        local val="$next"
                        i=$((i + 2))
                        local existing
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            [ -z "$val" ] && val=" "
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
                        fi
                        continue
                    fi
                fi
                local val="$EMPTY_EXPR_literal"
                i=$((i + 1))
                local existing
                existing="$(array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    array_set "target" "$key" "$val"
                    [ -z "$existing" ] && order_list+=("$key")
                fi
                continue
            else
                local j=1
                while [ $j -lt $token_len ]; do
                    local ch="${token:$j:1}"
                    local key="$ch"
                    local val="$EMPTY_EXPR_literal"
                    local existing
                    existing="$(array_get "target" "$key")"
                    if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                        array_set "target" "$key" "$val"
                        [ -z "$existing" ] && order_list+=("$key")
                    fi
                    j=$((j + 1))
                done
                i=$((i + 1))
                continue
            fi
        fi

        {
            local key="$positional_index"
            array_set "target" "$key" "$token"
            order_list+=("$key")
            positional_index=$((positional_index + 1))
            i=$((i + 1))
        }
    done

    array_dump "target" || return 1
    return 0
}

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
