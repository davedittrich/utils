#!/bin/bash
# Copyright (C) 2019-2022 Dave Dittrich. All rights reserved.
#
# Show the contents of the build artifact to help make sure that
# there are no leaks of secrets by accidental inclusion in the
# 'ansible-galaxy' built collection artifact. This is necessary because
# files are included by default if not explicitly excluded by the
# 'galaxy.yml' file, which requires relative paths to files (even
# when wildcards are used) and explicitly listing them in the
# 'build_ignore' list.
#
# This script relies on another script that is assumed to exist
# in the same directory as this script.

last_artifact="$(bash $(dirname $0)/get_last_artifact.sh ${PWD})"
artifact="${1:-${last_artifact}}"

if [[ -z "${artifact}" ]]; then
    echo "usage: $0 artifact"
    exit 1
fi

if [[ "${artifact}" == "None" ]]; then
    echo "[-] no artifact found: need to do 'make build'?"
    exit 2
fi

if [[ ! -f "${artifact}" ]]; then
    echo "$0: artifact not found: ${artifact}"
    exit 3
fi

echo "[+] contents of ${artifact}:"
tar -tzf "${artifact}" | grep -v '.*/$$' | while read line; do echo ' -->' $line; done

exit 0
