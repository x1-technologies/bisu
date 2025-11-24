#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
# shellcheck disable=SC2170,SC2219,SC2090,SC2190,SC2145,SC2294,SC2124,SC2139,SC2163,SC2043,SC2292,SC2250
################################################################# BISU Archived Functions ######################################################################
# Version: v1-20251124Z1

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

# Having issues with output format
# Function: Bisu::output a message
Bisu::output_v1() {
    local message="$1"
    local use_newline=$(Bisu::trim "$2")
    Bisu::in_array "$use_newline" "true" "false" || use_newline="true"
    local log_only=$(Bisu::trim "$3")
    Bisu::in_array "$log_only" "true" "false" || log_only="false"

    # Style tag parsing
    [[ $message == *\<*\>* ]] && {
        # style table
        declare -A style_codes=(
            [reset]=$'\033[0m' [bold]=$'\033[1m' [dim]=$'\033[2m' [underline]=$'\033[4m'
            [blink]=$'\033[5m' [reverse]=$'\033[7m' [hidden]=$'\033[8m'
            [fg_black]=$'\033[30m' [fg_red]=$'\033[31m' [fg_green]=$'\033[32m' [fg_yellow]=$'\033[33m' [fg_orange]=$'\033[38;5;166m'
            [fg_blue]=$'\033[34m' [fg_magenta]=$'\033[35m' [fg_cyan]=$'\033[36m' [fg_white]=$'\033[37m'
            [fg_bright_black]=$'\033[90m' [fg_bright_red]=$'\033[91m' [fg_bright_green]=$'\033[92m'
            [fg_bright_yellow]=$'\033[93m' [fg_bright_blue]=$'\033[94m' [fg_bright_magenta]=$'\033[95m'
            [fg_bright_cyan]=$'\033[96m' [fg_bright_white]=$'\033[97m'
            [bg_black]=$'\033[40m' [bg_red]=$'\033[41m' [bg_green]=$'\033[42m' [bg_yellow]=$'\033[43m'
            [bg_blue]=$'\033[44m' [bg_magenta]=$'\033[45m' [bg_cyan]=$'\033[46m' [bg_white]=$'\033[47m'
            [bg_bright_black]=$'\033[100m' [bg_bright_red]=$'\033[101m' [bg_bright_green]=$'\033[102m'
            [bg_bright_yellow]=$'\033[103m' [bg_bright_blue]=$'\033[104m' [bg_bright_magenta]=$'\033[105m'
            [bg_bright_cyan]=$'\033[106m' [bg_bright_white]=$'\033[107m'
        )
        # Inject customized style codes
        if Bisu::is_func "$BISU_STYLE_CODE_INJECTION_FUNC"; then
            local injected_style_codes="$(Bisu::safe_callfunc "$BISU_STYLE_CODE_INJECTION_FUNC" $(printf '%s ' "$@"))"
            injected_style_codes="$(Bisu::trim "$injected_style_codes")"
            [ -n "$injected_style_codes" ] && {
                injected_style_codes=("$injected_style_codes")
                Bisu::assoc_array_merge "style_codes" "injected_style_codes" "style_codes"
            }
        fi

        # Stack of open tags: each entry "ttype:name:start_index"
        # ttype is one of: fx, fg, bg, or "" for unknown (we still track to enforce positional pairing)
        declare -a tag_stack=()

        result="" # built Bisu::output without tag symbols
        seg=""    # accumulating plain text segment
        i=0
        len=${#message}

        # helper: determine tag type from tag name
        _tag_type() {
            case "$1" in
            fg_*) echo "fg" ;;
            bg_*) echo "bg" ;;
            bold | dim | underline | blink | reverse | hidden) echo "fx" ;;
            *) echo "" ;;
            esac
        }

        # helper: compute current outer prefix (top of each type in remaining stack)
        _outer_prefix_from_stack() {
            local prefix=""
            # iterate stack left->right to find last occurrence per type
            local t="" n="" start=""
            local found_fx="" found_fg="" found_bg=""
            for entry in "${tag_stack[@]}"; do
                t="${entry%%:*}"
                n="${entry#*:}"
                n="${n%%:*}" # remove possible :start if present
                case "$t" in
                fx) found_fx="$n" ;;
                fg) found_fg="$n" ;;
                bg) found_bg="$n" ;;
                esac
            done
            [[ -n "$found_fx" ]] && prefix+="${style_codes[$found_fx]}"
            [[ -n "$found_fg" ]] && prefix+="${style_codes[$found_fg]}"
            [[ -n "$found_bg" ]] && prefix+="${style_codes[$found_bg]}"
            printf "%s" "$prefix"
        }

        # single-pass parse
        while ((i < len)); do
            ch="${message:i:1}"

            # ordinary char: accumulate
            if [[ "$ch" != "<" ]]; then
                seg+="$ch"
                ((i++))
                continue
            fi

            # encountered '<' — try to read tag up to next '>'
            j=$((i + 1))
            tag_content=""
            while ((j < len)) && [[ "${message:j:1}" != ">" ]]; do
                tag_content+="${message:j:1}"
                ((j++))
            done

            # if no closing '>' found: treat '<' as literal
            if ((j >= len)); then
                seg+="$ch"
                ((i++))
                continue
            fi

            # We have a full tag: <tag_content>
            full_tag="<${tag_content}>"
            i=$((j + 1)) # advance past '>'

            # Flush accumulated segment with current outer prefix
            outer_prefix="$(_outer_prefix_from_stack)"
            if [[ -n "$seg" ]]; then
                if [[ -n "$outer_prefix" ]]; then
                    result+="${outer_prefix}${seg}${style_codes[reset]}"
                else
                    result+="$seg"
                fi
                seg=""
            fi

            # Normalize tag name: first token up to whitespace (names allow letters/digits/underscore/hyphen)
            raw_tag="$tag_content"
            # strip leading and trailing spaces
            raw_tag="${raw_tag#"${raw_tag%%[![:space:]]*}"}"
            raw_tag="${raw_tag%"${raw_tag##*[![:space:]]}"}"
            if [[ -z "$raw_tag" ]]; then
                # Per rule: paired-but-incorrect symbol removal applies only when closed; single empty tag stay literal now
                seg+="$full_tag"
                continue
            fi

            # Check if closing tag
            if [[ "${raw_tag:0:1}" == "/" ]]; then
                close_name="${raw_tag:1}"
                # If no open tag => unmatched closing, treat literal
                if ((${#tag_stack[@]} == 0)); then
                    seg+="$full_tag"
                    continue
                fi

                # top format: "ttype:name:start"
                top="${tag_stack[-1]}"
                unset 'tag_stack[-1]'
                tag_stack=("${tag_stack[@]}") # reindex
                ttype="${top%%:*}"
                rest="${top#*:}"
                name="${rest%%:*}"
                start_idx="${rest#*:}"

                # If names match -> positional pairing succeeded
                if [[ "$name" == "$close_name" ]]; then
                    # extract inner content that resides in result[start_idx:]
                    inner_len=$((${#result} - start_idx))
                    inner="${result:start_idx:inner_len}"
                    # remove inner from result to replace with styled/kept content
                    result="${result:0:start_idx}"

                    # If tag name maps to a style, apply style wrapper
                    if [[ -n "${style_codes[$name]}" && -n "$ttype" ]]; then
                        # Build outer-prefix after popping current (to restore outers)
                        outer_prefix="$(_outer_prefix_from_stack)"
                        # Compose: style_of_name + inner + reset + outer_prefix
                        result+="${style_codes[$name]}${inner}${style_codes[reset]}${outer_prefix}"
                    else
                        # Known positional pair but name not a style (or unknown type): remove tag symbols only, keep inner unchanged.
                        result+="${inner}"
                    fi
                else
                    # Names mismatch — per rule: remove tag symbols only (keep inner)
                    inner_len=$((${#result} - start_idx))
                    inner="${result:start_idx:inner_len}"
                    result="${result:0:start_idx}${inner}"
                    # Do NOT reapply any outer prefix here (outer remains as is)
                fi

                continue
            fi

            # Opening tag processing
            tag_name="${raw_tag%%[[:space:]]*}"
            ttype="$(_tag_type "$tag_name")"
            tag_stack+=("${ttype}:${tag_name}:${#result}")
            continue
        done

        # End of input: flush trailing seg
        outer_prefix="$(_outer_prefix_from_stack)"
        if [[ -n "$seg" ]]; then
            if [[ -n "$outer_prefix" ]]; then
                result+="${outer_prefix}${seg}${style_codes[reset]}"
            else
                result+="$seg"
            fi
        fi

        # Build a temporary buffer and reinsert at recorded offsets.
        if ((${#tag_stack[@]})); then
            tmp_result=""
            i=0
            idx_stack=0

            for entry in "${tag_stack[@]}"; do
                # entry format ttype:name:start
                name="${entry#*:}"
                name="${name%%:*}"
                tmp_result+="<${name}>"
            done
            result+="$tmp_result"
        fi

        # Final mutate
        message="$result"
    }

    local command
    if [[ "$use_newline" == "true" ]]; then
        command="printf '%b\\n' \"$message\""
    else
        command="printf '%b' \"$message\""
    fi

    if [[ "$log_only" == "true" ]]; then
        eval "$(printf '%s ' "$command")" |
            { Bisu::debug_mode_on && fold -s -w "$BISU_LINE_BREAK_LENGTH" || fold -s -w "$BISU_LINE_BREAK_LENGTH" 2>/dev/null; } |
            tee -a -- "$(Bisu::current_log_file)" &>/dev/null ||
            return 1
    else
        eval "$(printf '%s ' "$command")" |
            { Bisu::debug_mode_on && fold -s -w "$BISU_LINE_BREAK_LENGTH" || fold -s -w "$BISU_LINE_BREAK_LENGTH" 2>/dev/null; } |
            { Bisu::debug_mode_on && tee -a -- "$(Bisu::current_log_file)" || tee -a -- "$(Bisu::current_log_file)" 2>/dev/null; } ||
            return 1
    fi

    return 0
}

# archived work, works correctly
# Function: Bisu::output
# Description: Outputs a message with optional styles, newline, and logging support.
#              Unknown tags are treated as literal placeholders.
Bisu::output_v2() {
    local message="$1"
    local use_newline=$(Bisu::trim "$2")
    Bisu::in_array "$use_newline" "true" "false" || use_newline="true"
    local log_only=$(Bisu::trim "$3")
    Bisu::in_array "$log_only" "true" "false" || log_only="false"

    # Only parse style tags if message contains '<' and '>'
    if [[ $message == *\<*\>* ]]; then
        # Predefined style codes
        declare -A style_codes=(
            [reset]=$'\033[0m' [bold]=$'\033[1m' [dim]=$'\033[2m' [underline]=$'\033[4m'
            [blink]=$'\033[5m' [reverse]=$'\033[7m' [hidden]=$'\033[8m'
            [fg_black]=$'\033[30m' [fg_red]=$'\033[31m' [fg_green]=$'\033[32m' [fg_yellow]=$'\033[33m' [fg_orange]=$'\033[38;5;166m'
            [fg_blue]=$'\033[34m' [fg_magenta]=$'\033[35m' [fg_cyan]=$'\033[36m' [fg_white]=$'\033[37m'
            [fg_bright_black]=$'\033[90m' [fg_bright_red]=$'\033[91m' [fg_bright_green]=$'\033[92m'
            [fg_bright_yellow]=$'\033[93m' [fg_bright_blue]=$'\033[94m' [fg_bright_magenta]=$'\033[95m'
            [fg_bright_cyan]=$'\033[96m' [fg_bright_white]=$'\033[97m'
            [bg_black]=$'\033[40m' [bg_red]=$'\033[41m' [bg_green]=$'\033[42m' [bg_yellow]=$'\033[43m'
            [bg_blue]=$'\033[44m' [bg_magenta]=$'\033[45m' [bg_cyan]=$'\033[46m' [bg_white]=$'\033[47m'
            [bg_bright_black]=$'\033[100m' [bg_bright_red]=$'\033[101m' [bg_bright_green]=$'\033[102m'
            [bg_bright_yellow]=$'\033[103m' [bg_bright_blue]=$'\033[104m' [bg_bright_magenta]=$'\033[105m'
            [bg_bright_cyan]=$'\033[106m' [bg_bright_white]=$'\033[107m'
        )

        # Inject custom style codes if function exists
        if Bisu::is_func "$BISU_STYLE_CODE_INJECTION_FUNC"; then
            local injected="$(Bisu::safe_callfunc "$BISU_STYLE_CODE_INJECTION_FUNC" $(printf '%s ' "$@"))"
            injected="$(Bisu::trim "$injected")"
            [ -n "$injected" ] && {
                injected=("$injected")
                Bisu::assoc_array_merge "style_codes" "injected" "style_codes"
            }
        fi

        declare -a tag_stack=() # stack for open style tags
        local result=""         # final output string
        local seg=""            # accumulating normal text
        local i=0 len=${#message}

        # Determine tag type
        _tag_type() {
            case "$1" in
            fg_*) echo "fg" ;;
            bg_*) echo "bg" ;;
            bold | dim | underline | blink | reverse | hidden) echo "fx" ;;
            *) echo "" ;;
            esac
        }

        # Compute outer prefix from remaining stack
        _outer_prefix_from_stack() {
            local prefix="" t n
            local found_fx="" found_fg="" found_bg=""
            for entry in "${tag_stack[@]}"; do
                t="${entry%%:*}"
                n="${entry#*:}"
                n="${n%%:*}"
                case "$t" in
                fx) found_fx="$n" ;;
                fg) found_fg="$n" ;;
                bg) found_bg="$n" ;;
                esac
            done
            [[ -n "$found_fx" ]] && prefix+="${style_codes[$found_fx]}"
            [[ -n "$found_fg" ]] && prefix+="${style_codes[$found_fg]}"
            [[ -n "$found_bg" ]] && prefix+="${style_codes[$found_bg]}"
            printf "%s" "$prefix"
        }

        while ((i < len)); do
            local ch="${message:i:1}"

            # Normal character accumulation
            if [[ "$ch" != "<" ]]; then
                seg+="$ch"
                ((i++))
                continue
            fi

            # Potential tag
            local j=$((i + 1)) tag_content=""
            while ((j < len)) && [[ "${message:j:1}" != ">" ]]; do
                tag_content+="${message:j:1}"
                ((j++))
            done

            # No closing '>', treat as literal
            if ((j >= len)); then
                seg+="$ch"
                ((i++))
                continue
            fi

            local full_tag="<${tag_content}>"
            i=$((j + 1)) # move past '>'

            # Flush accumulated segment
            local outer="$(_outer_prefix_from_stack)"
            [[ -n "$seg" ]] && {
                [[ -n "$outer" ]] && result+="${outer}${seg}${style_codes[reset]}" || result+="$seg"
                seg=""
            }

            # Normalize tag
            local raw_tag="${tag_content#"${tag_content%%[![:space:]]*}"}"
            raw_tag="${raw_tag%"${raw_tag##*[![:space:]]}"}"
            [[ -z "$raw_tag" ]] && {
                seg+="$full_tag"
                continue
            }

            # Closing tag
            if [[ "${raw_tag:0:1}" == "/" ]]; then
                local close_name="${raw_tag:1}"
                if ((${#tag_stack[@]} == 0)); then
                    seg+="$full_tag"
                    continue
                fi
                local top="${tag_stack[-1]}"
                unset 'tag_stack[-1]'
                tag_stack=("${tag_stack[@]}")
                local ttype="${top%%:*}"
                local rest="${top#*:}"
                local name="${rest%%:*}"
                local start_idx="${rest#*:}"
                if [[ "$name" == "$close_name" ]]; then
                    local inner_len=$((${#result} - start_idx))
                    local inner="${result:start_idx:inner_len}"
                    result="${result:0:start_idx}"
                    [[ -n "${style_codes[$name]}" && -n "$ttype" ]] && {
                        outer="$(_outer_prefix_from_stack)"
                        result+="${style_codes[$name]}${inner}${style_codes[reset]}${outer}"
                    } || result+="$inner"
                else
                    local inner_len=$((${#result} - start_idx))
                    local inner="${result:start_idx:inner_len}"
                    result="${result:0:start_idx}${inner}"
                fi
                continue
            fi

            # Opening tag
            local tag_name="${raw_tag%%[[:space:]]*}"
            local ttype="$(_tag_type "$tag_name")"
            if [[ -n "$ttype" || -n "${style_codes[$tag_name]}" ]]; then
                tag_stack+=("${ttype}:${tag_name}:${#result}")
            else
                # unknown tag, treat literally
                result+="$full_tag"
            fi
        done

        # Flush remaining segment
        local outer="$(_outer_prefix_from_stack)"
        [[ -n "$seg" ]] && { [[ -n "$outer" ]] && result+="${outer}${seg}${style_codes[reset]}" || result+="$seg"; }

        message="$result"
    fi

    # Prepare printf
    local command
    [[ "$use_newline" == "true" ]] && command="printf '%b\\n' \"$message\"" || command="printf '%b' \"$message\""

    # Execute with logging and folding
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
