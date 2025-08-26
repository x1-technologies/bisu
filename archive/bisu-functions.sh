#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
# shellcheck disable=SC2170,SC2219,SC2090,SC2190,SC2145,SC2294,SC2124,SC2139,SC2163,SC2043
################################################################# BISU Archived Functions ######################################################################
# Version: v1-20250826Z1

# archived work, works correctly, improved version of get_args()
# Parse command-line arguments into an associative storage backend.
# - Uses only `array_set "$array" "$key" "$value"` to write values.
# - Uses `array_get "$array" "$key"` to read existing values (to enforce repetition rules).
# - Writes into "$args_array_name" or "result" by default.
# - Emits values only (in insertion order) on stdout (one per line), then returns 0.
extract_args_v1() {
    local array_name=$(trim "$1")
    # Load args safely (no splitting on spaces)
    local -a args
    mapfile -t args < <(current_args)

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
                [ -z "$val" ] && val=" "

                # repetition check
                local existing
                existing="$(array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    array_set "target" "$key" "$val"
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
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
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
                            [ -z "$val" ] && val=" "
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
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
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
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
                            [ -z "$val" ] && val=" "
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
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
                    [ -z "$existing" ] && order_list+=("$key")
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
            array_set "target" "$key" "$token"
            order_list+=("$key")
            positional_index=$((positional_index + 1))
            i=$((i + 1))
        }
    done

    local kv_str=$(array_dump "target")
    @set "arr_ref" "${kv_str[@]}" || return 1
    # IMPORTANT: use -g so the declared associative array is global (visible outside function)
    eval "declare -gA ${array_name}=($arr_ref)" 2>/dev/null || return 1
    return 0
}

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

