#!/usr/bin/env bash
# Version: v7-20250810Z1
# ================================================================ Bash OOP Engine Start =======================================================================
# Safe sed wrapper for regex operations
: | sed -E '' 2>/dev/null && class.sed() { sed -E "$@"; } || class.sed() { sed -r "$@"; }

# Rename a function by copying it and unsetting the original
class.rename() {
    class.copy "$1" "$2"
    unset -f "$1"
}

# Copy and rebind a function for instance or static methods, replacing placeholders
class.copy() {
    local func_body="$(declare -f "$1" 2>/dev/null)"
    [ -z "$func_body" ] && return 1
    func_body="${func_body#*\{}"
    func_body="${func_body%$'\n}'}"
    if [ "$3" ]; then
        local vars=CLASSES_V_${4//.*/}
        func_body="$(class.sed 's/\{?this\[(@'${!vars}')\]\}?/'${3#*.}'__\1/g' <<<"$func_body")"
        eval "$2() { local this=$3 parent=$4.parent self=$4; $func_body }"
    else
        local vars=CLASSES_V_${2//.*/}
        func_body="$(class.sed 's/\{?self\[(@'${!vars}')\]\}?/'${2//.*/}'_Static_\1/g' <<<"$func_body")"
        eval "$2() { local self=${2//.*/}; $func_body }"
    fi
}

# Get or set an instance variable
class.var() {
    local name=${1#*.}__$2
    if [ -z "$3" ]; then
        echo -n ${!name}
    else
        printf -v $name "${3#=}"
    fi
}

# Check if a function exists
class.exists() {
    typeset -F "$1" >/dev/null 2>&1
}

# Append a property or method to class storage
class.append() {
    if [ "$2" ]; then
        # Append property name
        local props=CLASSES_V_$CLASS_NAME
        printf -v $props "%s" "${!props}|$2"
    else
        # Parse method name from next line in source file
        local len=${#BASH_SOURCE[@]}
        local file="${BASH_SOURCE[$len - 1]}"
        local line=${BASH_LINENO[$len - 2]}
        local name=$(awk -v l="$line" '
            NR == l +1 { sub(/^[ \t]*/, ""); sub(/\(.*/, ""); print $0; exit }
        ' "$file")
        if [ -z "$name" ]; then
            echo "Error: could not parse method name at $file:$((line + 1))" >&2
            return 1
        fi
        # Append method with access prefix
        local methods=CLASSES_M_$CLASS_NAME
        printf -v $methods "%s" "${!methods} $CLASS_NAME.${1}${name}"
    fi
}

# Define a property or method with proper access
@def() {
    if [ -z "$1" ]; then
        # Public method
        class.append "public."
    elif [ "$1" == "static" ]; then
        if [ -z "$2" ]; then
            # Static method
            class.append "static."
        else
            # Static property
            class.append "static." "$2"
        fi
    else
        # Public property
        class.append "public." "$1"
    fi
}

# Set a variable's value
@return() {
    local name="$1"
    shift
    printf -v "$name" "$@"
}

# Begin class definition, merge parent properties
@class() {
    CLASS_NAME=($@)
    local name vars
    for name in "${CLASS_NAME[@]:1}"; do
        vars=CLASSES_V_$name
        printf -v CLASSES_V_$CLASS_NAME "%s" ${!vars}
    done
}

# Create a new instance of a class
class.new() {
    local file="${BASH_SOURCE[1]}"
    local line=${BASH_LINENO[1]}
    local methods=CLASSES_M_$1
    # Generate unique object ID
    local obj=object.$(md5sum <<<"$1 $file $line $RANDOM $(date +%s%N)" | awk '{print $1}')
    local inst_name="$2"
    for name in ${!methods}; do
        local mname=${name##*.}
        local newname=$obj.${mname}
        if class.exists $newname; then
            newname="${newname%.*}.parent.${mname}"
        fi
        class.copy $name $newname $obj "$1"
        if [ -n "$inst_name" ]; then
            eval "${inst_name}.${mname}() { \"$newname\" \"\$@\"; }"
        fi
    done
    local vars=CLASSES_V_$1
    for name in $(tr '|' ' ' <<<"${!vars}"); do
        eval "$obj.$name() { class.var \"$obj\" \"$name\" \"\$@\"; }"
        if [ -n "$inst_name" ]; then
            eval "${inst_name}.${name}() { \"$obj.$name\" \"\$@\"; }"
        fi
    done
    printf -v $2 $obj
    shift 2
    class.exists $obj.__construct && $obj.__construct "$@"
}

# End class definition, aggregate methods, create constructor
@class.end() {
    local methods name parent
    local parentmethods=()
    eval "${CLASS_NAME}.new() { class.new $CLASS_NAME \"\$@\"; }"
    if [ ${#CLASS_NAME[@]} -gt 1 ]; then
        for parent in "${CLASS_NAME[@]:1}"; do
            methods=CLASSES_M_$parent
            parentmethods="$parentmethods ${!methods}"
        done
    fi
    methods=CLASSES_M_$CLASS_NAME
    for name in ${!methods}; do
        class.rename ${name##*.} $name
    done
    unset CLASS_NAME
    # Aggregate and unique methods
    printf -v $methods "%s" "$(echo ${!methods} $parentmethods | tr ' ' '\n' | sort -u | tr '\n' ' ')"
}

# Destroy an object, call destructor, clean functions and variables
@destroy() {
    class.exists $1.__destruct && $1.__destruct
    # Clean associated functions
    for name in $(typeset -F | grep -o "$1[^ ]*"); do
        unset -f "$name"
    done
    # Clean associated variables
    for name in $( (
        set -o posix
        set
    ) | grep -o "^${1//*./}__[^=]*="); do
        unset ${name%%=}
    done
}

# Garbage collect unreferenced objects
@class.gc() {
    local vars=$( (
        set -o posix
        set
    ))
    for name in $(typeset -F | grep -o " object\.[^ ]*" | cut -d. -f2 | sort -u); do
        if ! grep -q "object.$name$" <<<"$vars"; then
            @destroy "object.$name"
        fi
    done
}
# ================================================================ Bash OOP Engine End =========================================================================
