#!/usr/bin/env bash
# Version: v5-20250809Z1
# ================================================================ Bash OOP Engine Start =======================================================================
# Safe sed wrapper for regex operations, fallback safe exit if unsupported
unset -f class.sed >/dev/null 2>&1
{
    printf '' | sed -E '' >/dev/null 2>&1 &&
        class.sed() { sed -E "$(printf '%s ' "$@")" 2>/dev/null; } || exit 1
}
export -f class.sed

# Check if a function exists (POSIX-compatible, Bash 5 builtin)
class.exists() { typeset -F "$1" >/dev/null 2>&1; }

# Manage instance and static variables
# Usage: class.var context name [value]
# If value provided, sets; else gets variable.
class.var() {
    local ctx="$1" name="$2" val="$3"
    local key
    # Determine if ctx is instance or static context
    if [[ "$ctx" == *@:* ]]; then
        # instance variable: objectid__varname
        key="${ctx#*.}__${name}"
    else
        # static variable: class_static_varname
        key="${ctx}_static_${name}"
    fi
    # Get or set variable safely (value stripped of leading '=' if set)
    if [[ -z "$val" ]]; then
        printf '%s' "${!key}"
    else
        printf -v "$key" "%s" "${val#=}"
    fi
}

# Copy and rebind functions for instance or static methods
# source: original function name to copy
# target: new function name to declare
# obj: if non-empty, object id string (instance); else static method
# class: logical class name
class.copy() {
    local source="$1" target="$2" obj="$3" class="$4"

    # Obtain full function body; return failure if not found
    local func_body
    func_body="$(declare -f "$source" 2>/dev/null)" || return 1
    [[ -z "$func_body" ]] && return 1

    # Strip function header ("name() {") and trailing "}"
    func_body="${func_body#*\{}"
    func_body="${func_body%$'\n}'}"

    # Access class variable list (handle dotted class names safely)
    local class_short="${class%%.*}"
    local vars_var="CLASSES_V_$class_short"
    local -n keys="$vars_var" 2>/dev/null || true

    if [[ -n "$obj" ]]; then
        # Instance method: replace placeholders 'this[@prop]' with 'objectid__prop'
        func_body="$(class.sed "s/{?this\[(@${keys[*]})\]}?/${obj#*.}__\\1/g" <<<"$func_body")"

        # Define method with local this/parent/self for scope, careful quoting
        eval "$target() {
            local this=\"$obj\" parent=\"$class.parent\" self=\"$class\"
            $func_body
        }"
    else
        # Static method: replace placeholders 'self[@prop]' with 'class_static_prop'
        func_body="$(class.sed "s/{?self\[(@${keys[*]})\]}?/${class}_static_\\1/g" <<<"$func_body")"

        # Define static method with local self, careful quoting
        eval "$target() {
            local self=\"$class\"
            $func_body
        }"
    fi
}

# Rename a method by copying and removing original to avoid duplicates
class.rename() {
    class.copy "$1" "$2" && unset -f "$1" 2>/dev/null
}

