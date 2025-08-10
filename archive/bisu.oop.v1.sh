#!/usr/bin/env bash
# Version: v1-20250810Z2
# ================================================================ Bash OOP Engine Start =======================================================================
unset -f class.sed >/dev/null 2>&1
{
    printf '' | sed -E '' >/dev/null 2>&1 &&
        class.sed() {
            sed -E "$(printf '%s ' "$@")" 2>/dev/null
        } || exit 1
}

class.new() {
    local file="${BASH_SOURCE[1]}"
    local line=${BASH_LINENO[1]}
    local methods_var="CLASSES_M_$1"
    local -n methods_ref="$methods_var"
    local ts=
    [[ -n $EPOCHSECONDS ]] && {
        ts=$EPOCHSECONDS
        [[ $EPOCHREALTIME =~ ^[0-9]+\.(.*)$ ]] && ns=$(printf '%-9s' "${BASH_REMATCH[1]}" | tr ' ' 0) || ns=000000000
        ts+=${ns}
    } || { command -v date >/dev/null 2>&1 && {
        ts=$(date +%s%N 2>/dev/null || true)
        [[ $ts =~ ^[0-9]{19,}$ ]] && : || {
            ts=$(date +%s 2>/dev/null || true)
            [[ $ts =~ ^[0-9]{10}$ ]] && ts=${ts}000000000 || ts=''
        }
    } || ts=''; }
    local obj="@:object.f$(md5sum <<<"${1}-${file}-${line}-${RANDOM}-${ts}" | awk '{print $1}')"

    for name in ${methods_ref}; do
        local newname=$obj.${name##*.}
        class.exists "$newname" && newname="${newname%.*}.parent.${newname//*./}"
        class.copy "$name" "$newname" "$obj" "$1"
    done

    local vars_var="CLASSES_V_$1"
    local -n vars_ref="$vars_var"
    for name in ${vars_ref//|/ }; do
        eval "$obj.$name() { class.var \"$obj\" \"$name\" \"\$@\"; }"
    done

    printf -v "$2" "%s" "$obj"
    shift 2
    class.exists "$obj.__construct" && "$obj.__construct" "$@"
}

class.rename() {
    class.copy "$1" "$2"
    unset -f "$1"
}

class.copy() {
    if [ "$3" ]; then
        local vars_var="CLASSES_V_${4//.*/}"
        local -n keys="$vars_var"
        local func_body
        func_body="$(declare -f "$1")"
        func_body="${func_body#*\{}"
        func_body="${func_body%$'\n}'}"
        func_body="$(class.sed "s/{?this\[(@${keys[*]})\]}?/${3#*.}__\\1/g" <<<"$func_body")"
        eval "$2() {"$'\n'"local this=\"$3\" parent=\"$4.parent\" self=\"$4\""$'\n'"$func_body"$'\n'"}"
    else
        local vars_var="CLASSES_V_${2//.*/}"
        local -n keys="$vars_var"
        local func_body
        func_body="$(declare -f "$1")"
        func_body="${func_body#*\{}"
        func_body="${func_body%$'\n}'}"
        func_body="$(class.sed "s/{?self\[(@${keys[*]})\]}?/${2//.*/}_static_\\1/g" <<<"$func_body")"
        eval "$2() {"$'\n'"local self=\"${2//.*/}\""$'\n'"$func_body"$'\n'"}"
    fi
}

class.var() {
    local name="${1#*.}__$2"
    if [ -z "$3" ]; then
        printf '%s' "${!name}"
    else
        printf -v "$name" "%s" "${3#=}"
    fi
}

class.exists() {
    typeset -F "$1" >/dev/null 2>&1
}

class.append() {
    if [ "$2" ]; then
        local props="CLASSES_V_$__CLASS_NAME"
        local -n val="$props"
        val="${val}|$2"
    else
        local len=${#BASH_SOURCE[@]}
        local file="${BASH_SOURCE[$((len - 1))]}"
        local line=${BASH_LINENO[$((len - 2))]}
        local name=($(awk -F ' *; *| *\\(' -v l="$line" '
            NR == l {print $2}
            NR == l + 1 {gsub("[ \t]", "", $1); print $1; exit}
        ' "$file"))
        local methods="CLASSES_M_$__CLASS_NAME"
        local -n val="$methods"
        val="${val} $__CLASS_NAME.$1${name}"
    fi
}

@def() {
    if [[ "$1" == "static" ]]; then
        class.append
    else
        class.append "public." "$1"
    fi
}

@return() {
    local name="$1"
    shift
    printf -v "$name" "$@"
}

@class() {
    export __CLASS_NAME=("$@")
    local name vars val
    for name in "${__CLASS_NAME[@]:1}"; do
        vars="CLASSES_V_$name"
        val="${!vars}"
        printf -v "CLASSES_V_${__CLASS_NAME[0]}" "%s" "$val"
    done
}

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

@destroy() {
    class.exists "$1.__destruct" && "$1.__destruct"
    for name in $(typeset -F | awk "/ $1[^ ]*/ {print \$3}"); do
        unset -f "$name"
    done
    for name in $(set | grep -o "^${1//*./}__[^=]*="); do
        unset "${name%%=*}"
    done
}

@class.gc() {
    local vars
    vars="$(set)"
    for name in $(typeset -F | grep -o " @:object\.[^ ]*" 2>/dev/null | cut -d. -f2 | sort -u); do
        grep -q "@:object.$name\$" <<<"$vars" || @destroy "@:object.$name"
    done
}

# Export functions to ensure availability in defining and importing files
export -f class.sed class.new class.rename class.copy class.var class.exists class.append @def @return @class @class.end @destroy @class.gc >/dev/null 2>&1
# ================================================================ Bash OOP Engine End =========================================================================
