#!/bin/bash
# Copyright (C) 2019-2022 Dave Dittrich. All rights reserved.
#
# Build a new artifact and link a generic name ending with
# `-latest.tar.gz` for convenience during development and testing.
#
# This script relies on another script that is assumed to exist
# in the same directory as this script.

# Set `DAVEDITTICH_UTILS_PUBLISH` in environment to publish after build.
DAVEDITTRICH_UTILS_PUBLISH=${DAVEDITTRICH_UTILS_PUBLISH:-false}

function remove_broken_link() {
	if [[ -L "${artifact_link}" ]]; then
	    if [[ "$(md5sum ${artifact_link})"  != "$(md5sum ${artifact})" ]]; then
            echo "[-] removing broken symbolic link '${artifact_link}'"
            rm "${artifact_link}"
		fi
    fi
}

if [[ "$GITHUB_ACTIONS" == "true" ]]; then
    echo '[+] running in a GitHub Actions workflow (not bumping version)'
elif ! bumpversion --allow-dirty build; then
    echo "[-] failed to bump version number"
    exit 1
fi

VERSION="$(cat VERSION)"
echo "[+] new version number: ${VERSION}"

# Template out `galaxy.yml` file.
ansible-playbook -i 'localhost,' build/galaxy_yml_create.yml

artifact="davedittrich-utils-${VERSION}.tar.gz"
artifact_link="davedittrich-utils-latest.tar.gz"

if [[ "${DAVEDITTRICH_UTILS_PUBLISH}" = "true" ]]; then
    echo "[+] preparing to publish collection to $ANSIBLE_GALAXY_SERVER: ${artifact}"
    ansible-playbook -i 'localhost,' -e '{"_no_log": true, "publish": true}' build/galaxy_deploy.yml
    if [[ $? -ne 0 ]]; then
        echo "[-] publishing artifact failed: cleaning up"
        remove_broken_link
        exit 1
    fi
    echo "[+] successfully published collection to $ANSIBLE_GALAXY_SERVER: ${artifact}"
else
    echo "[+] building collection artifact: ${artifact}"
    ansible-playbook -i 'localhost,' -e '{"_no_log": true, "publish": false}' build/galaxy_deploy.yml
    new_artifact=$($(dirname $0)/get_last_artifact.sh ${PWD})
    if [[ ! "${new_artifact}" =~ "${artifact}" ]]; then
        echo "[-] expected artifact not found: ${artifact} (got '${new_artifact}')"
        remove_broken_link
        exit 1
    fi
    echo "[+] successfully built collection artifact: ${artifact}"
fi
exit 0

# vim: set ts=4 sw=4 tw=0 et :
