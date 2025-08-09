#!/usr/bin/env bash
# Version: v3-20250809Z1
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
class.copy() {
    local source="$1" target="$2" obj="$3" class="$4"
    local func_body="$(declare -f "$source" 2>/dev/null)"
    [[ -z "$func_body" ]] && return 1
    func_body="${func_body#*\{}"
    func_body="${func_body%$'\n}'}"

    local vars_var="CLASSES_V_${class//.*/}"
    local -n keys="$vars_var"

    if [ "$obj" ]; then
        func_body="$(class.sed "s/{?this\[(@${keys[*]})\]}?/${obj#*.}__\\1/g" <<<"$func_body")"
        eval "$target() {"$'\n'"local this=\"$obj\" parent=\"$class.parent\" self=\"$class\""$'\n'"$func_body"$'\n'"}"
    else
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
class.new() {
    local file="${BASH_SOURCE[1]}" line=${BASH_LINENO[1]}
    local methods_var="CLASSES_M_$1" vars_var="CLASSES_V_$1"
    local -n methods_ref="$methods_var" vars_ref="$vars_var"

    local obj="@:object.f$(md5sum <<<"$1 $file $line $RANDOM $(date +%s%N)" | awk '{print $1}')"

    for m in ${methods_ref}; do
        local newname=$obj.${m##*.}
        class.exists "$newname" && newname="${newname%.*}.parent.${newname//*./}"
        class.copy "$m" "$newname" "$obj" "$1"
    done

    for name in ${vars_ref//|/ }; do
        eval "$obj.$name() { class.var \"$obj\" \"$name\" \"\$@\"; }"
    done

    printf -v "$2" "%s" "$obj"
    shift 2
    class.exists "$obj.__construct" && "$obj.__construct" "$@"
}

# Destroy an object and its associated methods/variables
@destroy() {
    class.exists "$1.__destruct" && "$1.__destruct"
    for name in $(typeset -F | awk "/ $1[^ ]*/ {print \$3}"); do unset -f "$name"; done
    for name in $(set | grep -o "^${1//*./}__[^=]*="); do unset "${name%%=*}"; done
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
