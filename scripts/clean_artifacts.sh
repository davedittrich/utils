
#!/bin/bash
# Copyright (C) 2019-2022 Dave Dittrich. All rights reserved.
#
# Delete all artifacts except the last created artifact to clean
# up disk space.
#
# This script relies on another script that is assumed to exist
# in the same directory as this script.

last_artifact="$(bash $(dirname $0)/get_last_artifact.sh)"

if [[ "${last_artifact}" = "None" ]]; then
    echo "[-] no artifacts found" >&2
    exit 1
fi

for artifact in $(ls davedittrich-utils-[0-9]*[0-9].tar.gz 2>/dev/null | sort -r | tail -n +2); do
    if [[ "${artifact}" != "${last_artifact}" ]]; then
        echo "[+] removing ${artifact}"
        rm ${artifact}
    fi
done

exit 0
