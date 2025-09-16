#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
# shellcheck disable=SC2170,SC2219,SC2090,SC2190,SC2145,SC2294,SC2124,SC2139,SC2163,SC2043
################################################################# BISU Archived Functions ######################################################################
# Version: v1-20250917Z3

# archived work, works correctly
# Get the file's real path and verify the base folder's existence
Bisu::normalize_path_v1() {
    # Trim spaces and handle parameters
    local file=$(Bisu::trim "$1")
    local check_base_existence=$(Bisu::trim "${2:-false}")
    Bisu::in_array "$check_base_existence" "true" "false" || check_base_existence="false"

    # If the input is empty after trimming, do not convert to "/" — return empty (preserve original semantics)
    if [ -z "$file" ]; then
        printf ''
        return 0
    fi

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

    # ---- Single awk pass: normalize slashes, remove /./ and /.$, trim trailing spaces and slashes ----
    file=$(printf '%s\n' "$file" | awk '{
        s=$0
        gsub(/\/+/, "/", s)         # collapse repeated slashes
        gsub(/\/\.\//, "/", s)     # remove /./ segments
        sub(/\/\.$/, "", s)        # remove trailing /. if present
        sub(/[ \t\r\n]+$/, "", s)  # trim trailing whitespace
        if (length(s) > 1) sub(/\/+$/, "", s) # remove trailing slashes except for root
        print s
    }' 2>/dev/null)

    # If `check_base_existence` is true, verify the file or directory exists
    if [[ "$check_base_existence" == "true" ]]; then
        [ -e "$file" ] && printf '%s' "$file" || printf ''
    else
        printf '%s' "$file"
    fi
    return 0
}

# archived work, works correctly
# Get the file's real path and optionally verify that the path exists.
Bisu::normalize_path_v2() {
    local file
    local check_base_existence
    local orig_trimmed
    local root_like

    file=$(Bisu::trim "$1")
    orig_trimmed=$file
    check_base_existence=$(Bisu::trim "${2:-false}")
    Bisu::in_array "$check_base_existence" "true" "false" || check_base_existence="false"

    # If the original trimmed input was empty, preserve emptiness and skip expansion.
    if [[ -z $orig_trimmed ]]; then
        file=""
    else
        # Expand shell variables and tilde (kept to match original semantics).
        file=$(eval printf '%s' "$orig_trimmed")

        # If eval produced an empty result, preserve empty (do not convert to $PWD).
        if [[ -z $file ]]; then
            file=""
        else
            # Leading ~ expansion only (no user-name expansion).
            if [[ $file == ~* ]]; then
                file="${HOME}${file:1}"
            fi

            # Build an absolute-like string for syntactic normalization:
            # - If already absolute, normalize that.
            # - If relative, prefix with $PWD (but we will canonicalize syntactically).
            local absolute=false
            local combined
            if [[ $file == /* ]]; then
                absolute=true
                combined="$file"
            else
                absolute=false
                combined="${PWD%/}/$file"
            fi

            # Split on '/' and process components into a stack (pure bash).
            local -a parts
            IFS='/' read -r -a parts <<<"$combined"
            local -a stack
            local part
            for part in "${parts[@]}"; do
                case "$part" in
                '' | '.')
                    # empty segment (from //) or current dir -> ignore
                    continue
                    ;;
                '..')
                    # parent dir: pop if possible; if at root (absolute + empty stack) do nothing
                    if ((${#stack[@]} > 0)); then
                        unset 'stack[${#stack[@]}-1]'
                    else
                        # If not absolute (shouldn't normally happen because combined used PWD),
                        # we would keep ".." to preserve semantics. But combined is absolute here.
                        :
                    fi
                    ;;
                *)
                    stack+=("$part")
                    ;;
                esac
            done

            # Reconstruct path from stack
            if [[ $absolute == true ]]; then
                if ((${#stack[@]} == 0)); then
                    file="/"
                else
                    # join with '/'
                    file="/${stack[*]}"
                    file="${file// /\/}"
                fi
            else
                # relative (edge-case): join without leading slash
                if ((${#stack[@]} == 0)); then
                    file=""
                else
                    file="${stack[*]}"
                    file="${file// /\/}"
                fi
            fi
        fi
    fi

    # If original input was root-like (one or more slashes), ensure "/"
    root_like=false
    if [[ -n $orig_trimmed && $orig_trimmed =~ ^/+$ ]]; then
        root_like=true
    fi

    if [[ -z $file && $root_like == true ]]; then
        file="/"
    fi

    # Final output: obey check_base_existence flag exactly like original function.
    if [[ "$check_base_existence" == "true" ]]; then
        [ -e "$file" ] && printf '%s' "$file" || printf ''
    else
        printf '%s' "$file"
    fi
    return 0
}

# archived work, works correctly
# Get the file's real path and verify the base folder's existence
Bisu::normalize_path_v3() {
    # Trim spaces and handle parameters
    local file=$(Bisu::trim "$1")
    local check_base_existence=$(Bisu::trim "${2:-false}")
    Bisu::in_array "$check_base_existence" "true" "false" || check_base_existence="false"

    # If the input is empty after trimming, preserve original semantics: return empty
    if [ -z "$file" ]; then
        printf ''
        return 0
    fi

    # Expand shell variables safely (preserve original eval behavior)
    file=$(eval printf '%s' "$file")

    # Replace a leading tilde (~) with $HOME using shell (preserves original behavior of replacing only leading '~')
    # This avoids spawning awk just for that substitution and keeps semantics identical to prior gsub(/^~/, ENVIRON["HOME"])
    if [ "${file#"${file%%[!~]*}"}" != "$file" ]; then
        # crude but safe check for leading '~' — the intent is only to replace the first leading '~' char
        :
    fi
    case "$file" in
    ~*) file="${HOME}${file#~}" ;;
    esac

    # Convert relative paths to absolute paths
    case "$file" in
    /*) : ;;                                              # Already absolute
    .) file="$(pwd)" ;;                                   # Convert "." to PWD
    ..) file="$(cd .. && pwd)" ;;                         # Convert ".." to absolute path
    ./*) file="$(pwd)/${file#./}" ;;                      # Handle "./file"
    ../*) file="$(cd "${file%/*}" && pwd)/${file##*/}" ;; # Handle "../file"
    *) file="$(pwd)/$file" ;;                             # Convert other relative paths
    esac

    # ---- Single awk pass: normalize slashes, remove /./ and /.$, trim trailing spaces and slashes ----
    file=$(printf '%s\n' "$file" | awk '{
        s=$0
        gsub(/\/+/, "/", s)         # collapse repeated slashes
        gsub(/\/\.\//, "/", s)      # remove /./ segments
        sub(/\/\.$/, "", s)         # remove trailing /. if present
        sub(/[ \t\r\n]+$/, "", s)   # trim trailing whitespace
        if (length(s) > 1) sub(/\/+$/, "", s) # remove trailing slashes except for root
        print s
    }' 2>/dev/null) || {
        printf ''
        return 1
    }

    # If `check_base_existence` is true, verify the file or directory exists
    if [[ "$check_base_existence" == "true" ]]; then
        [ -e "$file" ] && printf '%s' "$file" || printf ''
    else
        printf '%s' "$file"
    fi
    return 0
}

# archived work, works correctly
# Get the file's real path and verify the base folder's existence
Bisu::normalize_path_v4() {
    # Trim spaces and handle parameters (assumes Bisu::trim and Bisu::in_array exist)
    local file=$(Bisu::trim "$1")
    local check_base_existence=$(Bisu::trim "${2:-false}")
    Bisu::in_array "$check_base_existence" "true" "false" || check_base_existence="false"

    # Preserve original semantics: empty input (after trim) -> return empty string
    if [ -z "$file" ]; then
        printf ''
        return 0
    fi

    # Expand shell variables safely (preserve original eval behavior)
    file=$(eval printf '%s' "$file")

    # Replace a leading tilde (~) with $HOME (exactly like original awk behavior for leading '~')
    case "$file" in
    ~*) file="${HOME}${file#~}" ;;
    esac

    # Convert relative paths to absolute paths (kept identical to original logic)
    case "$file" in
    /*) : ;;                                              # Already absolute
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
