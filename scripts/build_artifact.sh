#!/bin/bash
# Copyright (C) 2019-2022 Dave Dittrich. All rights reserved.
#
# Build a new artifact and link a generic name ending with
# `-latest.tar.gz` for convenience during development and testing.
#
# This script relies on another script that is assumed to exist
# in the same directory as this script.

function remove_broken_link() {
	if [[ -L "${artifact_link}" ]]; then
	    if [[ "$(md5sum ${artifact_link})"  != "$(md5sum ${artifact})" ]]; then
            echo "[-] removing broken symbolic link '${artifact_link}'"
            rm "${artifact_link}"
		fi
    fi
}

if ! bumpversion --allow-dirty build; then
    echo "[-] failed to bump version number"
    exit 1
fi

VERSION="$(cat VERSION)"
echo "[+] new version number: ${VERSION}"

# Template out `galaxy.yml` file.
ansible-playbook -i 'localhost,' build/galaxy_yml_create.yml

artifact="davedittrich-utils-${VERSION}.tar.gz"
artifact_link="davedittrich-utils-latest.tar.gz"

echo "[+] building artifact: ${artifact}"
ansible-playbook -i 'localhost,' -e '{"_no_log": true, "publish": false}' build/galaxy_deploy.yml
if [[ $? -ne 0 ]]; then
    echo "[-] failed to build artifact"
	remove_broken_link
    exit 1
fi

new_artifact=$($(dirname $0)/get_last_artifact.sh ${PWD})
if [[ ! "${new_artifact}" =~ "${artifact}" ]]; then
    echo "[-] expected artifact not found: ${artifact} (got '${new_artifact}')"
	remove_broken_link
	exit 1
fi
exit 0
