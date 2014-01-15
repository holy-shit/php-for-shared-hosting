#!/bin/bash

INFO_MODE="false"
STARTWITHPHP="false"

REQ_USE_LIST_RAW=""
REQ_DISCARD_LIST_RAW=""

DEF_USE_LIST_RAW="php,xdebug"
DEF_DISCARD_LIST_RAW="apc"

. getopts_long.sh

OPTLIND=1
while getopts_long ":r:u:d" option \
info no_argument \
resume no_argument \
use 1 \
discard 1 \
"" "$@"
do
    case "$option" in
        i | info)    INFO_MODE="true";;
        r | resume)  STARTWITHPHP="true";;
        u | use)     REQ_USE_LIST_RAW=$OPTLARG;;
        d | discard) REQ_DISCARD_LIST_RAW=$OPTLARG;;
    esac
done
shift $(($OPTIND - 1))

function split_on_comma {
    unset return_of_split_on_comma
    unset parts
    comma_list=${1}  # colon-separate list to split
    while true ; do
        part=${comma_list%%,*}  # Delete longest substring match from back
        comma_list=${comma_list#*,}  # Delete shortest substring match from front
        parts[i++]=$part
        # We are done when there is no more colon
        if test "$comma_list" = "$part" ; then
            break
        fi
    done
    return_of_split_on_comma=${parts[@]}
}

split_on_comma $REQ_USE_LIST_RAW
NU_REQ_USE_LIST=$return_of_split_on_comma
REQ_USE_LIST=$(printf "%s\n" "${NU_REQ_USE_LIST[@]}" | sort -u)
#http://stackoverflow.com/questions/13648410/how-can-i-get-unique-values-from-an-array-in-linux-bash

echo "Requested uses:"
for part in "${REQ_USE_LIST[@]}"; do
    echo $part
done

split_on_comma $REQ_DISCARD_LIST_RAW
NU_REQ_DISCARD_LIST=$return_of_split_on_comma
REQ_DISCARD_LIST=$(printf "%s\n" "${NU_REQ_DISCARD_LIST[@]}" | sort -u)

echo "Requested discards:"
for part in "${REQ_DISCARD_LIST[@]}"; do
    echo $part
done

split_on_comma $DEF_USE_LIST_RAW
NU_DEF_USE_LIST=$return_of_split_on_comma
DEF_USE_LIST=$(printf "%s\n" "${NU_DEF_USE_LIST[@]}" | sort -u)

echo "Default uses:"
for part in "${DEF_USE_LIST[@]}"; do
    echo $part
done

split_on_comma $DEF_DISCARD_LIST_RAW
NU_DEF_DISCARD_LIST=$return_of_split_on_comma
DEF_DISCARD_LIST=$(printf "%s\n" "${NU_DEF_DISCARD_LIST[@]}" | sort -u)

echo "Default discards:"
for part in "${DEF_DISCARD_LIST[@]}"; do
    echo $part
done

#Compute USE_LIST

#Initial value is default use list
USE_LIST=$DEF_USE_LIST

#Remove default discard list
TEMP_USE_LIST=" ${USE_LIST[*]} "
for item in ${DEF_DISCARD_LIST[@]}; do
  TEMP_USE_LIST=${TEMP_USE_LIST/${item}/}
done
USE_LIST=$TEMP_USE_LIST
#http://stackoverflow.com/questions/10020148/bash-delete-items-present-in-one-array-from-another

#Add requested use list
TEMP_USE_LIST=( ${USE_LIST[@]} ${REQ_USE_LIST[@]} )
USE_LIST=$(printf "%s\n" "${TEMP_USE_LIST[@]}" | sort -u)

#Remove requested discard list
TEMP_USE_LIST=" ${USE_LIST[*]} "
for item in ${REQ_DISCARD_LIST[@]}; do
  TEMP_USE_LIST=${TEMP_USE_LIST/${item}/}
done
USE_LIST=$TEMP_USE_LIST

echo "Computed uses:"
for part in "${USE_LIST[@]}"; do
    echo $part
done

#Compute DISCARD_LIST

#Initial value is default discard list
DISCARD_LIST=$DEF_DISCARD_LIST

#Remove requested uses list
TEMP_DISCARD_LIST=" ${DISCARD_LIST[*]} "
for item in ${REQ_USES_LIST[@]}; do
  TEMP_DISCARD_LIST=${TEMP_DISCARD_LIST/${item}/}
done
DISCARD_LIST=$TEMP_DISCARD_LIST

#Add requested discard list
TEMP_DISCARD_LIST=( ${DISCARD_LISTT[@]} ${REQ_DISCARD_LIST[@]} )
DISCARD_LIST=$(printf "%s\n" "${TEMP_DISCARD_LIST[@]}" | sort -u)

echo "Computed discards:"
for part in "${DISCARD_LIST[@]}"; do
    echo $part
done

function array_contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "y"
            return 0
        fi
    }
    echo "n"
    return 1
}

$(array_contains "${USE_LIST[@]}" "php")

function package_used() {
    if [ $(array_contains "${USE_LIST[@]}" $1) == "y" ]; then
        echo "y"
        return 1
    else
        echo "n"
        return 0
    fi
}

function package_discarded() {
    if [ $(array_contains "${DISCARD_LIST[@]}" $1) == "y" ]; then
        echo "y"
        return 1
    else
        echo "n"
        return 0
    fi
}