# archived work, works correctly, preliminarily optimized
# Parse command-line arguments into an associative storage backend.
# - Uses only `array_set "$array" "$key" "$value"` to write values.
# - Uses `array_get "$array" "$key"` to read existing values (to enforce repetition rules).
# - Writes into "$args_array_name" or "result" by default.
# - Emits values only (in insertion order) on stdout (one per line), then returns 0.
get_args_v3() {
    # Load args safely (no splitting on spaces)
    local -a args
    mapfile -t args < <(current_args)

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
                [ -z "$val" ] && val=" "

                # repetition check
                local existing
                existing="$(array_get "target" "$key")"
                if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                    array_set "target" "$key" "$val"
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
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
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
                            [ -z "$val" ] && val=" "
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
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
                        existing="$(array_get "target" "$key")"
                        if [ -z "$existing" ] || [ "$GETARGS_OVERRIDE_FLAG" -eq 1 ]; then
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
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
                            [ -z "$val" ] && val=" "
                            array_set "target" "$key" "$val"
                            [ -z "$existing" ] && order_list+=("$key")
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
                    [ -z "$existing" ] && order_list+=("$key")
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

# archived work, works correctly, not fully verified
# Set the specified key/value pairs in either indexed or associative arrays
# Usage: array_set arr key1 val1 [key2 val2 ...]
# Returns 0 on success, 1 on failure
array_set_v1() {
    local array_name key value is_assoc i
    array_name=$(trim "$1")
    shift

    is_array "$array_name" || return 1
    declare -n _ref="$array_name"

    if is_assoc_array "$array_name"; then
        is_assoc=1
    else
        is_assoc=0
    fi

    while [[ $# -gt 1 ]]; do
        key="$(trim "$1")"
        value="$2"
        shift 2

        [[ -z "$key" ]] && continue

        if [[ $is_assoc -eq 1 ]]; then
            _ref["$key"]="$value"
            continue
        fi

        if [[ "$key" =~ ^[0-9]+$ ]]; then
            _ref[$key]="$value"
            continue
        fi

        local __mig_tmp="__array_mig_tmp_$$"
        if isset "$__mig_tmp"; then
            unset -v "$__mig_tmp"
        fi
        declare -gA "$__mig_tmp"

        declare -n __tmp_ref="$__mig_tmp"
        for i in "${!_ref[@]}"; do
            __tmp_ref["$i"]="${_ref[$i]}"
        done

        # Unset original variable and re-declare it as associative
        unset -v "$array_name"
        declare -gA "$array_name"

        # Rebind _ref to the now-associative variable
        declare -n _ref="$array_name"

        # Restore values from tmp and clean up
        for i in "${!__tmp_ref[@]}"; do
            _ref["$i"]="${__tmp_ref[$i]}"
        done

        unset -v "__tmp_ref"
        unset -v "$__mig_tmp"

        is_assoc=1

        _ref["$key"]="$value"
    done

    return 0
}

# archived work, works correctly, not fully verified
# Get an element from a indexed or assoc array, if having multiple keys, when matched the first non-empty val then stop
# Usage: array_get arr key1 [key2 ...]
# Returns: 0 on success, 1 on failure
array_get_v1() {
    local array_name key val is_assoc
    array_name=$(trim "$1")
    shift

    is_array "$array_name" || {
        printf ''
        return 1
    }

    declare -n _ref="$array_name"

    if is_assoc_array "$array_name"; then
        is_assoc=1
    else
        is_assoc=0
    fi

    val=""
    for key in "$@"; do
        [[ -z "$key" ]] && continue

        if [[ $is_assoc -eq 1 ]]; then
            [[ -v _ref["$key"] ]] 2>/dev/null || continue
            val="${_ref[$key]}"
        else
            [[ "$key" =~ ^[0-9]+$ ]] || continue
            if ((key >= 0 && key < ${#_ref[@]})); then
                val="${_ref[$key]}"
            else
                continue
            fi
        fi

        [[ "${val:-}" == "${EMPTY_EXPR:-}" ]] && val=""

        [[ -n "$val" ]] && {
            [[ "$val" == "$EMPTY_EXPR" ]] && val=""
            break
        }
    done

    printf '%s' "$val"
    return 0
}

# archived work, works correctly
# Encode a string to Base10
# Concatenated 3-digit zero-padded ASCII decimals.
# Usage: base10_encode "string" -> "DDD...DDD"
base10_encode_v1() {
    local input result="" char ascii
    input=$(trim "$1")
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

# archived work, works correctly
# Decode from Base10 to the original string.
# Accepts concatenated 3-digit blocks or tokens separated by non-digits.
# Usage: base10_decode "DDD...DDD"  OR  base10_decode "DDD SEP DDD SEP ..."
base10_decode_v1() {
    local input result="" ascii_value ascii_dec char len i token processed=0

    input=$(trim "$1")
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

# archived work, works correctly
# base26: alphabet A..Z (0..25). Each byte -> 2 letters (high, low)
# base26_encode "string" -> "AA...ZZ"   (2 chars per byte)
base26_encode_v1() {
    local input result="" char ascii high low alphabet
    input=$(trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ' # index 0->A .. 25->Z

    while IFS= read -r -n1 char; do
        ascii=$(LC_ALL=C printf '%d' "'$char")
        # compute base26 two-digit representation
        high=$((ascii / 26))
        low=$((ascii % 26))
        result+="${alphabet:high:1}${alphabet:low:1}"
    done <<<"$input"

    printf '%s' "$result"
    return 0
}

# archived work, works correctly
# base26_decode: decode A..Z pairs (base26) back to original bytes.
# Accepts concatenated pairs "AABBCD..." (even length) or separated tokens like "AA BB C" (1-2 letters per token).
# Returns '' and exit code 1 on invalid input.
base26_decode_v1() {
    local input result="" token len ascii_val c0 c1 v0 v1 byte processed=0 i

    input=$(trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    # Normalize to uppercase to accept a..z or A..Z
    input=${input^^}

    # If any non-letter present, parse tokens of 1..2 letters using pure-Bash regex (no external tools)
    if [[ "$input" =~ [^A-Z] ]]; then
        while [[ $input =~ ^[^A-Z]*([A-Z]{1,2})(.*)$ ]]; do
            token=${BASH_REMATCH[1]}
            input=${BASH_REMATCH[2]}

            len=${#token}
            ((len >= 1 && len <= 2)) || {
                printf ''
                return 1
            }

            if ((len == 1)); then
                c0=${token:0:1}
                v0=$(($(LC_ALL=C printf '%d' "'$c0") - 65)) # 'A' -> 0
                ((v0 >= 0 && v0 < 26)) || {
                    printf ''
                    return 1
                }
                byte=$v0
            else
                c0=${token:0:1}
                c1=${token:1:1}
                v0=$(($(LC_ALL=C printf '%d' "'$c0") - 65))
                v1=$(($(LC_ALL=C printf '%d' "'$c1") - 65))
                ((v0 >= 0 && v0 < 26 && v1 >= 0 && v1 < 26)) || {
                    printf ''
                    return 1
                }
                byte=$((v0 * 26 + v1))
            fi

            # Validate byte range and ignore NUL for portability
            ((byte >= 0 && byte <= 255)) || {
                printf ''
                return 1
            }
            if ((byte != 0)); then
                result+=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$byte")")
            fi
            processed=1
        done

        # If no tokens were processed, input was invalid
        ((processed == 1)) || {
            printf ''
            return 1
        }

    else
        # Pure letters: must be even length (2 chars per byte)
        len=${#input}
        ((len % 2 == 0)) || {
            printf ''
            return 1
        }

        for ((i = 0; i < len; i += 2)); do
            c0=${input:i:1}
            c1=${input:i+1:1}
            v0=$(($(LC_ALL=C printf '%d' "'$c0") - 65))
            v1=$(($(LC_ALL=C printf '%d' "'$c1") - 65))
            ((v0 >= 0 && v0 < 26 && v1 >= 0 && v1 < 26)) || {
                printf ''
                return 1
            }
            byte=$((v0 * 26 + v1))
            ((byte >= 0 && byte <= 255)) || {
                printf ''
                return 1
            }
            # ignore NUL for portability
            if ((byte != 0)); then
                result+=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$byte")")
            fi
        done
    fi

    printf '%s' "$result"
    return 0
}

# archived work, works correctly
# base36: alphabet 0..9 A..Z (0..35). Each byte -> 2 chars.
# base36_encode "string" -> "00...ZZ"   (2 chars per byte)
base36_encode_v1() {
    local input result char ascii high low alphabet len
    input=$(trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    alphabet='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' # index 0..35

    while IFS= read -r -n1 char; do
        ascii=$(LC_ALL=C printf '%d' "'$char")
        high=$((ascii / 36))
        low=$((ascii % 36))
        result+="${alphabet:high:1}${alphabet:low:1}"
    done <<<"$input"

    printf '%s' "$result"
    return 0
}

# archived work, works correctly
# base36_decode: decode base36 (0-9,A-Z) 2-char pairs back to original bytes.
# Accepts concatenated pairs "00A1..." (even length) or separated tokens like "0A A1 2".
# Returns '' and exit code 1 on invalid input.
base36_decode_v1() {
    local input result="" token len c0 c1 v0 v1 byte processed=0 i

    input=$(trim "$1")
    [ -n "$input" ] || {
        printf ''
        return 1
    }

    # Normalize to uppercase to accept a..z or A..Z
    input=${input^^}

    # If any char outside 0-9A-Z present, parse tokens of 1..2 allowed chars using pure-Bash regex
    if [[ "$input" =~ [^0-9A-Z] ]]; then
        while [[ $input =~ ^[^0-9A-Z]*([0-9A-Z]{1,2})(.*)$ ]]; do
            token=${BASH_REMATCH[1]}
            input=${BASH_REMATCH[2]}

            len=${#token}
            ((len >= 1 && len <= 2)) || {
                printf ''
                return 1
            }

            if ((len == 1)); then
                c0=${token:0:1}
                if [[ "$c0" =~ [0-9] ]]; then
                    v0=$((c0)) # '0'..'9' -> 0..9
                else
                    v0=$(($(LC_ALL=C printf '%d' "'$c0") - 55)) # 'A'->10
                fi
                ((v0 >= 0 && v0 < 36)) || {
                    printf ''
                    return 1
                }
                byte=$v0
            else
                c0=${token:0:1}
                c1=${token:1:1}
                if [[ "$c0" =~ [0-9] ]]; then v0=$((c0)); else v0=$(($(LC_ALL=C printf '%d' "'$c0") - 55)); fi
                if [[ "$c1" =~ [0-9] ]]; then v1=$((c1)); else v1=$(($(LC_ALL=C printf '%d' "'$c1") - 55)); fi
                ((v0 >= 0 && v0 < 36 && v1 >= 0 && v1 < 36)) || {
                    printf ''
                    return 1
                }
                byte=$((v0 * 36 + v1))
            fi

            ((byte >= 0 && byte <= 255)) || {
                printf ''
                return 1
            }
            # ignore NUL byte for portability
            if ((byte != 0)); then
                result+=$(printf '%b' "\\$(LC_ALL=C printf '%03o' "$byte")")
            fi
            processed=1
        done

        # if no tokens processed, invalid input
        ((processed == 1)) || {
            printf ''
            return 1
        }

    else
        # Pure allowed-chars: must be even length (2 chars per byte)
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
            ((v0 >= 0 && v0 < 36 && v1 >= 0 && v1 < 36)) || {
                printf ''
                return 1
            }
            byte=$((v0 * 36 + v1))
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

# archived work, works correctly
# Encode a string to Base64
base64_encode_v1() {
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

# archived work, works correctly
# Decode from base64 to original string
base64_decode_v1() {
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

# archived work, correctly works, lack of performance
# POSIX-compliant trim functions using awk (UTF-8 supported)
trim_v1() {
    local str="$1"
    local chars="$2" # default POSIX space class
    local ci="$3"
    in_array "$ci" "true" "false" || ci="false"
    if [[ "$ci" == "true" ]]; then
        ci=1
    else
        ci=0
    fi
    [ $# -ne 0 ] || str=$(cat)

    if [[ "$chars" =~ ^[[:space:]]*$ ]]; then
        str="${str#"${str%%[![:space:]]*}"}" # ltrim
        str="${str%"${str##*[![:space:]]}"}" # rtrim
    else
        str=$(awk -v chars="[$chars]" -v IGNORECASE="$ci" '
            {
                gsub("^" chars "+", "")
                gsub(chars "+$", "")
                print
            }
        ' <<<"$str" 2>/dev/null)
    fi

    echo "$str"
    return 0
}

# archived work, correctly works, lack of performance
# POSIX-compliant trim functions using awk (UTF-8 supported)
ltrim_v1() {
    local str="$1"
    local chars="$2" # default POSIX space class
    local ci="$3"
    in_array "$ci" "true" "false" || ci="false"
    if [[ "$ci" == "true" ]]; then
        ci=1
    else
        ci=0
    fi
    [ $# -ne 0 ] || str=$(cat)

    if [[ "$chars" =~ ^[[:space:]]*$ ]]; then
        str="${str#"${str%%[![:space:]]*}"}" # ltrim
    else
        str=$(awk -v chars="[$chars]" -v IGNORECASE="$ci" '
            { gsub("^" chars "+", ""); print }
        ' <<<"$str" 2>/dev/null)
    fi

    echo "$str"
    return 0
}

# archived work, correctly works, lack of performance
# POSIX-compliant trim functions using awk (UTF-8 supported)
rtrim_v1() {
    local str="$1"
    local chars="$2" # default POSIX space class
    local ci="$3"
    in_array "$ci" "true" "false" || ci="false"
    if [[ "$ci" == "true" ]]; then
        ci=1
    else
        ci=0
    fi
    [ $# -ne 0 ] || str=$(cat)

    if [[ "$chars" =~ ^[[:space:]]*$ ]]; then
        str="${str%"${str##*[![:space:]]}"}" # rtrim
    else
        str=$(awk -v chars="[$chars]" -v IGNORECASE="$ci" '
            { sub(chars "$", ""); print }
        ' <<<"$str" 2>/dev/null)
    fi

    echo "$str"
    return 0
}

# archived work, correctly works
# Adaptive, POSIX-aware trim function (UTF-8 friendly, high-performance)
# Usage: trim "string" [chars] [case_insensitive]
#   chars: characters to trim (default: POSIX space class)
#   case_insensitive: "true"|"false"
# Behavior: adaptive threshold controlled by TRIM_CRITICAL_POINT (non-negative int, default 4096).
#           For inputs >= threshold the function uses awk (robust for large/UTF-8 data).
#           For smaller inputs it uses pure-Bash paths for best performance.
trim_v2() {
    local str chars raw_ci ci endpoints critical_point len use_awk
    str="$1"
    chars="${2:-}"
    raw_ci="${3:-false}"
    endpoints="${4:-3}"

    # validate ci param
    in_array "$raw_ci" "true" "false" || raw_ci="false"
    if [[ "$raw_ci" == "true" ]]; then
        ci=1
    else
        ci=0
    fi

    # endpoints must be 1,2 or 3; otherwise default 3
    if ! [[ "$endpoints" =~ ^[123]$ ]]; then
        endpoints=3
    fi

    # if no args, read from stdin (preserve original)
    if [[ $# -eq 0 ]]; then
        str=$(cat)
    fi

    # threshold: environment override allowed
    critical_point="${TRIM_CRITICAL_POINT:-4096}"
    if ! [[ "$critical_point" =~ ^[1-9][0-9]*$ ]]; then
        critical_point=4096
    fi

    # choose fast bash path or awk path
    len=${#str}
    if ((len >= critical_point)); then
        use_awk=1
    else
        use_awk=0
    fi

    # ---- whitespace default fast-path ----
    if [[ "$chars" =~ ^[[:space:]]*$ ]]; then
        if ((use_awk == 0)); then
            case $endpoints in
            1) # left only
                str="${str#"${str%%[![:space:]]*}"}"
                ;;
            2) # right only
                str="${str%"${str##*[![:space:]]}"}"
                ;;
            3) # both
                str="${str#"${str%%[![:space:]]*}"}"
                str="${str%"${str##*[![:space:]]}"}"
                ;;
            esac
            echo "$str"
            return 0
        else
            # large input: use awk (robust for UTF-8)
            # For whitespace, ensure a valid class is used
            if [[ "$endpoints" == "1" ]]; then
                str=$(
                    awk -v chars="[$chars]" -v IGNORECASE="$ci" '
                        { gsub("^" chars "+", ""); print }
                    ' <<<"$str" 2>/dev/null
                )
            elif [[ "$endpoints" == "2" ]]; then
                str=$(
                    awk -v chars="[$chars]" -v IGNORECASE="$ci" '
                        { gsub(chars "+$", ""); print }
                    ' <<<"$str" 2>/dev/null
                )
            else
                str=$(
                    awk -v chars="[$chars]" -v IGNORECASE="$ci" '{
                        gsub("^" chars "+", "")
                        gsub(chars "+$", "")
                        print 
                    }' <<<"$str" 2>/dev/null
                )
            fi
            echo "$str"
            return 0
        fi
    fi

    # ---- custom chars branch ----
    if ((use_awk == 1)); then
        # large input: use awk (robust for UTF-8)
        # For whitespace, ensure a valid class is used
        if [[ "$endpoints" == "1" ]]; then
            str=$(
                awk -v chars="[$chars]" -v IGNORECASE="$ci" '
                    { gsub("^" chars "+", ""); print }
                ' <<<"$str" 2>/dev/null
            )
        elif [[ "$endpoints" == "2" ]]; then
            str=$(
                awk -v chars="[$chars]" -v IGNORECASE="$ci" '
                    { gsub(chars "+$", ""); print }
                ' <<<"$str" 2>/dev/null
            )
        else
            str=$(
                awk -v chars="[$chars]" -v IGNORECASE="$ci" '{
                    gsub("^" chars "+", "")
                    gsub(chars "+$", "")
                    print 
                }' <<<"$str" 2>/dev/null
            )
        fi
        echo "$str"
        return 0
    fi

    # small input & custom chars: pure-Bash trimming (multibyte-aware-ish)
    local -A trim_map=()
    local ch chkey
    # build map from chars; honor case-insensitive
    while IFS= read -r -n1 ch; do
        [[ -z "$ch" ]] && continue
        if ((ci)); then
            chkey=${ch,,}
        else
            chkey=$ch
        fi
        trim_map["$chkey"]=1
    done <<<"$chars"

    # left trim if endpoints demands
    if ((endpoints == 1 || endpoints == 3)); then
        while [[ -n "$str" ]]; do
            ch="${str:0:1}"
            if ((ci)); then
                chkey=${ch,,}
            else
                chkey=$ch
            fi
            if [[ ${trim_map[$chkey]+_} ]]; then
                # remove first character (use pattern removal to be robust)
                str=${str#?}
                continue
            fi
            break
        done
    fi

    # right trim if endpoints demands
    if ((endpoints == 2 || endpoints == 3)); then
        while [[ -n "$str" ]]; do
            ch="${str: -1}"
            if ((ci)); then
                chkey=${ch,,}
            else
                chkey=$ch
            fi
            if [[ ${trim_map[$chkey]+_} ]]; then
                # remove last character robustly
                str=${str%?}
                continue
            fi
            break
        done
    fi

    echo "$str"
    return 0
}

# archived work, correctly works
# Adaptive, POSIX-aware ltrim function (UTF-8 friendly, high-performance)
# Usage: ltrim "string" [chars] [case_insensitive]
#   chars: characters to trim (default: POSIX space class)
#   case_insensitive: "true"|"false" (validated via in_array; default "false")
ltrim_v2() {
    trim "$1" "$2" "$3" "1" || return 1
    return 0
}

# archived work, correctly works
# Adaptive, POSIX-aware rtrim function (UTF-8 friendly, high-performance)
# Usage: rtrim "string" [chars] [case_insensitive]
#   chars: characters to trim (default: POSIX space class)
#   case_insensitive: "true"|"false" (validated via in_array; default "false")
rtrim_v2() {
    trim "$1" "$2" "$3" "2" || return 1
    return 0
}

# archived work, correctly works, lack of performance
# set guard for importing act
set_source_guard_v1() {
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

# archived work, correctly works, lack of performance
# Function to acquire a lock to prevent multiple instances
acquire_lock_v1() {
    local lock_file=$(current_lock_file)
    [ -n "$lock_file" ] || error_exit "❗️ Failed to acquire 🔒 lock."
    exec 200>"$lock_file" || error_exit "❗️ Cannot open 🔒 lock file: $lock_file"
    flock -n 200 || {
        lock_held
        error_exit "🔒 An instance is running: $lock_file"
    }
}

# archived work, correctly works, lack of performance
# Function to release the lock
release_lock_v1() {
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

# archived work, correctly works, lack of performance
# Function: gdate
# Description: function for converting ISO8601 time format to natural language format
gdate_v1() {
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
