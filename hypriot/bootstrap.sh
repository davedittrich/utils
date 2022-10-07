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
LOCAL_SERVER="http://192.168.0.22:8888"
ARTIFACT_DIR="/root"


# Function to get the identifier for the Ansible Collection to be
# installed for execution on first boot.  It gets the result from
# one of three options:
# 1. The name of the artifact inserted using the `--file` option
#    when flashing the SD card;
# 2. The last generated development version of the artifact being
#    served by an HTTP server (typically) on the local network,
#    such as the development host;
# 3. The generic name of the Ansible Collection consisting of the
#    namespace + collection (i.e., `davedittrich.utils`)
#
function get_artifact() {
    # Just in case there is more than one, look for the latest artifact
    # in /boot directory.
    local boot_artifact="$(cd /boot && ls davedittrich-utils-*.tar.gz 2>/dev/null | sort -r | head -n 1)"
    if [[ ! -z "${boot_artifact}" ]]; then
	# Move it to /root to save space on /boot partition. HypriotOS default /boot partition is
	# small and until it can be expanded, it may not even hold the collection artifact itself!
        mv "/boot/${boot_artifact}" ${ARTIFACT_DIR}/
        echo "${ARTIFACT_DIR}/${boot_artifact}"
    elif (cd ${ARTIFACT_DIR} && curl --fail --silent --connect-timeout 5 -O ${LOCAL_SERVER}/davedittrich-utils-latest.tar.gz); then
        echo "${ARTIFACT_DIR}/davedittrich-utils-latest.tar.gz"
    else
        echo davedittrich.utils
    fi
}

# Operate out of /root by default.
#
cd /root

# Call the function to get the identifier for the collection now,
# so it is more obvious in the console output at boot time.
#
collection_artifact=$(get_artifact)

# Make boot-time running services transparent to help debug
# `cloud-config` enabled services.
#
service --status-all

# Ensure a copy of this script is kept in `/root` to make it
# easier to debug or develop features.
#
[[ -f /root/bootstrap.sh ]] || cp -av /boot/bootstrap.sh /root

# The file `/root/.custom-hook-completed` is used to trigger delayed
# installation of any files cached in the system image to speed up
# customization. This feature helps work around a problem encountered while
# attempting to use `image-build-rpi` and its `chroot` method of package
# installation that can fail when some packages cannot be configured properly,
# in turn causing the entire image creation process to fail.
#
if [[ -f /root/.custom-hook-completed && "$(ls /var/cache/apt/archives/*.deb 2>/dev/null| wc -l)" -gt 0 ]]; then
  dpkg -i /var/cache/apt/archives/*.deb
  apt-get -y --fix-broken install
fi

# Ensure we have an up-to-date Python `pip` and an
# Ansible version that works.  Creates `/root/.local` tree.
#
python3 -m pip install -U pip --user
python3 -m pip install -U "ansible>=2.2.0" --user

# ...but it is not yet in PATH.
#
/root/.local/bin/ansible --version

# Use Ansible ad-hoc mode to ensure it *is* in root's PATH.
#
/root/.local/bin/ansible -i localhost, \
  localhost \
  -c local \
  -m lineinfile \
  -a "dest=/root/.bashrc line='PATH=/root/.local/bin:$PATH' mode=0o600"

# Confirm that works.
source /root/.bashrc
ansible --version

# Install the Ansible Collection for configuring the system.
if [[ ${collection_artifact} == ${ARTIFACT_DIR}/* ]]; then
  ansible-galaxy collection install ${collection_artifact}
else
  ansible-galaxy collection install davedittrich.utils --server=${GALAXY_SERVER}
fi
export COLLECTION_ROOT=$(ansible-galaxy collection list davedittrich.utils 2>/dev/null --format yaml | head -n 1 | sed 's/://')/davedittrich/utils

# Now run the playbook using the FQCN.
ansible-playbook -v \
  -e '{"accounts": ["root","pirate"]}' \
  davedittrich.utils.workstation_setup && touch /root/.installed

# This would be the point at which additional scripts or playbooks
# could be run using a dropin directory. Just saying.
#
# TODO(dittrich): Add dropin capability for additional config.

# We now return you to your regularly schedule `cloud-init` run.
exit 0
