#!/bin/bash
# Copyright (C) 2019-2022 Dave Dittrich. All rights reserved.
#
# Flash a customized hypriotos image to SD card using hypriot
# `flash` that includes the most recent Ansible collection artifact
# for the `davedittrich.utils` collection. Any arguments passed to
# this script are assumed to be files that you want placed in the
# `/boot` directory (which is limited in space, so be sparing).

FLASH=${FLASH:-$(command -v flash)}
USAGE="$0 image cloud-config collection_artifact [files_for_boot ...]"

HYPRIOT_USER="$(psec secrets get hypriot_user)"
if [[ -z "${HYPRIOT_USER}" ]]; then
    echo "[-] could not get 'hypriot_user'"
    exit 1
fi

HYPRIOT_PASSWORD="$(psec secrets get hypriot_password)"
if [[ -z "${HYPRIOT_PASSWORD}" ]]; then
    echo "[-] could not get 'hypriot_password'"
    exit 1
fi

# Process command line arguments.
IMAGE=$1; shift
if [[ -z "${IMAGE}" ]]; then
    echo "[-] usage: ${USAGE}"
    exit 1
elif [[ ! -f "${IMAGE}" ]]; then
    echo "[-] file not found: ${IMAGE}"
    exit 1
fi

CLOUD_CONFIG=$1; shift
if [[ -z "${CLOUD_CONFIG}" ]]; then
    echo "[-] 'cloud-config' file not specified"
    echo "[-] usage: ${USAGE}"
    exit 1
elif [[ ! -f "${CLOUD_CONFIG}" ]]; then
    echo "[-] file not found: ${CLOUD_CONFIG}"
    exit 1
fi


COLLECTION_ARTIFACT=${1:-None}; shift

# Should a `--file` option be used to include a pre-built
# collection artifact to be installed at boot time?
COLLECTION_FILE_OPTION=""
if [[ "${COLLECTION_ARTIFACT}" = "None" ]]; then
    echo "[+] boot image will not include pre-built collection artifact"
elif [[ ! -f "${COLLECTION_ARTIFACT}" ]]; then
    echo "[-] file not found: ${COLLECTION_ARTIFACT}"
    exit 1
else
    COLLECTION_FILE_OPTION="--file ${COLLECTION_ARTIFACT}"
fi

# Validate pre-requisites.
if [[ -z "${FLASH}" ]]; then
    echo "[-] 'flash' not found in \$PATH or defined in environment variable 'FLASH'"
fi

# Use the `psec` envirionment variables to configure `flash` operation
# and include `--file` options for all remaining command line arguments.
# TODO(dittrich): Make the `--file` stuff be a function on an array.
psec run -- ${FLASH} \
    --bootconf config.txt \
    --cmdline cmdline.txt \
    --userdata ${CLOUD_CONFIG} \
    --file bootstrap.sh \
    ${COLLECTION_FILE_OPTION} \
    $(for file in $@; do echo " --file $file"; done) \
    ${IMAGE} &&
    echo -n "[+] Reminder: log in to host '${HYPRIOT_HOSTNAME}' " &&
    echo "with user name '${HYPRIOT_USER}' and password '${HYPRIOT_PASSWORD}'"

exit $?

# vim: set ts=4 sw=4 tw=0 et :
