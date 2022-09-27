#!/bin/bash
# Copyright (C) 2019-2022 Dave Dittrich. All rights reserved.
#
# Identify the last built artifact and return its name. This script
# assumes the artifacts are located in the current working directory,
# as would occur when run from the `Makefile` in the repo root directory.

if [[ ! -z "$1" ]]; then
    if [[ ! -d "$1" ]]; then
        echo "[-] directory not found: $1"
    fi
    dir="${1}"
    if grep -q '/$' <<< "${1}"; then
        dir="$(sed 's/\/$//' <<< \"${1})\""
    fi
else
    dir="."
fi

latest_artifact=$(ls -l ${dir}/davedittrich-utils-latest.tar.gz 2>/dev/null | awk '{ print $NF; }')
highest_version_artifact=$(ls ${dir}/davedittrich-utils-[0-9]*[0-9].tar.gz 2>/dev/null | sort -r | head -n 1)

if [[ ! -z "${latest_artifact}" ]]; then
    echo "${latest_artifact}"
elif [[ ! -z "${highest_version_artifact}" ]]; then
    echo "${highest_version_artifact}"
else
    echo "None"
fi

exit 0

# vim: set ts=4 sw=4 tw=0 et :
