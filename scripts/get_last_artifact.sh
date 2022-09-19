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
last_artifact=$(ls ${dir}/davedittrich-utils-*.tar.gz 2>/dev/null | sort -r | head -n 1)
if [[ -z "${last_artifact}" ]]; then
  echo "None"
else
  echo "${last_artifact}"
fi
exit 0