# Append method or property to class definition storage variables
# Usage:
#   class.append access name
#   or
#   class.append file line access  (parses method name from source file)
class.append() {
    if [ "$#" -eq 2 ]; then
        local access="$1" name="$2"
        local props="CLASSES_V_$__CLASS_NAME"
        local -n val="$props"
        val="${val}|$access $name"
    elif [ "$#" -eq 3 ]; then
        local file="$1" line="$2" access="$3"
        local name=($(awk -F ' *; *| *\\(' -v l="$line" '
            NR == l + 1 {gsub("[ \t]", "", $1); print $1; exit}
        ' "$file"))
        if [[ -z "$name" ]]; then
            echo "Error: could not parse method name at $file:$line" >&2
            return 1
        fi
        local methods="CLASSES_M_$__CLASS_NAME"
        local -n val="$methods"
        val="${val} $__CLASS_NAME.$access.$name"
    else
        echo "Error: invalid arguments to class.append" >&2
        return 1
    fi
}

# Create a new object instance of a class
# Usage: class.new ClassName instanceVarName [constructor args...]
class.new() {
    local file="${BASH_SOURCE[1]}" line=${BASH_LINENO[1]}
    local methods_var="CLASSES_M_$1" vars_var="CLASSES_V_$1"
    local -n methods_ref="$methods_var" vars_ref="$vars_var"

    # Generate unique object id (kept stable as before)
    local obj="@:object.f$(md5sum <<<"$1 $file $line $RANDOM $(date +%s%N)" | awk '{print $1}')"
    local inst_name="$2"

    # Create instance methods bound to obj and friendly wrappers
    for m in ${methods_ref}; do
        local mname=${m##*.}
        local newname="$obj.${mname}"
        # Avoid duplicate method name collisions by renaming with parent chain suffix
        class.exists "$newname" && newname="${newname%.*}.parent.${newname//*./}"
        class.copy "$m" "$newname" "$obj" "$1"
        # Friendly wrapper for instance: allow <instance>.<method> calls transparently
        if [[ -n "$inst_name" ]]; then
            eval "${inst_name}.${mname}() { \"$newname\" \"\$@\"; }"
        fi
    done

    # Create property accessor functions on object id and friendly wrappers
    for name in ${vars_ref//|/ }; do
        eval "$obj.$name() { class.var \"$obj\" \"$name\" \"\$@\"; }"
        if [[ -n "$inst_name" ]]; then
            eval "${inst_name}.${name}() { \"$obj.$name\" \"\$@\"; }"
        fi
    done

    # Export object id back to caller variable
    printf -v "$2" "%s" "$obj"
    shift 2

    # Call constructor if defined
    class.exists "$obj.__construct" && "$obj.__construct" "$@"
}

# Destroy object and all associated internal methods, wrappers, and variables safely
@destroy() {
    # Call destructor if any
    class.exists "$1.__destruct" && "$1.__destruct"
    local id="$1" fname body

    # Remove functions whose names contain the object id (internal methods)
    while read -r fname; do
        [[ -z "$fname" ]] && continue
        unset -f "$fname" 2>/dev/null || true
    done < <(typeset -F | awk -v pat="$id" 'index($0, pat) {print $3}')

    # Remove wrapper functions whose bodies forward to internal object id methods
    while read -r fname; do
        [[ -z "$fname" ]] && continue
        body="$(declare -f "$fname" 2>/dev/null || true)"
        if [[ -n "$body" && "$body" == *"$id"* ]]; then
            unset -f "$fname" 2>/dev/null || true
        fi
    done < <(typeset -F | awk '{print $3}')

    # Clean up shell variables matching object-backed naming convention
    for name in $(set | grep -o "^${id//./\\.}__[^=]*=" 2>/dev/null); do
        unset "${name%%=*}" 2>/dev/null || true
    done
}

# Garbage collector for orphaned objects (remove unreferenced)
@class.gc() {
    local vars="$(set)"
    for name in $(typeset -F | grep -o " @:object\.[^ ]*" 2>/dev/null | cut -d. -f2 | sort -u); do
        grep -q "@:object.$name\$" <<<"$vars" || @destroy "@:object.$name"
    done
}

# Define a class property or method with proper access control
@def() {
    if [ "$1" == "static" ]; then
        if [ -z "$2" ]; then
            local caller_info=$(caller 0)
            local line=$(echo "$caller_info" | awk '{print $1}')
            local file=$(echo "$caller_info" | awk '{print $3}')
            class.append "$file" "$line" "static"
        else
            class.append "static" "$2"
        fi
    else
        if [ -z "$1" ]; then
            local caller_info=$(caller 0)
            local line=$(echo "$caller_info" | awk '{print $1}')
            local file=$(echo "$caller_info" | awk '{print $3}')
            class.append "$file" "$line" "public"
        else
            class.append "public" "$1"
        fi
    fi
}

# Set a variable's value safely
@set() {
    local name="$1"
    shift
    printf -v "$name" "%s" "$@"
}

# Begin a class definition: set current class and merge vars from parents
@class() {
    export __CLASS_NAME=("$@")
    local name vars val
    for name in "${__CLASS_NAME[@]:1}"; do
        vars="CLASSES_V_$name"
        val="${!vars}"
        printf -v "CLASSES_V_${__CLASS_NAME[0]}" "%s" "$val"
    done
}

# End a class definition: aggregate methods and create new() constructor
@class.end() {
    local methods_var="CLASSES_M_${__CLASS_NAME[0]}"
    local -n methods="$methods_var"
    eval "${__CLASS_NAME[0]}.new() { class.new ${__CLASS_NAME[0]} \"\$@\"; }"

    if [ "${#__CLASS_NAME[@]}" -gt 1 ]; then
        for parent in "${__CLASS_NAME[@]:1}"; do
            local parentmethods_var="CLASSES_M_$parent"
            local -n parentmethods="$parentmethods_var"
            methods+=" ${parentmethods[*]}"
        done
    fi

    # Rename methods to internal object id format (avoid name collisions)
    for name in ${methods}; do
        class.rename "${name##*.}" "$name"
    done

    unset __CLASS_NAME
    methods="$(printf '%s\n' ${methods} | sort -u | tr '\n' ' ')"
    printf -v "$methods_var" "%s" "$methods"
}

# Define classes in a controlled subshell scope to avoid pollution
@class.definition() {
    local def_func="$1"
    (eval "$def_func")
}

# Export core engine functions for external usage
export -f class.sed class.new class.rename class.copy class.var class.exists class.append @def @set @class @class.end @destroy @class.gc >/dev/null 2>&1
# ================================================================ Bash OOP Engine End =========================================================================
