#!/bin/bash
# Copyright (C) 2019-2022 Dave Dittrich. All rights reserved.
#
# Identify the 'conda' and 'psec' environments active for this project.
# Both virtual environment and shell environment variables for overall
# configuration are managed using 'conda', with 'python-secrets' ('psec')
# for storing project configuration, secrets, temporary files, etc.

if [[ "$GITHUB_ACTIONS" == "true" ]]; then
    echo '[-] check-conda: running in a GitHub Actions workflow'
	exit 0
fi

conda_env=${CONDA_DEFAULT_ENV:-None}
psec_env=$(psec environments default 2>/dev/null)

if [[ -z "${conda_env}" ]]; then
    echo '[-] conda does not appear to be installed'
    exit 1
fi

if [[ "${conda_env}" = "base" ]]; then
    echo "[-] please 'conda activate' the environment for this project (don't use 'base')"
    exit 1
fi

if [[ -z "${psec_env}" ]]; then
    echo "[-] default 'psec' environment cannot be determined"
    exit 1
fi

echo "[+] using 'conda' environment '${conda_env}' and 'psec' environment '${psec_env}'"
exit 0

# vim: set ts=4 sw=4 tw=0 et :
