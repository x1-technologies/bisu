#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2071,SC1087,SC2159,SC2070,SC2155,SC2046,SC2206,SC2154,SC2157,SC2128,SC2120,SC2178,SC2086,SC2009,SC2015,SC2004,SC2005,SC1003,SC1091,SC2034
# shellcheck disable=SC2207,SC2181,SC2018,SC2019,SC2059,SC2317,SC2064,SC2188,SC1090,SC2106,SC2329,SC2235,SC1091,SC2153,SC2076,SC2102,SC2324,SC2283,SC2179,SC2162
# shellcheck disable=SC2170,SC2219,SC2090,SC2190,SC2145,SC2294,SC2124
# ================================================================ Bash OOP Engine Start =======================================================================
# Version: v7-20250821Z1
# Wrapper for sed to handle extended regex compatibly across systems.
class.sed() { sed -E "$@" 2>/dev/null; } || class.sed() { sed -r "$@" 2>/dev/null; }

class.trim() {
    local str="$1"
    str="${str#"${str%%[![:space:]]*}"}" # ltrim
    str="${str%"${str##*[![:space:]]}"}" # rtrim
    echo "$str"
}

# Validate if a given string is a valid Bash variable name.
class.name.valid() {
    local var_name=$(class.trim "$1")
    if [[ -z "$var_name" || ! "$var_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        return 1
    fi
    return 0
}

# Rename a class by copying it and unsetting the original.
class.rename() {
    class.copy "$1" "$2"
    unset -f "$1" >/dev/null 2>&1
}

# Copy a class or method definition, handling static or instance contexts.
class.copy() {
    if [ "$3" ]; then
        local vars=__BISU_CLASS_V_${4//.*/}
        eval "$2() { local this=$3 parent=$3.parent self=$4; $(declare -f $1 2>/dev/null |
            tail -n +4 | # delete local self
            class.sed 's/\{?this\[(@'${!vars}')\]\}?/'${3#*.}'__\1/g')"
    else
        local vars=__BISU_CLASS_V_${2//.*/}
        eval "$2() { local self=${2//.*/}; $(declare -f $1 2>/dev/null |
            tail -n +3 |
            class.sed 's/\{?self\[(@'${!vars}')\]\}?/'${2//.*/}'_static_\1/g')"
    fi
}

# Get or set a class variable value.
class.var() {
    local name="${1#*.}__$2"
    name=$(class.trim "$name")
    if [ -z "$3" ]; then
        printf '%s' "${!name}"
    else
        printf -v "$name" "%s" "${3#=}"
    fi
}

# Check if a class or function exists.
class.exists() {
    typeset -f "$1" >/dev/null 2>&1
}

# Append properties or methods to the current class.
class.append() {
    if [ "$2" ]; then
        local props=__BISU_CLASS_V_$__BISU_CLASS_NAME
        printf -v $props "%s" "${!props}|$2"
    else
        local len=${#BASH_SOURCE[@]}
        local file="${BASH_SOURCE[$len - 1]}"
        local line=${BASH_LINENO[$len - 2]}
        local name=($(
            awk -F ' *; *| *\\(' \
                'NR=='$line' {print $2}
                NR=='$line'+1 {gsub("[ \t]", "", $1);print $1;exit}' \
                "$file" 2>/dev/null
        ))
        class.name.valid "$name" || {
            printf '%s\n' "${ERROR_MSG_PREFIX}Invalid method name of file \"${file}\" at line: ${line}"
            return 1
        }
        local methods=__BISU_CLASS_M_$__BISU_CLASS_NAME
        printf -v $methods "%s" "${!methods} $__BISU_CLASS_NAME.$1$name"
    fi

    return 0
}

# Define static or public members.
@def() {
    if [[ "$1" == "static" ]]; then
        class.append
    else
        class.append "public." "$1"
    fi
}

# Set a variable with validation.
@set() {
    local name=$(class.trim "$1")
    shift
    class.name.valid "$name" && printf -v "$name" '%s' "$@"
}

# Return an object with validation.
@return() {
    local name=$(class.trim "$1")
    shift
    class.name.valid "$name" && printf -v "$name" "$@"
}

# Begin class definition, handling inheritance.
@class() {
    export __BISU_CLASS_NAME=($(printf '%s ' "$@"))
    local name vars
    for name in "${__BISU_CLASS_NAME[@]:1}"; do
        vars="__BISU_CLASS_V_$name"
        printf -v "__BISU_CLASS_V_${__BISU_CLASS_NAME[0]}" "%s" "${!vars}"
    done
}

# Create a new object instance.
class.new() {
    local file="${BASH_SOURCE[1]}"
    local line="${BASH_LINENO[1]}"
    local methods="__BISU_CLASS_M_$1"
    # Generate unique timestamp for object ID.
    local ts=""
    if [ -n "$EPOCHSECONDS" ]; then
        ts="$EPOCHSECONDS"
        local ns=""
        if [[ "$EPOCHREALTIME" =~ ^[0-9]+\.(.*)$ ]]; then
            ns=$(printf '%-9s' "${BASH_REMATCH[1]}" | tr ' ' 0)
        else
            ns="000000000"
        fi
        ts+="$ns"
    else
        ts=$(date +%s%N 2>/dev/null || true)
        if ! [[ "$ts" =~ ^[0-9]{19,}$ ]]; then
            ts=$(date +%s 2>/dev/null || true)
            if [[ "$ts" =~ ^[0-9]{10}$ ]]; then
                ts="${ts}000000000"
            else
                ts=""
            fi
        fi
    fi
    # Create unique object name using md5sum.
    local obj="@:object.o$(md5sum <<<"$1 $file $line $RANDOM $ts" | cut -d' ' -f1)"
    # Copy methods to object-specific names.
    for name in ${!methods}; do
        local newname="$obj.${name##*.}"
        if class.exists "$newname"; then
            newname="${newname%.*}.parent.${newname##*.}"
        fi
        class.copy "$name" "$newname" "$obj" "$1"
    done
    # Define variable accessors for the object.
    local vars="__BISU_CLASS_V_$1"
    for name in $(tr '|' ' ' <<<"${!vars}"); do
        eval "$obj.$name() { class.var \"$obj\" \"$name\" \"\$@\"; }"
    done
    printf -v "$2" "%s" "$obj"
    shift 2
    # Call constructor if it exists.
    class.exists "$obj.__construct" && "$obj.__construct" "$@"
}

# End class definition, setting up new and inheriting methods.
@class.end() {
    local methods name parent
    local parentmethods=()
    eval "${__BISU_CLASS_NAME[0]}.new() { class.new \"${__BISU_CLASS_NAME[0]}\" \"\$@\"; }"
    if [ "${#__BISU_CLASS_NAME[@]}" -gt 1 ]; then
        for parent in "${__BISU_CLASS_NAME[@]:1}"; do
            methods="__BISU_CLASS_M_$parent"
            parentmethods+=" ${!methods}"
        done
    fi
    methods="__BISU_CLASS_M_${__BISU_CLASS_NAME[0]}"
    # Rename methods to final names.
    for name in ${!methods}; do
        class.rename "${name##*.}" "$name"
    done
    unset "__BISU_CLASS_NAME" >/dev/null 2>&1
    printf -v "$methods" "%s" "${!methods} $parentmethods"
}

# Destroy an object, calling destructor and cleaning up.
@destroy() {
    class.exists "$1.__destruct" && "$1.__destruct"
    # Unset object-specific functions.
    for name in $(typeset -F | grep -o "$1[^ ]*"); do
        unset -f "$name" >/dev/null 2>&1
    done
    # Unset object-specific variables.
    for name in $(
        set -o posix
        set | grep -o "^${1//\./}__[^=]*="
    ); do
        unset "${name%%=}" >/dev/null 2>&1
    done
}

# Garbage collect unreferenced objects.
@class.gc() {
    local vars=$(
        set -o posix
        set
    )
    for name in $(typeset -F | grep -o "@:object\.[^ ]*" | cut -d. -f2 | sort -u); do
        if ! grep -q "=@:object\.$name\$" <<<"$vars" 2>/dev/null; then
            @destroy "@:object.$name"
        fi
    done
}
# ================================================================ Bash OOP Engine End =========================================================================
