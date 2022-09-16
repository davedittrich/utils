#!/bin/bash
# Copyright (C) 2019-2022 Dave Dittrich. All rights reserved.
#
# Identify the last built artifact and return its name. This script
# assumes the artifacts are located in the current working directory,
# as would occur when run from the `Makefile` in the repo root directory.

last_artifact=$(ls davedittrich-utils-*.tar.gz 2>/dev/null | sort -r | head -n 1)
if [[ -z "${last_artifact}" ]]; then
  echo "None"
else
  echo "${last_artifact}"
fi
exit 0
