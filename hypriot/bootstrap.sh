#!/bin/bash
# Copyright (C) 2022 Dave Dittrich. All rights reserved.
# Author: Dave Dittrich <dave.dittrich@gmail.com>
#
# This script performs all of the bootstrapping functions for first boot.
# It is assumed it is written to `/boot` using Hypriot `flash` with the
# `--file` option.
#
# When debugging, it will remain on the system in `/root/bootstrap.sh` so
# you can run it again manually. (Do not forget to make *sure* you have
# merged any changes made to the script on the RPi *before* you reflash
# the SD card!)

set -ex

export ANSIBLE_FORCE_COLOR=true
export DEBIAN_FRONTEND=noninteractive
GALAXY_SERVER="https://galaxy-dev.ansible.com"
LOCAL_SERVER="http://192.168.1.135:8888"
ARTIFACT_DIR="/boot"

# function download_test_artifact() {
# }

function get_artifact() {
    # Look first for an artifact inserted when flashing the SD card
    # using the `--file` option. If not found, try to download the
    # latest built artifact from a local server.
    local boot_artifact="$(ls ${ARTIFACT_DIR}/davedittrich-utils-*.tar.gz 2>/dev/null | sort -r | head -n 1)"
    if [[ -z "${boot_artifact}" ]]; then
        ( \
            cd ${ARTIFACT_DIR} && \
            curl -O ${LOCAL_SERVER}/davedittrich-utils-latest.tar.gz && \
            echo davedittrich-utils-latest.tar.gz \
        )
    else
	echo ${boot_artifact}
    fi
}

cd /root
service --status-all

# Ensure a copy of this script is kept in /root.
[[ -f /root/bootstrap.sh ]] || cp -av /boot/bootstrap.sh /root

# The file `/root/.custom-hook-completed` is used to trigger delayed
# installation of any files cached in the system image to speed up
# customization. This feature helps work around a problem encountered while
# attempting to use `image-build-rpi` and its `chroot` method of package
# installation that can fail when some packages cannot be configured properly,
# in turn causing the entire image creation process to fail.

if [[ -f /root/.custom-hook-completed && "$(ls /var/cache/apt/archives/*.deb 2>/dev/null| wc -l)" -gt 0 ]]; then
  dpkg -i /var/cache/apt/archives/*.deb
  apt-get -y --fix-broken install
fi

# Ensure we have an Ansible version that works.

python3 -m pip install -U pip --user
python3 -m pip install -U "ansible>=2.2.0" --user
/root/.local/bin/ansible --version

# Use Ansible ad-hoc mode to ensure it is in root's PATH.

/root/.local/bin/ansible -i localhost, \
  localhost \
  -c local \
  -m lineinfile \
  -a "dest=/root/.bashrc line='PATH=/root/.local/bin:$PATH' mode=0o600"
source /root/.bashrc
ansible --version

# Get any development collection artifact newer than the version
# specified above.
collection_artifact=$(get_artifact)

# Default to the generic collection name to load from Ansible Galaxy.
collection_artifact=${collection_artifact:-davedittrich-utils}
if [[ ${collection_artifact} == ${ARTIFACT_DIR}/* ]]; then
  ansible-galaxy collection install ${collection_artifact}
  echo "[+] moving ${collection_artifact} to /root to save space on /boot"
  mv ${collection_artifact} /root
else
  ansible-galaxy collection install ${collection_artifact} --server=${GALAXY_SERVER}
fi
export COLLECTION_ROOT=$(ansible-galaxy collection list davedittrich.utils 2>/dev/null --format yaml | head -n 1 | sed 's/://')/davedittrich/utils

# Now run the playbook using the FQCN.
ansible-playbook -v \
  -e '{"accounts": ["root","pirate"]}' \
  davedittrich.utils.workstation_setup && touch /root/.installed

exit 0
