#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
# shellcheck disable=SC2170,SC2219,SC2090,SC2190,SC2145,SC2294,SC2124,SC2139,SC2163,SC2043,SC2292,SC2250,SC2088
################################################################# BISU Archived Functions ######################################################################
# Version: v11-20260502Z2

# It has issues
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

# It has issues
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

# It has issues
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

# It has issues
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

# It has issues
# Method: Bisu::normalize_path v5
# Get the file's real path and verify the base folder's existence
# Normalize a filesystem path string and optionally verify existence.
# Parameters:
#   $1  - input path (string). If empty after trim -> returns empty string.
#   $2  - preserve_relative_path (expects "true" or "false"; kept for API compatibility;
#         original behavior converts relative paths to absolute; this parameter is
#         validated but NOT applied to preserve original semantics).
#   $3  - check_base_existence ("true"|"false"). If "true" the function prints the
#         normalized path only when it exists; otherwise prints empty string.
# Notes:
#   - Uses Bisu::trim and Bisu::in_array which are assumed to exist (per original).
#   - Uses pure-bash manipulations and safe subshells for cd to avoid changing caller cwd.
#   - Returns 0 on success; prints result to stdout (empty string when requested/absent).
Bisu::normalize_path_v5() {
    local file
    file="$(Bisu::trim "$1")"
    local check_base_existence
    check_base_existence="$(Bisu::trim "$2")"
    Bisu::in_array "$check_base_existence" "true" "false" || check_base_existence="false"
    local preserve_relative_path
    preserve_relative_path="$(Bisu::trim "$3")"
    Bisu::in_array "$preserve_relative_path" "true" "false" || preserve_relative_path="false"

    # Preserve original semantics: empty input -> return empty string (and exit 0).
    if [ -z "$file" ]; then
        printf ''
        return 0
    fi

    # Expand leading tilde safely: ~ or ~user (only ~ for current user handled here)
    case "$file" in
    ~) file="${HOME}" ;;
    ~/*) file="${HOME}/${file#~/}" ;;
    esac

    # Convert certain relative shorthands to absolute (match original behavior):
    case "$file" in
    /*) : ;;                                      # already absolute — no change
    .) file="$(pwd)" ;;                           # single dot -> current working dir
    ..) file="$(cd .. >/dev/null 2>&1 && pwd)" ;; # parent dir -> absolute
    ./*) file="$(pwd)/${file#./}" ;;              # ./something -> pwd/something
    ../*)                                         # ../foo -> resolve directory portion
        {
            # Use a subshell cd to avoid changing caller directory.
            local _dirpart="${file%/*}"
            local _basepart="${file##*/}"
            # If path is exactly "../name" then _dirpart == ".."
            file="$(cd "$_dirpart" >/dev/null 2>&1 && pwd)/$_basepart" || file="$(pwd)/$file"
        }
        ;;
    *) file="$(pwd)/$file" ;; # other relative -> pwd/relative
    esac

    # --------------------------
    # Path normalization (pure bash)
    #  - collapse repeated '//' sequences
    #  - remove '/./' segments
    #  - remove trailing '/.' if present
    #  - trim trailing whitespace
    #  - remove trailing slashes except for root '/'
    # --------------------------

    # Collapse repeated slashes (iteratively until no double-slash remains).
    # Use a lightweight loop; safe for extremely long sequences.
    while [[ "$file" == *//* ]]; do
        file="${file//\/\//\/}"
    done

    # Remove '/./' segments
    file="${file//\/.\//\/}"

    # Remove trailing '/.' if present
    case "$file" in
    */.) file="${file%/.}" ;;
    esac

    # Trim trailing whitespace characters (space, tab, newline)
    local _trail="${file##*[!$' \t\n']}"
    file="${file%"$_trail"}"

    # Remove trailing slashes but preserve root '/'
    if [ "$file" != "/" ]; then
        # Remove any trailing slashes
        # "${file##*[!/]}" yields the trailing run of slashes; remove them
        file="${file%"${file##*[!/]}"}"
        # If result becomes empty (path was only slashes), coerce to '/'
        [ -z "$file" ] && file="/"
    fi

    # Final output: if check_base_existence requested, only output if path exists
    if [ "$check_base_existence" = "true" ]; then
        if [ -e "$file" ]; then
            printf '%s' "$file"
        else
            printf ''
        fi
    else
        printf '%s' "$file"
    fi

    return 0
}

# It has issues
# Method: Bisu::normalize_path v6
# Normalize a filesystem path string and optionally verify existence.
#
# Parameters:
#   $1  - input path (string). If empty after trim -> returns empty string.
#   $2  - preserve_relative_path ("true"|"false").
#   $3  - check_base_existence ("true"|"false"). If "true", print only if the final path exists.
#
# Notes:
#   - Expands leading ~ for the current user.
#   - Expands simple shell-style environment variables anywhere in the string:
#       $VAR   and   ${VAR}
#   - Does NOT evaluate command substitutions, arithmetic expansions, globs, or backticks.
#   - Uses pure bash path normalization.
Bisu::normalize_path_v6() {
    local input preserve_relative_path check_base_existence
    local expanded token name value segment result
    local is_absolute=0
    local -a parts stack
    local IFS='/' idx

    input="$(Bisu::trim "${1-}")"
    preserve_relative_path="$(Bisu::trim "${2-}")"
    check_base_existence="$(Bisu::trim "${3-}")"

    Bisu::in_array "$preserve_relative_path" "true" "false" || preserve_relative_path="false"
    Bisu::in_array "$check_base_existence" "true" "false" || check_base_existence="false"

    if [ -z "$input" ]; then
        printf ''
        return 0
    fi

    # Expand leading ~ for the current user.
    case "$input" in
    ~) input="$HOME" ;;
    ~/*) input="$HOME/${input#~/}" ;;
    esac

    # Expand simple env vars anywhere in the path.
    # Supports $VAR and ${VAR}.
    expanded="$input"
    while [[ "$expanded" =~ (\$\{[A-Za-z_][A-Za-z0-9_]*\}|\$[A-Za-z_][A-Za-z0-9_]*) ]]; do
        token="${BASH_REMATCH[1]}"

        # Prefix before the first occurrence of the token.
        # Use shortest-match removal so we replace the first match only.
        local prefix rest
        prefix="${expanded%"$token"*}"
        rest="${expanded#*"$token"}"

        case "$token" in
        \$\{*\})
            name="${token:2:${#token}-3}"
            ;;
        \$*)
            name="${token:1}"
            ;;
        esac

        value="${!name-}"
        expanded="${prefix}${value}${rest}"
    done
    input="$expanded"

    # Absolute vs relative.
    case "$input" in
    /*) is_absolute=1 ;;
    esac

    # Preserve relative input only when requested.
    if [ "$is_absolute" -eq 0 ] && [ "$preserve_relative_path" != "true" ]; then
        input="$(pwd -P)/$input"
        is_absolute=1
    fi

    # Split and normalize path components.
    read -r -a parts <<<"$input"

    for segment in "${parts[@]}"; do
        case "$segment" in
        '' | .)
            continue
            ;;
        ..)
            if [ "${#stack[@]}" -gt 0 ]; then
                idx=$((${#stack[@]} - 1))
                if [ "${stack[$idx]}" != ".." ]; then
                    unset "stack[$idx]"
                    continue
                fi
            fi

            # Keep unresolved .. only for relative paths.
            if [ "$is_absolute" -eq 0 ]; then
                stack+=("..")
            fi
            ;;
        *)
            stack+=("$segment")
            ;;
        esac
    done

    # Rebuild final path.
    if [ "${#stack[@]}" -eq 0 ]; then
        if [ "$is_absolute" -eq 1 ]; then
            result="/"
        else
            result="."
        fi
    else
        if [ "$is_absolute" -eq 1 ]; then
            result="/${stack[0]}"
        else
            result="${stack[0]}"
        fi

        for ((idx = 1; idx < ${#stack[@]}; idx++)); do
            result="$result/${stack[$idx]}"
        done
    fi

    # Optional existence check.
    if [ "$check_base_existence" = "true" ] && [ ! -e "$result" ]; then
        printf ''
        return 0
    fi

    printf '%s' "$result"
    return 0
}

# It has issues
# Method: Bisu::normalize_path v7
# Normalize a filesystem path string and optionally verify the base folder exists.
#
# Parameters:
#   $1  - input path (string). If empty after trim -> returns empty string.
#   $2  - preserve_relative_path ("true" or "false").
#         - "true"  => keep relative paths relative, but still normalize them.
#         - "false" => convert relative paths to an absolute path using pwd.
#   $3  - check_base_existence ("true" or "false").
#         - "true"  => print the normalized path only when its base directory exists.
#         - "false" => print the normalized path regardless of existence.
#
# Behavior:
#   - Expands leading "~" and shell-style variables anywhere in the path:
#       $HOME, ${HOME}, $PWD, ${VAR}, etc.
#   - Normalizes path segments safely:
#       repeated slashes, ".", ".."
#   - Removes trailing slash except for "/"
#   - Uses cd -P only when it can improve physical resolution of an existing base directory
#     and only when preserve_relative_path is "false".
#   - Returns 0 on success and prints the normalized path to stdout.
Bisu::normalize_path_v7() {
    local input normalized segment prefix rest varname varvalue
    local preserve_relative_path check_base_existence
    local had_trailing_slash=false
    local is_absolute=false
    local base_dir real_dir parent_dir leaf_dir

    input="$(Bisu::trim "$1")"
    preserve_relative_path="$(Bisu::trim "$2")"
    check_base_existence="$(Bisu::trim "$3")"

    Bisu::in_array "$preserve_relative_path" "true" "false" || preserve_relative_path="false"
    Bisu::in_array "$check_base_existence" "true" "false" || check_base_existence="false"

    # Empty input stays empty.
    if [ -z "$input" ]; then
        printf ''
        return 0
    fi

    # Remember whether the caller passed a directory-like path.
    case "$input" in
    */) had_trailing_slash=true ;;
    esac

    # Expand leading "~" safely.
    case "$input" in
    "~") input="$HOME" ;;
    "~/"*) input="$HOME/${input#~/}" ;;
    esac

    # Expand shell-style variables anywhere in the path, safely and without eval.
    # Supported forms:
    #   $VAR
    #   ${VAR}
    # Unknown variables expand to an empty string, matching shell behavior.
    normalized=''
    while :; do
        case "$input" in
        *'$'*)
            prefix=${input%%\$*}
            normalized+="$prefix"
            rest=${input#"$prefix"}

            if [[ $rest =~ ^\$\{([A-Za-z_][A-Za-z0-9_]*)\}(.*)$ ]]; then
                varname=${BASH_REMATCH[1]}
                varvalue=${!varname-}
                normalized+="$varvalue"
                input=${BASH_REMATCH[2]}
            elif [[ $rest =~ ^\$([A-Za-z_][A-Za-z0-9_]*)(.*)$ ]]; then
                varname=${BASH_REMATCH[1]}
                varvalue=${!varname-}
                normalized+="$varvalue"
                input=${BASH_REMATCH[2]}
            else
                # Lone "$" or non-variable token: keep it literally.
                normalized+='$'
                input=${rest#\$}
            fi
            ;;
        *)
            normalized+="$input"
            break
            ;;
        esac
    done
    input="$normalized"

    # Decide whether the path is absolute.
    case "$input" in
    /*) is_absolute=true ;;
    esac

    # Convert relative paths to absolute unless preserve_relative_path is requested.
    if [ "$preserve_relative_path" != "true" ] && [ "$is_absolute" != "true" ]; then
        input="$(pwd -P)/$input"
        is_absolute=true
    fi

    # Logical path normalization:
    #   - remove empty segments
    #   - remove "."
    #   - resolve ".."
    #   - keep "/" as root
    normalized=''
    if [ "$is_absolute" = "true" ]; then
        normalized='/'
    fi

    while :; do
        case "$input" in
        */*)
            segment=${input%%/*}
            input=${input#*/}
            ;;
        *)
            segment=$input
            input=''
            ;;
        esac

        case "$segment" in
        '' | '.')
            # Skip empty and current-directory segments.
            ;;
        '..')
            if [ "$normalized" = "/" ]; then
                # Stay at root.
                :
            elif [ -z "$normalized" ]; then
                # Relative path and nothing to pop: preserve leading "..".
                normalized='..'
            else
                normalized=${normalized%/*}
                [ -z "$normalized" ] && normalized='/'
            fi
            ;;
        *)
            if [ -z "$normalized" ] || [ "$normalized" = "/" ]; then
                normalized="${normalized}${segment}"
            else
                normalized="${normalized}/${segment}"
            fi
            ;;
        esac

        [ -z "$input" ] && break
    done

    # Relative paths that normalize to "current directory" should return ".".
    if [ "$preserve_relative_path" = "true" ] && [ -z "$normalized" ]; then
        normalized='.'
    fi

    # Optional physical canonicalization of an existing base directory.
    # This preserves the file name when possible, but only when the path is absolute
    # (or was converted to absolute) and preserve_relative_path is false.
    if [ "$preserve_relative_path" != "true" ]; then
        if [ "$normalized" = "/" ]; then
            :
        elif [ -d "$normalized" ]; then
            real_dir="$(cd -P -- "$normalized" >/dev/null 2>&1 && pwd -P)" || real_dir="$normalized"
            normalized="$real_dir"
        else
            parent_dir=${normalized%/*}
            leaf_dir=${normalized##*/}

            [ "$parent_dir" = "$normalized" ] && parent_dir='.'

            if [ -d "$parent_dir" ]; then
                real_dir="$(cd -P -- "$parent_dir" >/dev/null 2>&1 && pwd -P)" || real_dir="$parent_dir"
                if [ "$real_dir" = "/" ]; then
                    normalized="/$leaf_dir"
                else
                    normalized="$real_dir/$leaf_dir"
                fi
            fi
        fi
    fi

    # Check the base directory only, not strictly the final file path.
    # This allows paths to new files inside an existing folder to pass.
    if [ "$check_base_existence" = "true" ]; then
        if [ "$normalized" = "/" ]; then
            base_dir='/'
        elif [ -d "$normalized" ]; then
            base_dir="$normalized"
        else
            base_dir=${normalized%/*}
            [ "$base_dir" = "$normalized" ] && base_dir='.'
        fi

        if [ ! -d "$base_dir" ]; then
            printf ''
            return 0
        fi
    fi

    # Final polish:
    #   - remove trailing slash from non-root paths
    #   - ensure paths like "foo///" end as "foo"
    if [ "$normalized" != "/" ]; then
        while [ "${normalized%/}" != "$normalized" ]; do
            normalized=${normalized%/}
        done
    fi

    printf '%s' "$normalized"
    return 0
}

# It works well
# Method: Bisu::normalize_path v8
# Normalize a filesystem path string and optionally verify the base folder exists.
#
# Parameters:
#   $1  - input path (string). If empty after trim -> returns empty string.
#   $2  - preserve_relative_path ("true" or "false").
#         - "true"  => keep relative paths relative, but still normalize them.
#         - "false" => convert relative paths to an absolute path using pwd.
#   $3  - check_base_existence ("true" or "false").
#         - "true"  => print the normalized path only when its base directory exists.
#         - "false" => print the normalized path regardless of existence.
#
# Behavior:
#   - Expands leading "~" and shell-style variables anywhere in the path:
#       $HOME, ${HOME}, $PWD, ${VAR}, etc.
#   - Normalizes path segments safely:
#       repeated slashes, ".", ".."
#   - Removes trailing slash except for "/"
#   - Uses cd -P only when it can improve physical resolution of an existing base directory
#     and only when preserve_relative_path is "false".
#   - Returns 0 on success and prints the normalized path to stdout.
Bisu::normalize_path() {
    local input normalized segment prefix rest varname varvalue
    local preserve_relative_path check_base_existence
    local had_trailing_slash=false
    local is_absolute=false
    local base_dir real_dir parent_dir leaf_dir

    input="$(Bisu::trim "$1")"
    preserve_relative_path="$(Bisu::trim "$2")"
    check_base_existence="$(Bisu::trim "$3")"

    Bisu::in_array "$preserve_relative_path" "true" "false" || preserve_relative_path="false"
    Bisu::in_array "$check_base_existence" "true" "false" || check_base_existence="false"

    # Empty input stays empty.
    if [ -z "$input" ]; then
        printf ''
        return 0
    fi

    # Remember whether the caller passed a directory-like path.
    case "$input" in
    */) had_trailing_slash=true ;;
    esac

    # Expand leading "~" safely.
    case "$input" in
    "~")
        if [ "$preserve_relative_path" != "true" ]; then
            input="$HOME"
        fi
        ;;
    "~/"*)
        if [ "$preserve_relative_path" != "true" ]; then
            input="$HOME/${input#\~/}"
        fi
        ;;
    esac

    # Expand shell-style variables anywhere in the path, safely and without eval.
    # Supported forms:
    #   $VAR
    #   ${VAR}
    # Unknown variables expand to an empty string, matching shell behavior.
    normalized=''
    while :; do
        case "$input" in
        *'$'*)
            prefix=${input%%\$*}
            normalized+="$prefix"
            rest=${input:${#prefix}}

            if [[ $rest =~ ^\$\{([A-Za-z_][A-Za-z0-9_]*)\}(.*)$ ]]; then
                varname=${BASH_REMATCH[1]}
                varvalue=${!varname-}
                normalized+="$varvalue"
                input=${BASH_REMATCH[2]}
            elif [[ $rest =~ ^\$([A-Za-z_][A-Za-z0-9_]*)(.*)$ ]]; then
                varname=${BASH_REMATCH[1]}
                varvalue=${!varname-}
                normalized+="$varvalue"
                input=${BASH_REMATCH[2]}
            else
                # Lone "$" or non-variable token: keep it literally.
                normalized+='$'
                input=${rest#\$}
            fi
            ;;
        *)
            normalized+="$input"
            break
            ;;
        esac
    done
    input="$normalized"

    # Expand leading "~" again after substitutions.
    case "$input" in
    "~")
        if [ "$preserve_relative_path" != "true" ]; then
            input="$HOME"
        fi
        ;;
    "~/"*)
        if [ "$preserve_relative_path" != "true" ]; then
            input="$HOME/${input#\~/}"
        fi
        ;;
    esac

    # Decide whether the path is absolute.
    case "$input" in
    /*) is_absolute=true ;;
    esac

    # Convert relative paths to absolute unless preserve_relative_path is requested.
    if [ "$preserve_relative_path" != "true" ] && [ "$is_absolute" != "true" ]; then
        input="$(pwd -P)/$input"
        is_absolute=true
    fi

    # Logical path normalization:
    #   - remove empty segments
    #   - remove "."
    #   - resolve ".."
    #   - keep "/" as root
    normalized=''
    if [ "$is_absolute" = "true" ]; then
        normalized='/'
    fi

    while :; do
        case "$input" in
        */*)
            segment=${input%%/*}
            input=${input#*/}
            ;;
        *)
            segment=$input
            input=''
            ;;
        esac

        case "$segment" in
        '' | '.') ;;
        '..')
            if [ "$normalized" = "/" ]; then
                :
            elif [ -z "$normalized" ]; then
                normalized='..'
            elif [ "$normalized" = ".." ] || [ "${normalized#../}" != "$normalized" ]; then
                normalized="${normalized}/.."
            else
                normalized=${normalized%/*}
                [ -z "$normalized" ] && [ "$is_absolute" = "true" ] && normalized='/'
            fi
            ;;
        *)
            if [ -z "$normalized" ] || [ "$normalized" = "/" ]; then
                normalized="${normalized}${segment}"
            else
                normalized="${normalized}/${segment}"
            fi
            ;;
        esac

        [ -z "$input" ] && break
    done

    # Relative paths that normalize to "current directory" should return ".".
    if [ "$preserve_relative_path" = "true" ] && [ -z "$normalized" ]; then
        normalized='.'
    fi

    # Optional physical canonicalization of an existing base directory.
    if [ "$preserve_relative_path" != "true" ]; then
        if [ "$normalized" = "/" ]; then
            :
        elif [ -d "$normalized" ]; then
            real_dir="$(cd -P -- "$normalized" >/dev/null 2>&1 && pwd -P)" || real_dir="$normalized"
            normalized="$real_dir"
        else
            parent_dir=${normalized%/*}
            leaf_dir=${normalized##*/}

            [ "$parent_dir" = "$normalized" ] && parent_dir='.'

            if [ -d "$parent_dir" ]; then
                real_dir="$(cd -P -- "$parent_dir" >/dev/null 2>&1 && pwd -P)" || real_dir="$parent_dir"
                if [ "$real_dir" = "/" ]; then
                    normalized="/$leaf_dir"
                else
                    normalized="$real_dir/$leaf_dir"
                fi
            fi
        fi
    fi

    # Check the base directory only.
    if [ "$check_base_existence" = "true" ]; then
        if [ "$normalized" = "/" ]; then
            base_dir='/'
        elif [ -d "$normalized" ]; then
            base_dir="$normalized"
        else
            base_dir=${normalized%/*}
            [ "$base_dir" = "$normalized" ] && base_dir='.'
        fi

        if [ ! -d "$base_dir" ]; then
            printf ''
            return 0
        fi
    fi

    # Final polish.
    if [ "$normalized" != "/" ]; then
        while [ "${normalized%/}" != "$normalized" ]; do
            normalized=${normalized%/}
        done
    fi

    printf '%s' "$normalized"
    return 0
}

# It works well
# Bisu::array_set
# Description:
#   Set key/value pairs in indexed or associative arrays.
#   Fully uses Bisu's ref-processing pattern: canonical dump -> set via nameref -> rehydrate global array.
# Usage:
#   Bisu::array_set "array_name" key1 val1 [key2 val2 ...]
# Returns 0 on success, 1 on failure
Bisu::array_set_v1() {
    local arr_name key val is_assoc tmp_assoc tmp_ref num_keys sorted_idx idx i IFS_bak kv_dump

    # Trim and validate array name
    arr_name="$(Bisu::trim "$1")"
    shift
    Bisu::is_array "$arr_name" || return 1

    # Name reference to target array
    declare -n ref="$arr_name"

    # Detect if array is associative
    if Bisu::is_assoc_array "$arr_name"; then
        is_assoc=1
    else
        is_assoc=0
    fi

    # Process key/value pairs
    while (($# > 1)); do
        key="$(Bisu::trim "$1")"
        val="$2"
        shift 2

        # Skip empty keys
        [[ -z "$key" ]] && continue

        # Associative array fast path
        if ((is_assoc)); then
            ref["$key"]="$val"
            continue
        fi

        # Numeric key -> keep as indexed
        case "$key" in
        '' | *[!0-9]*) ;; # non-numeric -> migration
        *)
            ref["$key"]="$val"
            continue
            ;;
        esac

        # ---------- Migration: indexed -> associative ----------
        # Create unique temp associative container
        tmp_assoc="__arr_mig_${arr_name//[^a-zA-Z0-9_]/}_${BISU_CURRENT_UTIL_PID}_${RANDOM}"
        declare -gA "$tmp_assoc"
        declare -n tmp_ref="$tmp_assoc"

        # Copy existing numeric indices into temp
        num_keys=()
        for i in "${!ref[@]}"; do
            case "$i" in
            '' | *[!0-9]*) ;; # skip non-numeric
            *)
                num_keys+=("$i")
                tmp_ref["$i"]="${ref[$i]}"
                ;;
            esac
        done

        # Clear original and convert to associative
        unset -v "$arr_name"
        declare -gA "$arr_name"
        declare -n ref="$arr_name"

        # Restore numeric entries in ascending order
        if ((${#num_keys[@]})); then
            if ((${#num_keys[@]} > 1)); then
                IFS_bak=$IFS
                IFS=$'\n'
                mapfile -t sorted_idx < <(printf '%s\n' "${num_keys[@]}" | sort -n)
                IFS=$IFS_bak
            else
                sorted_idx=("${num_keys[@]}")
            fi
            for idx in "${sorted_idx[@]}"; do
                ref["$idx"]="${tmp_ref[$idx]}"
            done
        fi

        # Cleanup temporary
        unset -v tmp_ref
        unset -v "$tmp_assoc"

        # Mark as associative and set key
        is_assoc=1
        ref["$key"]="$val"
    done

    return 0
}

# It works well
# Bisu::array_get
# Description:
#   Retrieve the first non-empty value for one or more keys from a Bisu-managed array
#   (indexed or associative). Fully uses Bisu's ref-processing pattern: dump -> set -> rehydrate.
# Usage:
#   Bisu::array_get "array_name" key1 [key2 ...]
# Returns 0 on success (prints value), 1 on failure (prints nothing)
Bisu::array_get_v1() {
    local arr_name key val is_assoc idx

    # Normalize and validate array name
    arr_name="$(Bisu::trim "$1")"
    shift
    Bisu::is_array "$arr_name" || {
        printf ''
        return 1
    }

    # Determine array type (associative or indexed)
    if Bisu::is_assoc_array "$arr_name"; then
        is_assoc=1
    else
        is_assoc=0
    fi

    # Create nameref for target array
    declare -n ref="$arr_name"

    # Iterate keys and return the first non-empty value
    for key in "$@"; do
        [[ -z "$key" ]] && continue
        val=""

        if ((is_assoc)); then
            [[ -v ref["$key"] ]] || continue
            val="${ref[$key]}"
        else
            # Ensure numeric index for indexed array
            case "$key" in
            '' | *[!0-9]*) continue ;;
            *) idx=$key ;;
            esac
            [[ -v ref[$idx] ]] || continue
            val="${ref[$idx]}"
        fi

        [[ -n "$val" ]] && {
            printf '%s' "$val"
            return 0
        }
    done

    # No non-empty value found
    printf ''
    return 1
}

# It works well
# Bisu::output
# Description:
#   Outputs a message with optional style tags, optional newline, and optional logging-only mode.
#   Unknown tags are treated literally. Style tags use an associative map of ANSI codes.
#   No nested functions/sub-functions are used — logic is inlined to comply with constraints.
# Dependencies (assumed to exist and behave correctly):
#   Bisu::trim, Bisu::in_array, Bisu::is_func, Bisu::safe_callfunc, Bisu::assoc_array_merge,
#   Bisu::current_log_file
Bisu::output_v1() {
    # args
    local message="$1"
    local use_newline
    use_newline="$(Bisu::trim "$2")"
    Bisu::in_array "$use_newline" "true" "false" || use_newline="true"
    local log_only
    log_only="$(Bisu::trim "$3")"
    Bisu::in_array "$log_only" "true" "false" || log_only="false"

    # Only attempt tag parsing if message appears to contain '<' and '>'
    if [[ $message == *\<*\>* ]]; then
        # Predefined style codes (associative array)
        declare -A style_codes=(
            [reset]=$'\033[0m' [bold]=$'\033[1m' [dim]=$'\033[2m' [underline]=$'\033[4m'
            [blink]=$'\033[5m' [reverse]=$'\033[7m' [hidden]=$'\033[8m'
            [fg_black]=$'\033[30m' [fg_red]=$'\033[31m' [fg_green]=$'\033[32m' [fg_yellow]=$'\033[33m'
            [fg_orange]=$'\033[38;5;166m' [fg_blue]=$'\033[34m' [fg_magenta]=$'\033[35m'
            [fg_cyan]=$'\033[36m' [fg_white]=$'\033[37m' [fg_bright_black]=$'\033[90m'
            [fg_bright_red]=$'\033[91m' [fg_bright_green]=$'\033[92m' [fg_bright_yellow]=$'\033[93m'
            [fg_bright_blue]=$'\033[94m' [fg_bright_magenta]=$'\033[95m' [fg_bright_cyan]=$'\033[96m'
            [fg_bright_white]=$'\033[97m' [bg_black]=$'\033[40m' [bg_red]=$'\033[41m' [bg_green]=$'\033[42m'
            [bg_yellow]=$'\033[43m' [bg_blue]=$'\033[44m' [bg_magenta]=$'\033[45m' [bg_cyan]=$'\033[46m'
            [bg_white]=$'\033[47m' [bg_bright_black]=$'\033[100m' [bg_bright_red]=$'\033[101m'
            [bg_bright_green]=$'\033[102m' [bg_bright_yellow]=$'\033[103m' [bg_bright_blue]=$'\033[104m'
            [bg_bright_magenta]=$'\033[105m' [bg_bright_cyan]=$'\033[106m' [bg_bright_white]=$'\033[107m'
        )

        # Inject custom style codes if injection function exists
        if Bisu::is_func "$BISU_STYLE_CODE_INJECTION_FUNC"; then
            local injected
            injected="$(Bisu::safe_callfunc "$BISU_STYLE_CODE_INJECTION_FUNC" $(printf '%s ' "$@"))"
            injected="$(Bisu::trim "$injected")"
            if [[ -n "$injected" ]]; then
                # Put injected into an array of one element, then merge into style_codes via assumed helper
                injected=("$injected")
                Bisu::assoc_array_merge "style_codes" "injected" "style_codes"
            fi
        fi

        # Tag stack holds entries like: "<type>:<name>:<start_index>"
        # type is one of "fx" (effects), "fg" (foreground), "bg" (background)
        declare -a tag_stack=()
        local result="" # final output string (with ANSI codes inserted)
        local seg=""    # accumulated literal characters between tags
        local i=0
        local len=${#message}

        # Inline helper: compute outer prefix from current tag_stack
        # (no nested function; computed where needed)
        # Loop through message characters
        while ((i < len)); do
            local ch="${message:i:1}"

            # Normal character accumulation (not a tag start)
            if [[ "$ch" != "<" ]]; then
                seg+="$ch"
                ((i++))
                continue
            fi

            # Potential tag: collect until next '>' (or end)
            local j=$((i + 1))
            local tag_content=""
            while ((j < len)) && [[ "${message:j:1}" != ">" ]]; do
                tag_content+="${message:j:1}"
                ((j++))
            done

            # If we reached end without finding '>', treat '<' as literal
            if ((j >= len)); then
                seg+="$ch"
                ((i++))
                continue
            fi

            # We found a tag candidate; build full tag and advance i past it
            local full_tag="<${tag_content}>"
            i=$((j + 1))

            # Flush accumulated plain segment with appropriate outer prefix
            # Compute outer prefix from tag_stack inline
            local outer_prefix=""
            {
                local found_fx="" found_fg="" found_bg=""
                local entry t n rest
                for entry in "${tag_stack[@]}"; do
                    t="${entry%%:*}"
                    rest="${entry#*:}"
                    n="${rest%%:*}"
                    case "$t" in
                    fx) found_fx="$n" ;;
                    fg) found_fg="$n" ;;
                    bg) found_bg="$n" ;;
                    esac
                done
                [[ -n "$found_fx" ]] && outer_prefix+="${style_codes[$found_fx]}"
                [[ -n "$found_fg" ]] && outer_prefix+="${style_codes[$found_fg]}"
                [[ -n "$found_bg" ]] && outer_prefix+="${style_codes[$found_bg]}"
            }
            if [[ -n "$seg" ]]; then
                if [[ -n "$outer_prefix" ]]; then
                    result+="${outer_prefix}${seg}${style_codes[reset]}"
                else
                    result+="$seg"
                fi
                seg=""
            fi

            # Normalize tag whitespace
            local raw_tag="${tag_content#"${tag_content%%[![:space:]]*}"}"
            raw_tag="${raw_tag%"${raw_tag##*[![:space:]]}"}"
            if [[ -z "$raw_tag" ]]; then
                # empty tag like "<   >", treat literally
                seg+="$full_tag"
                continue
            fi

            # Closing tag handling: starts with '/'
            if [[ "${raw_tag:0:1}" == "/" ]]; then
                local close_name="${raw_tag:1}"
                # If stack empty, treat as literal
                if ((${#tag_stack[@]} == 0)); then
                    seg+="$full_tag"
                    continue
                fi

                # Pop top entry from stack
                local last_idx=$((${#tag_stack[@]} - 1))
                local top="${tag_stack[last_idx]}"
                unset 'tag_stack[last_idx]'
                tag_stack=("${tag_stack[@]}") # reindex

                # Parse top entry: type:name:start_idx
                local ttype rest name start_idx
                ttype="${top%%:*}"
                rest="${top#*:}"
                name="${rest%%:*}"
                start_idx="${rest#*:}"

                # If closing name matches the tag name of the popped entry
                if [[ "$name" == "$close_name" ]]; then
                    local inner_len=$((${#result} - start_idx))
                    if ((inner_len < 0)); then
                        inner_len=0
                    fi
                    local inner="${result:start_idx:inner_len}"
                    result="${result:0:start_idx}"

                    # If we have a known style code for this name and a recognized type, wrap
                    if [[ -n "${style_codes[$name]}" && -n "$ttype" ]]; then
                        # Recompute outer prefix after popping (inline)
                        local outer_after=""
                        {
                            local found_fx="" found_fg="" found_bg=""
                            local entry t n rest2
                            for entry in "${tag_stack[@]}"; do
                                t="${entry%%:*}"
                                rest2="${entry#*:}"
                                n="${rest2%%:*}"
                                case "$t" in
                                fx) found_fx="$n" ;;
                                fg) found_fg="$n" ;;
                                bg) found_bg="$n" ;;
                                esac
                            done
                            [[ -n "$found_fx" ]] && outer_after+="${style_codes[$found_fx]}"
                            [[ -n "$found_fg" ]] && outer_after+="${style_codes[$found_fg]}"
                            [[ -n "$found_bg" ]] && outer_after+="${style_codes[$found_bg]}"
                        }
                        result+="${style_codes[$name]}${inner}${style_codes[reset]}${outer_after}"
                    else
                        # Unknown style name at runtime or no type: just re-insert inner unstyled
                        result+="$inner"
                    fi
                else
                    # Mismatched closing tag: we don't honor ordering; just append inner content back as literal
                    local inner_len=$((${#result} - start_idx))
                    if ((inner_len < 0)); then
                        inner_len=0
                    fi
                    local inner="${result:start_idx:inner_len}"
                    result="${result:0:start_idx}${inner}"
                fi
                continue
            fi

            # Opening tag handling: take first token as tag name
            local tag_name="${raw_tag%%[[:space:]]*}"
            # Determine tag type inline (no helper): fx, fg, bg, or empty
            local ttype=""
            case "$tag_name" in
            fg_*) ttype="fg" ;;
            bg_*) ttype="bg" ;;
            bold | dim | underline | blink | reverse | hidden) ttype="fx" ;;
            *) ttype="" ;;
            esac

            # If known type or known explicit code, push to stack with current result length index
            if [[ -n "$ttype" || -n "${style_codes[$tag_name]}" ]]; then
                tag_stack+=("${ttype}:${tag_name}:${#result}")
            else
                # Unknown tag: treat literally
                result+="$full_tag"
            fi
        done

        # Flush any remaining segment after loop with current outer prefix
        local outer_prefix=""
        {
            local found_fx="" found_fg="" found_bg=""
            local entry t n rest
            for entry in "${tag_stack[@]}"; do
                t="${entry%%:*}"
                rest="${entry#*:}"
                n="${rest%%:*}"
                case "$t" in
                fx) found_fx="$n" ;;
                fg) found_fg="$n" ;;
                bg) found_bg="$n" ;;
                esac
            done
            [[ -n "$found_fx" ]] && outer_prefix+="${style_codes[$found_fx]}"
            [[ -n "$found_fg" ]] && outer_prefix+="${style_codes[$found_fg]}"
            [[ -n "$found_bg" ]] && outer_prefix+="${style_codes[$found_bg]}"
        }
        if [[ -n "$seg" ]]; then
            if [[ -n "$outer_prefix" ]]; then
                result+="${outer_prefix}${seg}${style_codes[reset]}"
            else
                result+="$seg"
            fi
        fi

        # The prepared message becomes result
        message="$result"
    fi

    # Choose printf command according to newline flag
    local command
    if [[ "$use_newline" == "true" ]]; then
        command="printf '%b\\n' \"$message\""
    else
        command="printf '%b' \"$message\""
    fi

    # Execute with folding and logging. Keep behavior: when log_only, suppress stdout.
    if [[ "$log_only" == "true" ]]; then
        eval "$command" |
            { fold -s -w "${BISU_LINE_BREAK_LENGTH:-160}" 2>/dev/null; } |
            tee -a -- "$(Bisu::current_log_file)" &>/dev/null || return 1
    else
        eval "$command" |
            { fold -s -w "${BISU_LINE_BREAK_LENGTH:-160}" 2>/dev/null; } |
            tee -a -- "$(Bisu::current_log_file)" || return 1
    fi

    return 0
}

# It works well
# Bisu::string_join
# Description:
#   Join array elements into a single string with a separator.
#   Preferred signature: Bisu::string_join "array_name" "receiver_var" "sep" [big_spec]
#   Backward-compatible signature: Bisu::string_join "array_name" "sep" [big_spec]
# Params:
#   $1 - source array variable name (required)
#   $2 - either receiver variable name (preferred) OR separator (legacy)
#   $3 - separator (preferred) OR big_spec (legacy)
#   $4 - big_spec (preferred; true/false). Default false.
# Notes:
#   - If receiver_var is provided and valid, the joined string is assigned to it.
#   - If no receiver_var, result is printed to stdout (legacy behavior).
#   - Respects Bisu helper functions: Bisu::trim, Bisu::is_valid_var_name,
#     Bisu::array_is_available, Bisu::in_array, Bisu::set
Bisu::string_join_v1() {
    local src_name raw2_orig raw2_trim sep big_spec receiver joined

    src_name="$(Bisu::trim "$1")"
    raw2_orig="$2"                 # preserve original (untrimmed) second arg (used as sep in legacy mode)
    raw2_trim="$(Bisu::trim "$2")" # trimmed version used only to detect receiver var name

    # Determine whether raw2_trim is a valid receiver var name.
    if [[ -n "$raw2_trim" ]] && Bisu::is_valid_var_name "$raw2_trim"; then
        # Preferred mode: $2 (trimmed) is receiver var name
        receiver="$raw2_trim"
        sep="${3-}" # use raw $3 as separator (do NOT trim)
        big_spec="$(Bisu::trim "${4:-false}")"
    else
        # Legacy mode: $2 is separator — use original untrimmed value
        receiver=""
        sep="${raw2_orig-}"
        big_spec="$(Bisu::trim "${3:-false}")"
    fi

    # Normalize big_spec
    Bisu::in_array "$big_spec" "true" "false" || big_spec="false"

    # Validate source array availability
    declare -n arr_ref="$src_name" 2>/dev/null
    Bisu::array_is_available "$src_name" || {
        # If receiver specified, set it to empty (robust assignment), then fail
        if [[ -n "$receiver" ]]; then
            if declare -n out_ref="$receiver" 2>/dev/null; then
                out_ref=""
            else
                eval "declare -g ${receiver}=\"\"" 2>/dev/null || true
            fi
        else
            printf ''
        fi
        return 1
    }

    # Build joined string using chosen algorithm
    if [[ "$big_spec" == "true" ]]; then
        # Use awk for potentially very large data sets.
        # Pass sep verbatim to awk (-v sep="...") so spaces/comma+space are preserved.
        joined="$(printf '%s\n' "${arr_ref[@]}" | awk -v ORS="" -v sep="$sep" '
        {
            if (NR == 1) out = $0;
            else out = out sep $0;
        }
        END { if (NR == 0) print ""; else print out }' 2>/dev/null)" || {
            # On awk failure, set joined to empty and fail
            joined=""
            if [[ -n "$receiver" ]]; then
                if declare -n out_ref="$receiver" 2>/dev/null; then
                    out_ref="$joined"
                else
                    eval "declare -g ${receiver}=\"\$joined\"" 2>/dev/null || true
                fi
            else
                printf '%s\n' "$joined"
            fi
            return 1
        }
    else
        # Pure Bash join (fast and stable)
        local out="" first=1 elem
        for elem in "${arr_ref[@]}"; do
            if ((first)); then
                out="$elem"
                first=0
            else
                out+="$sep$elem"
            fi
        done
        joined="$out"
    fi

    # Materialize result: if receiver provided, assign to it.
    if [[ -n "$receiver" ]]; then
        if declare -n out_ref="$receiver" 2>/dev/null; then
            out_ref="$joined"
        else
            eval "declare -g ${receiver}=\"\$joined\"" 2>/dev/null || true
        fi
        return 0
    fi

    # Legacy behavior: print to stdout
    printf '%s\n' "$joined"
    return 0
}

# It works well
# Bisu::string_to_array
# Description:
#   Convert an input string into a global array (indexed or associative) using the
#   Bisu-style ref-processing pattern: stage -> dump -> set -> rehydrate.
# Usage:
#   Bisu::string_to_array "<input>" "receiver_array_name" [delim]
# Params:
#   $1 - input string (trimmed). Empty/blank -> return 0 (empty array).
#   $2 - receiver array variable name (required, validated via Bisu::is_valid_var_name).
#   $3 - delimiter for splitting when not newline-delimited (default: single space).
Bisu::string_to_array_v1() {
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

# It works well
# Bisu::array_copy v1
# Description:
#   Copy a Bisu-managed array (indexed or associative) from one variable to another.
#   Preserves array type and follows the canonical ref-processing pattern: dump -> set -> rehydrate.
# Usage:
#   Bisu::array_copy "source_array_name" "destination_array_name"
Bisu::array_copy_v1() {
    local src dst declare_out is_assoc kv_str

    # Normalize and validate names
    src="$(Bisu::trim "$1")"
    dst="$(Bisu::trim "$2")"
    Bisu::is_valid_var_name "$dst" || return 1
    Bisu::is_array "$src" || return 1

    # Safe no-op if source and destination are the same
    [[ "$src" == "$dst" ]] && return 0

    # Determine array type: associative or indexed
    if Bisu::is_assoc_array "$src"; then
        is_assoc="true"
    else
        is_assoc="false"
    fi

    # Prepare named reference for destination and clear existing contents
    declare -n dst_ref="$dst" 2>/dev/null
    dst_ref=()

    # Obtain canonical dump of source array (Bisu pattern)
    kv_str="$(Bisu::array_dump "$src")" || return 1

    # Set the canonical representation into the reference
    Bisu::set "dst_ref" "${kv_str[@]}" || return 1

    # Rehydrate the global array, preserving type
    if [[ "$is_assoc" == "true" ]]; then
        eval "declare -gA ${dst}=($kv_str)" 2>/dev/null || return 1
    else
        eval "declare -ga ${dst}=($kv_str)" 2>/dev/null || return 1
    fi

    return 0
}

# Uncertain for correctness/robustness
# Method: Bisu::array_splice
# Description: To remove elements from an array
Bisu::array_splice_v1() {
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

# Uncertain for correctness/robustness
# Method: Bisu::indexed_array_merge
# Description: Function to merge 2 arrays into arg3, according to arg3's array name
Bisu::indexed_array_merge_v1() {
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

# Uncertain for correctness/robustness
# Method: Bisu::assoc_array_merge
# Description: Merge 2 associative arrays into arg3 (dest associative array)
Bisu::assoc_array_merge_v1() {
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

# Uncertain for correctness/robustness
# Function to add an element to a specified global array from the bottom
Bisu::array_push_v1() {
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

# Uncertain for correctness/robustness
# Function to add an element to a specified global array from the top
Bisu::array_unshift_v1() {
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

# Uncertain for correctness/robustness
# Bisu::array_unique
# Description:
#   Remove duplicate values from a global Bisu-managed array (preserve first-appearance order).
#   Final result is written back to the same named array as an indexed array.
# Usage:
#   Bisu::array_unique "array_name"
# Notes:
#   - Assumes Bisu helpers exist: Bisu::trim, Bisu::is_array, Bisu::array_dump, Bisu::set.
#   - If the array does not exist, returns non-zero. If called with only the array name, behavior
#     matches original: nothing to do and return 0.
Bisu::array_unique_v1() {
    local arr_name="${1:+$(Bisu::trim "$1")}"
    local tmp_name kv_str
    local -a unique_vals
    declare -A seen
    local v

    # Validate input / existence
    if [[ -z "$arr_name" ]]; then
        return 1
    fi
    Bisu::is_array "$arr_name" || return 1

    # If caller passed only name (same as original's $# -eq 1 early-return), nothing to do.
    # The original returned 0 in that case; preserve that contract.
    if [[ $# -eq 1 ]]; then
        return 0
    fi

    # Read source array by nameref to avoid copies and to be safe if arr_name is large.
    declare -n src_ref="$arr_name" 2>/dev/null || return 1

    # Build unique list preserving first-appearance order
    unique_vals=()
    seen=()
    for v in "${src_ref[@]}"; do
        if [[ -z ${seen[$v]+x} ]]; then
            unique_vals+=("$v")
            seen["$v"]=1
        fi
    done

    # Prepare a low-collision temporary global indexed array to produce canonical dump
    tmp_name="bisu_unique_tmp_${$}_${RANDOM}_${RANDOM}"
    eval "declare -ga ${tmp_name}=()" 2>/dev/null || return 1
    declare -n work="$tmp_name" 2>/dev/null || {
        unset -v "$tmp_name" 2>/dev/null || true
        return 1
    }

    # Populate the temporary working array with the unique values
    work=("${unique_vals[@]}")

    # Obtain canonical dump of the working array (so Bisu::set gets canonical representation)
    kv_str="$(Bisu::array_dump "$tmp_name")" || {
        unset -v "$tmp_name" 2>/dev/null || true
        return 1
    }

    # Prepare destination named reference and clear existing content (best-effort)
    declare -n dst_ref="$arr_name" 2>/dev/null || {
        unset -v "$tmp_name" 2>/dev/null || true
        return 1
    }
    dst_ref=()

    # Use Bisu::set to place canonical representation into the named reference
    Bisu::set "dst_ref" "${kv_str[@]}" || {
        unset -v "$tmp_name" 2>/dev/null || true
        return 1
    }

    # Rehydrate the global destination as an indexed array (this matches original's
    # behavior which assigned via (...)= making it indexed)
    eval "declare -ga ${arr_name}=($kv_str)" 2>/dev/null || {
        unset -v "$tmp_name" 2>/dev/null || true
        return 1
    }

    # Cleanup temporary working array
    unset -v "$tmp_name" 2>/dev/null || true

    return 0
}

# Uncertain for correctness/robustness
# ---------------------------------------
# Bisu::array_keys <array_name> [pattern]
# Returns all keys of the array.
# ---------------------------------------
Bisu::array_keys_v1() {
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

# Uncertain for correctness/robustness
# --------------------------------------------
# Bisu::array_values <array_name> [pattern]
# Returns all values of the array.
# --------------------------------------------
Bisu::array_values_v1() {
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

# Uncertain for correctness/robustness
# ------------------------------------------------------------
# Bisu::array_search <array_name> <search_value>
# Returns all keys where array value matches search_value.
# ------------------------------------------------------------
Bisu::array_search_v1() {
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

# Uncertain for correctness/robustness
# Bisu::array_unshift
# Description:
#   Prepend a value to a Bisu-managed global array (indexed or associative).
#   Uses Bisu ref-processing: dump -> set -> rehydrate.
# Usage:
#   Bisu::array_unshift "array_name" "new_value" ["string"|"int"|"float"] [unique:false|true]
Bisu::array_unshift_v1() {
    local array_name new_value value_type unique
    local declare_out is_assoc
    local tmp_name tmp_ref kv_str element min_key candidate

    # Normalize & defaults
    array_name="$(Bisu::trim "$1")"
    new_value="$2"
    value_type="$(Bisu::trim "${3:-string}")"
    unique="$(Bisu::trim "${4:-false}")"
    Bisu::in_array "$unique" "true" "false" || unique="false"
    value_type="${value_type:-string}"

    # Ensure the global array exists
    if ! Bisu::is_array "$array_name"; then
        Bisu::error_log "Array ${array_name} does not exist."
        return 1
    fi

    # Validate value type
    case "$value_type" in
    int)
        if ! Bisu::is_int "$new_value"; then
            Bisu::error_log "Value must be an integer."
            return 1
        fi
        ;;
    float)
        if ! Bisu::is_float "$new_value"; then
            Bisu::error_log "Value must be a float."
            return 1
        fi
        ;;
    string)
        # no-op
        ;;
    *)
        Bisu::error_log "Invalid type specified. Use string, int, or float."
        return 1
        ;;
    esac

    # Detect array type (assoc vs indexed) using same approach as array_copy
    if Bisu::is_assoc_array "$array_name"; then
        is_assoc="true"
    else
        is_assoc="false"
    fi

    # === Create working copy via canonical dump -> set -> rehydrate ===
    # Use unique temporary name to avoid collisions and ensure cleanup.
    tmp_name="bisu_unshift_tmp_${$}_${RANDOM}_${RANDOM}"

    # 1) Obtain canonical dump of source array
    kv_str="$(Bisu::array_dump "$array_name")" || return 1

    # 2) Prepare working named reference and seed it with canonical representation
    #    so Bisu::set can write the canonical fields into the working ref.
    declare -n tmp_ref="$tmp_name" 2>/dev/null || true
    tmp_ref=()
    Bisu::set "tmp_ref" "${kv_str[@]}" || return 1

    # 3) Rehydrate working copy preserving type
    if [[ "$is_assoc" == "true" ]]; then
        eval "declare -gA ${tmp_name}=($kv_str)" 2>/dev/null || return 1
    else
        eval "declare -ga ${tmp_name}=($kv_str)" 2>/dev/null || return 1
    fi

    # Re-bind tmp_ref to the rehydrated working array (safe access)
    declare -n tmp_ref="$tmp_name" 2>/dev/null || {
        unset -v "$tmp_name" 2>/dev/null || true
        return 1
    }

    # === uniqueness check (if requested) ===
    if [[ "$unique" == "true" ]]; then
        for element in "${tmp_ref[@]}"; do
            if [[ "$element" == "$new_value" ]]; then
                # Already present; nothing to do
                unset -v "$tmp_name" 2>/dev/null || true
                return 0
            fi
        done
    fi

    # === perform unshift on working copy ===
    if [[ "$is_assoc" == "true" ]]; then
        # find minimum numeric key and use min_key - 1 to prepend
        min_key=
        for element in "${!tmp_ref[@]}"; do
            if [[ "$element" =~ ^-?[0-9]+$ ]]; then
                if [[ -z "$min_key" ]]; then
                    min_key="$element"
                else
                    # numeric compare
                    if ((element < min_key)); then
                        min_key="$element"
                    fi
                fi
            fi
        done
        if [[ -z "$min_key" ]]; then
            min_key=0
        fi
        candidate=$((min_key - 1))
        # assign new value under computed numeric key on working copy
        # use eval so variable expansions are correct and safe
        eval "${tmp_name}[${candidate}]=\$new_value"
    else
        # indexed: prepend - ensure proper quoting
        eval "${tmp_name}=(\"\$new_value\" \"\${${tmp_name}[@]}\")"
    fi

    # === write modified working copy back to the real global array ===
    kv_str="$(Bisu::array_dump "$tmp_name")" || {
        unset -v "$tmp_name" 2>/dev/null || true
        return 1
    }

    # prepare destination reference and clear existing contents (best-effort)
    declare -n dst_ref="$array_name" 2>/dev/null || {
        unset -v "$tmp_name" 2>/dev/null || true
        return 1
    }
    dst_ref=()

    Bisu::set "dst_ref" "${kv_str[@]}" || {
        unset -v "$tmp_name" 2>/dev/null || true
        return 1
    }

    # Rehydrate target preserving original type
    if [[ "$is_assoc" == "true" ]]; then
        eval "declare -gA ${array_name}=($kv_str)" 2>/dev/null || {
            unset -v "$tmp_name" 2>/dev/null || true
            return 1
        }
    else
        eval "declare -ga ${array_name}=($kv_str)" 2>/dev/null || {
            unset -v "$tmp_name" 2>/dev/null || true
            return 1
        }
    fi

    # Cleanup working temporary array
    unset -v "$tmp_name" 2>/dev/null || true

    return 0
}

# Uncertain for correctness/robustness
# Bisu::array_pop
# Description:
#   Remove the last element from a Bisu-managed array (indexed or associative)
#   and store it into an external variable via reference.
# Usage:
#   Bisu::array_pop "array_name" "value_var_name"
# Returns 0 on success, 1 if array is empty or invalid
Bisu::array_pop_v1() {
    local arr_name val_name last_key

    # Normalize and validate array name
    arr_name="$(Bisu::trim "$1")"
    Bisu::isset "$arr_name" || return 1

    # Ensure array is not empty
    [ "$(Bisu::array_count "$arr_name")" -gt 0 ] || return 1

    # Name references for array and external variable
    val_name="$(Bisu::trim "$2")"
    declare -n arr="$arr_name"
    declare -n val_ref="$val_name"

    # Determine the last key
    last_key=$(printf '%s\n' "${!arr[@]}" | tail -n1 2>/dev/null)
    [ -n "$last_key" ] || return 1

    # Assign value to external reference if valid
    Bisu::is_valid_var_name "$val_name" && val_ref="${arr[$last_key]}" 2>/dev/null

    # Remove the last element
    if Bisu::is_assoc_array "$arr_name"; then
        unset 'arr[$last_key]' 2>/dev/null
    else
        # Slice indexed array up to but excluding last index
        arr=("${arr[@]:0:$last_key}")
    fi

    return 0
}

# Uncertain for correctness/robustness
# Bisu::dump an array's elements into string
Bisu::array_dump_v1() {
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

# It works well
# Bisu::array_dump v2
# Description:
#   Serialize a Bisu-managed array (indexed or associative) into a canonical string representation.
#   Supports Bash5 indexed arrays and associative arrays.
# Usage:
#   kv_str=$(Bisu::array_dump "array_name")
Bisu::array_dump_v2() {
    local array_name kv_str declare_out

    # Normalize the input array name
    array_name=$(Bisu::trim "$1")
    [ -n "$array_name" ] || {
        printf ''
        return 1
    }

    # Determine if array is indexed or associative
    if Bisu::is_indexed_array "$array_name"; then
        # Indexed array
        local -a temp_array
        # Attempt robust element extraction
        if ! eval "mapfile -t temp_array < <(printf '%s\0' \"\${${array_name}[@]}\" 2>/dev/null | xargs -0 -n1 printf '%s\n' 2>/dev/null)"; then
            # Fallback if streaming fails
            eval "temp_array=(\"\${${array_name}[@]}\")" &>/dev/null || {
                printf ''
                return 1
            }
        fi

        # Canonical quoting of elements
        local IFS=$' '
        kv_str=$(printf '%s\n' "${temp_array[@]}" |
            awk '{
                gsub(/'\''/, "'\''\\'\'''\''");  # Escape single quotes
                printf "'\''%s'\'' ", $0
            }
            END {
                if (NR > 0) printf "\n"
            }' 2>/dev/null)

        printf '%s\n' "$(Bisu::trim "$kv_str")"
        return 0
    elif Bisu::is_assoc_array "$array_name"; then
        # Associative array
        local p kv
        if p="$(declare -p "$array_name" 2>/dev/null)"; then
            # Extract literal payload after '='
            kv="${p#*=}"
            # Strip top-level quotes if present
            case "$kv" in
            \'*\') kv="${kv:1:-1}" ;;
            \"*\") kv="${kv:1:-1}" ;;
            esac
            kv=$(Bisu::trim "$kv" "() ")
            printf '%s\n' "$kv"
            return 0
        fi
    fi

    # If not an array or extraction fails, return empty
    printf ''
    return 1
}

# Uncertain for correctness/robustness
# Bisu::sign_array
# Description:
#   Compute a deterministic MD5 signature of a Bisu-managed array (indexed or associative)
#   based on its canonical dumped contents.
# Usage:
#   Bisu::sign_array "array_name"
Bisu::sign_array_v1() {
    local array_name trimmed_contents array_md5

    # Normalize array name
    array_name="$(Bisu::trim "$1")"

    # Safely copy the array into a local variable using canonical ref-processing
    Bisu::array_copy "$array_name" "trimmed_contents" || {
        printf ''
        return 1
    }

    # If the array is empty, return empty
    [[ ${#trimmed_contents[@]} -eq 0 ]] && {
        printf ''
        return 1
    }

    # Compute MD5 hash from canonical array contents
    array_md5=$(printf '%s\n' "${trimmed_contents[@]}" 2>/dev/null | md5sum 2>/dev/null | awk '{print $1}' 2>/dev/null)

    # If MD5 computation failed, return empty
    [[ -z "$array_md5" ]] && {
        printf ''
        return 1
    }

    # Output the array signature
    printf '%s' "$array_md5"
    return 0
}

# It has issues
# Function to acquire a lock to prevent multiple instances
Bisu::acquire_lock_v1() {
    local lock_file=$(Bisu::current_lock_file)
    [ -n "$lock_file" ] || Bisu::error_exit "❗️ Failed to acquire 🔒 lock."
    exec 200>"$lock_file" 2>/dev/null || Bisu::error_exit "❗️ Cannot open 🔒 lock file: $lock_file"
    flock -n 200 2>/dev/null || {
        Bisu::lock_held
        Bisu::error_exit "🔒 An instance is running: $lock_file"
    }
}

# It works well
# ──────────────────────────────────────────────────────────────
# Robust singleton flock set – works everywhere
# ──────────────────────────────────────────────────────────────

Bisu::acquire_lock_v2() {
    local lock_file=$(Bisu::current_lock_file)
    [ -n "$lock_file" ] || Bisu::error_exit "Failed to acquire 🔒 lock(1)"
    exec 200>"$lock_file" 2>/dev/null || Bisu::error_exit "Cannot open 🔒 lock file: $lock_file"

    if ! flock -x -n 200 2>/dev/null; then
        Bisu::error_exit "An instance is running: $lock_file" 1 "🔒"
    fi
    if flock -x -n 200 2>/dev/null; then
        Bisu::lock_set
    fi
    Bisu::lock_is_set || {
        Bisu::saferm "$lock_file"
        Bisu::error_exit "Failed to acquire 🔒 lock(2)"
    }

    echo "$BISU_CURRENT_UTIL_PID" >&200
    return 0
}

# It has issues
# Function to release the lock
Bisu::release_lock_v1() {
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

# It works well
# ──────────────────────────────────────────────────────────────
# Robust singleton flock clean – works everywhere
# ──────────────────────────────────────────────────────────────
Bisu::release_lock_v2() {
    Bisu::lock_is_set || return 0
    local lock_file=$(Bisu::current_lock_file)
    # Unlock + close fd 200, this automatically removes the kernel lock
    flock -u 200 2>/dev/null && {
        exec 200>&- && Bisu::saferm "$lock_file" || {
            Bisu::error_log "Failed to remove lock file: ${lock_file}"
            return 1
        }
    }

    Bisu::log_msg "✅ Released 🔒 lock_file: ${lock_file}" "true"
    return 0
}

# It works well
# Truly random string with zero bias and no structural patterns
Bisu::random_string_v1() {
    local length byte alphabet result idx max alpha_len
    length=$(Bisu::trim "${1:-21}")
    Bisu::is_posi_int "$length" || {
        printf ""
        return 1
    }
    type=$(Bisu::trim "${2:-base62}")

    # Alphabet selection
    case "$type" in
    base10) alphabet='0123456789' ;;
    base26) alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZ' ;;
    base36) alphabet='0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ' ;;
    base62) alphabet='0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ' ;;
    base64) alphabet='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/' ;;
    *)
        printf ""
        return 1
        ;;
    esac

    alpha_len=${#alphabet}
    max=$((256 / alpha_len * alpha_len)) # rejection sampling

    result=""
    while ((${#result} < length)); do
        # read 1 byte from /dev/urandom
        IFS= read -r -N1 byte </dev/urandom || {
            printf ""
            return 1
        }
        # convert to numeric
        byte=$(printf '%d' "'$byte")
        ((byte < max)) || continue # rejection if out of range
        idx=$((byte % alpha_len))
        result+=${alphabet:idx:1}
    done

    printf '%s' "$result"
    return 0
}

# It works well
# To generate a random number
# Usage: Bisu::random_number <length>
Bisu::random_number_v1() {
    local length
    length=$(Bisu::trim "${1:-6}")
    Bisu::is_posi_int "$length" || {
        printf ""
        return 1
    }

    local legality_ensured
    legality_ensured=$(Bisu::trim "$2")
    Bisu::in_array "$legality_ensured" "true" "false" || legality_ensured="false"

    local number
    number=$(Bisu::random_string "$length" "base10")
    if [[ "$legality_ensured" == "true" && "$number" == 0* ]]; then
        local first_non_zero
        first_non_zero=$(((RANDOM % 9) + 1))
        number="${first_non_zero}${number:1}"
    fi

    printf '%s' "$number"
    return 0
}

# It works well
# Generate a secure random UUIDv4 (128 bits)
Bisu::uuidv4_v1() {
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
