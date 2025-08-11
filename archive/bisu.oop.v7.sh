#!/usr/bin/env bash
# Version: v7-20250811Z1
# ================================================================ Bash OOP Engine Start =======================================================================
# Wrapper for sed to handle extended regex compatibly across systems.
class.sed() {
    sed -E "$@"
} 2>/dev/null || class.sed() {
    sed -r "$@"
}

# Validate if a given string is a valid Bash variable name.
@valid.name() {
    local var_name="$1"
    var_name="${var_name#"${var_name%%[![:space:]]*}"}" # Trim leading whitespace
    var_name="${var_name%"${var_name##*[![:space:]]}"}" # Trim trailing whitespace
    if [[ -z "$var_name" || ! "$var_name" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
        return 1
    fi
    return 0
}

# Rename a class by copying it and unsetting the original.
class.rename() {
    class.copy "$1" "$2"
    unset -f "$1"
}

# Copy a class or method definition, handling static or instance contexts.
class.copy() {
    if [ "$3" ]; then
        local vars=CLASSES_V_${4//.*/}
        # Generate new function with replaced variable references for instance.
        eval "$2() { local this=\"$3\" parent=\"$3.parent\" self=\"$4\"; $(declare -f "$1" |
            tail -n +2 | # Skip function declaration line
            class.sed "s/\{?this\[(@${!vars})\]\}?/${3#*.}__\1/g") }"
    else
        local vars=CLASSES_V_${2//.*/}
        # Generate static function with replaced static variable references.
        eval "$2() { local self=\"${2//.*/}\"; $(declare -f "$1" |
            tail -n +2 | # Skip function declaration line
            class.sed "s/\{?self\[(@${!vars})\]\}?/${2//.*/}_Static_\1/g") }"
    fi
}

# Get or set a class variable value.
class.var() {
    local name="${1#*.}__$2"
    if [ -z "$3" ]; then
        echo -n "${!name}"
    else
        printf -v "$name" "%s" "${3#=}"
    fi
}

# Check if a class or function exists.
class.exists() {
    typeset -F | grep -qF "$1"
}

# Append properties or methods to the current class.
class.append() {
    if [ "$2" ]; then
        local props=CLASSES_V_$CLASS_NAME
        printf -v $props "%s" "${!props}|$2"
    else
        local len=${#BASH_SOURCE[@]}
        local file="${BASH_SOURCE[$len - 1]}"
        local line=${BASH_LINENO[$len - 2]}

        local name=($(
            awk -F ' *; *| *\\(' \
                'NR=='$line' {print $2}
                NR=='$line'+1 {gsub("[ \t]", "", $1);print $1;exit}' \
                "$file"
        ))

        local methods=CLASSES_M_$CLASS_NAME
        printf -v $methods "%s" "${!methods} $CLASS_NAME.$1$name"
    fi
}

# Define static or public members.
@def() {
    if [ "$1" == "static" ]; then
        class.append
    else
        class.append "public." "$1"
    fi
}

# Set a variable with validation.
@set() {
    local name="$1"
    shift
    @valid.name "$name" && printf -v "$name" '%s' "$@"
}

# Return a value to a variable with validation.
@return() {
    local name="$1"
    shift
    @valid.name "$name" && printf -v "$name" "$@"
}

# Begin class definition, handling inheritance.
@class() {
    CLASS_NAME=("$@")
    local name vars
    for name in "${CLASS_NAME[@]:1}"; do
        vars="CLASSES_V_$name"
        printf -v "CLASSES_V_${CLASS_NAME[0]}" "%s" "${!vars}"
    done
}

# Create a new object instance.
class.new() {
    local file="${BASH_SOURCE[1]}"
    local line="${BASH_LINENO[1]}"
    local methods="CLASSES_M_$1"
    # Generate unique timestamp for object ID.
    local ts=""
    if [ -n "$EPOCHSECONDS" ]; then
        ts="$EPOCHSECONDS"
        if [[ "$EPOCHREALTIME" =~ ^[0-9]+\.(.*)$ ]]; then
            ns=$(printf '%-9s' "${BASH_REMATCH[1]}" | tr ' ' 0)
        else
            ns="000000000"
        fi
        ts+="$ns"
    elif command -v date >/dev/null 2>&1; then
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
    local obj="@:object.m$(md5sum <<<"$1 $file $line $RANDOM $ts" | cut -d' ' -f1)"
    # Copy methods to object-specific names.
    for name in ${!methods}; do
        local newname="$obj.${name##*.}"
        if class.exists "$newname"; then
            newname="${newname%.*}.parent.${newname##*.}"
        fi
        class.copy "$name" "$newname" "$obj" "$1"
    done
    # Define variable accessors for the object.
    local vars="CLASSES_V_$1"
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
    eval "${CLASS_NAME[0]}.new() { class.new \"${CLASS_NAME[0]}\" \"\$@\"; }"
    if [ "${#CLASS_NAME[@]}" -gt 1 ]; then
        for parent in "${CLASS_NAME[@]:1}"; do
            methods="CLASSES_M_$parent"
            parentmethods+=" ${!methods}"
        done
    fi
    methods="CLASSES_M_${CLASS_NAME[0]}"
    # Rename methods to final names.
    for name in ${!methods}; do
        class.rename "${name##*.}" "$name"
    done
    unset CLASS_NAME
    printf -v "$methods" "%s" "${!methods} $parentmethods"
}

# Destroy an object, calling destructor and cleaning up.
@destroy() {
    class.exists "$1.__destruct" && "$1.__destruct"
    # Unset object-specific functions.
    for name in $(typeset -F | grep -o "$1[^ ]*"); do
        unset -f "$name"
    done
    # Unset object-specific variables.
    for name in $(
        set -o posix
        set | grep -o "^${1//\./}__[^=]*="
    ); do
        unset "${name%%=}"
    done
}

# Garbage collect unreferenced objects.
@class.gc() {
    local vars=$(
        set -o posix
        set
    )
    for name in $(typeset -F | grep -o "@:object\.[^ ]*" | cut -d. -f2 | sort -u); do
        if ! grep -q "=@:object\.$name\$" <<<"$vars"; then
            @destroy "@:object.$name"
        fi
    done
}
# ================================================================ Bash OOP Engine End =========================================================================
