#!/usr/bin/env bash
# Version: v4-20250809Z1
# ================================================================ Bash OOP Engine Start =======================================================================
# Safe sed wrapper for regex operations
unset -f class.sed >/dev/null 2>&1
{
    printf '' | sed -E '' >/dev/null 2>&1 &&
        class.sed() { sed -E "$(printf '%s ' "$@")" 2>/dev/null; } || exit 1
}
export -f class.sed

# Check if a function exists
class.exists() { typeset -F "$1" >/dev/null 2>&1; }

# Manage instance and static variables
class.var() {
    local ctx="$1" name="$2" val="$3"
    local key
    [[ "$ctx" == *@:* ]] && key="${ctx#*.}__$name" || key="${ctx}_static_$name"
    [[ -z "$val" ]] && printf '%s' "${!key}" || printf -v "$key" "%s" "${val#=}"
}

# Copy and rebind functions for instance or static methods
# source: original function name to copy
# target: new function name to declare
# obj: if non-empty, an object-id string (instance); otherwise creating static method
# class: logical class name
class.copy() {
    local source="$1" target="$2" obj="$3" class="$4"

    # obtain function source (entire declaration)
    local func_body
    func_body="$(declare -f "$source" 2>/dev/null)" || return 1
    [[ -z "$func_body" ]] && return 1

    # strip "name() {" and trailing "}"
    func_body="${func_body#*\{}"
    func_body="${func_body%$'\n}'}"

    # resolve the class variable that stores property names (handle dotted names safely)
    local class_short="${class%%.*}"
    local vars_var="CLASSES_V_$class_short"
    local -n keys="$vars_var" 2>/dev/null || true

    if [[ -n "$obj" ]]; then
        # replace placeholder property accesses that reference 'this[...]' with object-backed names
        # keys[*] contains property names (space separated).
        # the original engine used a token format; preserve that behaviour.
        func_body="$(class.sed "s/{?this\[(@${keys[*]})\]}?/${obj#*.}__\\1/g" <<<"$func_body")"
        # create the new instance function; set local this/parent/self in the function scope
        eval "$target() {"$'\n'"local this=\"$obj\" parent=\"$class.parent\" self=\"$class\""$'\n'"$func_body"$'\n'"}"
    else
        # static method: replace self[...] tokens to static storage
        func_body="$(class.sed "s/{?self\[(@${keys[*]})\]}?/${class}_static_\\1/g" <<<"$func_body")"
        eval "$target() {"$'\n'"local self=\"$class\""$'\n'"$func_body"$'\n'"}"
    fi
}

# Rename a method by copying and removing the original
class.rename() {
    class.copy "$1" "$2" && unset -f "$1" 2>/dev/null
}

# Append method or property to class definition
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
        [[ -z "$name" ]] && {
            echo "Error: could not parse method name at $file:$line" >&2
            return 1
        }
        local methods="CLASSES_M_$__CLASS_NAME"
        local -n val="$methods"
        val="${val} $__CLASS_NAME.$access.$name"
    else
        echo "Error: invalid arguments to class.append" >&2
        return 1
    fi
}

# Create a new object instance
# Usage: class.new ClassName instanceVarName [constructor args...]
class.new() {
    local file="${BASH_SOURCE[1]}" line=${BASH_LINENO[1]}
    local methods_var="CLASSES_M_$1" vars_var="CLASSES_V_$1"
    local -n methods_ref="$methods_var" vars_ref="$vars_var"

    # create an object id string (kept as before for compatibility)
    local obj="@:object.f$(md5sum <<<"$1 $file $line $RANDOM $(date +%s%N)" | awk '{print $1}')"
    local inst_name="$2"

    # create instance methods (internal names based on object id)
    for m in ${methods_ref}; do
        local mname=${m##*.}
        local newname="$obj.${mname}"
        # protect against duplicate method names
        class.exists "$newname" && newname="${newname%.*}.parent.${newname//*./}"
        class.copy "$m" "$newname" "$obj" "$1"

        # Friendly wrapper so callers can use "<instance>.<method>" (e.g. array.data)
        # without needing to expand the object id. This prevents ".method: command not found".
        if [[ -n "$inst_name" ]]; then
            # wrapper simply forwards args to the internal object-id method.
            # Keep the wrapper minimal and transparent (preserve exit status / stdout of target).
            eval "${inst_name}.${mname}() { \"$newname\" \"\$@\"; }"
        fi
    done

    # create property accessors as functions on the object id and friendly wrappers
    for name in ${vars_ref//|/ }; do
        eval "$obj.$name() { class.var \"$obj\" \"$name\" \"\$@\"; }"
        if [[ -n "$inst_name" ]]; then
            eval "${inst_name}.${name}() { \"$obj.$name\" \"\$@\"; }"
        fi
    done

    # write object id back into caller variable
    printf -v "$2" "%s" "$obj"
    shift 2

    # call constructor if present
    class.exists "$obj.__construct" && "$obj.__construct" "$@"
}

# Destroy an object and its associated methods/variables (robust removal)
@destroy() {
    # call destructor if any
    class.exists "$1.__destruct" && "$1.__destruct"

    local id="$1"
    local fname body

    # First remove any function whose name literally contains the id (internal methods)
    while read -r fname; do
        [[ -z "$fname" ]] && continue
        unset -f "$fname" 2>/dev/null || true
    done < <(typeset -F | awk -v pat="$id" 'index($0, pat) {print $3}')

    # Then remove wrapper functions whose bodies forward to the internal id (search bodies)
    # This handles wrappers like "array.method" that call "@:object.f...method".
    while read -r fname; do
        [[ -z "$fname" ]] && continue
        body="$(declare -f "$fname" 2>/dev/null || true)"
        if [[ -n "$body" && "$body" == *"$id"* ]]; then
            unset -f "$fname" 2>/dev/null || true
        fi
    done < <(typeset -F | awk '{print $3}')

    # Clean up any object-backed shell variables (matching the engine's naming convention)
    for name in $(set | grep -o "^${id//./\\.}__[^=]*=" 2>/dev/null); do
        unset "${name%%=*}" 2>/dev/null || true
    done
}

# Garbage collector for orphaned objects
@class.gc() {
    local vars="$(set)"
    for name in $(typeset -F | grep -o " @:object\.[^ ]*" 2>/dev/null | cut -d. -f2 | sort -u); do
        grep -q "@:object.$name\$" <<<"$vars" || @destroy "@:object.$name"
    done
}

# Define a class property or method
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

# Set a variable value
@set() {
    local name="$1"
    shift
    printf -v "$name" "%s" "$@"
}

# Begin a class definition
@class() {
    export __CLASS_NAME=("$@")
    local name vars val
    for name in "${__CLASS_NAME[@]:1}"; do
        vars="CLASSES_V_$name"
        val="${!vars}"
        printf -v "CLASSES_V_${__CLASS_NAME[0]}" "%s" "$val"
    done
}

# End a class definition
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

    for name in ${methods}; do
        class.rename "${name##*.}" "$name"
    done

    unset __CLASS_NAME
    methods="$(printf '%s\n' ${methods} | sort -u | tr '\n' ' ')"
    printf -v "$methods_var" "%s" "$methods"
}

# Define classes in a controlled scope
@class.definition() {
    local def_func="$1"
    (eval "$def_func")
}

# Export core functions
export -f class.sed class.new class.rename class.copy class.var class.exists class.append @def @set @class @class.end @destroy @class.gc >/dev/null 2>&1
# ================================================================ Bash OOP Engine End =========================================================================
