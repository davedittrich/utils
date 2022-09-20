#!/bin/bash
# Copyright (C) 2019-2022 Dave Dittrich. All rights reserved.
#
# Flash a customized hypriotos image to SD card using hypriot
# `flash` that includes the most recent Ansible collection artifact
# for the `davedittrich.utils` collection. Any arguments passed to
# this script are assumed to be files that you want placed in the
# `/boot` directory (which is limited in space, so be sparing).

FLASH=${FLASH:-$(command -v flash)}
USAGE="$0 image cloud-config collection_artifact [files_for_boot]"

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


COLLECTION_ARTIFACT=$1; shift
if [[ -z "${COLLECTION_ARTIFACT}" ]]; then
  echo "[-] collection artifact not specified"
  echo "[-] usage: ${USAGE}"
elif [[ ! -f "${COLLECTION_ARTIFACT}" ]]; then
  echo "[-] file not found: ${COLLECTION_ARTIFACT}"
  exit 1
fi

# Validate pre-requisites.

if [[ -z "${FLASH}" ]]; then
  echo "[-] 'flash' not found in \$PATH or defined in environment variable 'FLASH'"
fi

psec run -- ${FLASH} \
  --bootconf config.txt \
  --cmdline cmdline.txt \
  --userdata ${CLOUD_CONFIG} \
  --file bootstrap.sh \
  --file ${COLLECTION_ARTIFACT} \
  $(for file in "$@"; do echo "--file $file "; done) \
  ${IMAGE}

exit 0
