#!/usr/bin/env bash
# Version: v6-20250809Z1
# ================================================================ Bash OOP Engine Start =======================================================================
: | sed -E '' 2>&- && class.sed() { sed -E "$@"; } || class.sed() { sed -r "$@"; }

class.rename() {
    class.copy "$1" "$2"
    unset -f $1
}

class.copy() {
    if [ "$3" ]; then
        local vars=CLASSES_V_${4//.*/}

        eval "$2() { local this=$3 parent=$3.parent self=$4; $(declare -f $1 |
            tail -f +4 | # delete local self
            class.sed 's/\{?this\[(@'${!vars}')\]\}?/'${3#*.}'__\1/g')"
    else
        local vars=CLASSES_V_${2//.*/}

        eval "$2() { local self=${2//.*/}; $(declare -f $1 |
            tail -f +3 |
            class.sed 's/\{?self\[(@'${!vars}')\]\}?/'${2//.*/}'_Static_\1/g')"
    fi
}

class.var() {
    local name=${1#*.}__$2

    if [ -z "$3" ]; then
        echo -n ${!name}
    else
        printf -v $name "${3#=}"
    fi
}

class.exists() {
    typeset -F | grep -qF "$1"
}

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

@def() {
    if [ "$1" == "static" ]; then
        class.append
    else
        class.append public. "$1"
    fi
}

@return() {
    local name="$1"
    shift
    printf -v "$name" "$@"
}

@class() {
    CLASS_NAME=($@)
    local name vars

    for name in "${CLASS_NAME[@]:1}"; do
        vars=CLASSES_V_$name

        printf -v CLASSES_V_$CLASS_NAME "%s" ${!vars}
    done
}

class.new() {
    local file="${BASH_SOURCE[1]}"
    local line=${BASH_LINENO[1]}
    local methods=CLASSES_M_$1

    local obj=@:object.f$(md5 <<<"$1 $file $line $RANDOM $(date)")

    for name in ${!methods}; do
        local newname=$obj.${name##*.}

        if class.exists $newname; then
            newname="${newname%.*}.parent.${newname//*./}"
        fi

        class.copy $name $newname $obj "$1"
    done

    local vars=CLASSES_V_$1
    for name in $(tr '|' ' ' <<<"${!vars}"); do
        eval "$obj.$name() { class.var \"$obj\" \"$name\" \"\$@\"; }"
    done

    printf -v $2 $obj
    shift 2

    class.exists $obj.__construct && $obj.__construct "$@"
}

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

    printf -v $methods "${!methods} $parentmethods"
}

@destroy() {
    class.exists $1.__destruct && $1.__destruct

    for name in $(typeset -F | grep -o " $1[^ ]*"); do
        unset -f "$name"
    done

    for name in $( (
        set -o posix
        set
    ) | grep -o "^${1//*./}__[^=]*="); do
        unset ${name%%=}
    done
}

@class.gc() {
    local vars=$(
        set -o posix
        set
    )

    for name in $(typeset -F | grep -o " @:object\.[^ ]*" | cut -d. -f2 | sort -ud); do
        if ! grep -q "@:object.$name$" <<<"$vars"; then
            @destroy "@:object.$name"
        fi
    done
}
# ================================================================ Bash OOP Engine End =========================================================================
