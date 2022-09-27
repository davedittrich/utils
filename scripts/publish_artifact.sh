#!/bin/bash
# Copyright (C) 2019-2022 Dave Dittrich. All rights reserved.
#
# Build and publish an artifact.

# Make error messages a little easier to read than `ansible.builtin.assert`.

if [[ -z "${ANSIBLE_GALAXY_SERVER}" ]]; then
	echo "[-] no environment variable found: ANSIBLE_GALAXY_SERVER"
	exit 1
elif [[ -z "${ANSIBLE_GALAXY_API_KEY}" ]]; then
	echo "[-] no environment variable found: ANSIBLE_GALAXY_SERVER"
	exit 1
fi

# Now call build script passing boolean to publish after build.
DAVEDITTRICH_UTILS_PUBLISH="true" bash $(dirname $0)/build_artifact.sh
exit $?

# vim: set ts=4 sw=4 tw=0 et :
