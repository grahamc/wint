#!/usr/bin/env bash

set -eux

dataset=${1:-tank/local/junk/send}
prevsnap=${2:-pre}

# Protect stdin so we only read from the remote socket when we mean to
exec 10<&0 # Rename our actual stdin to FD10
exec < /dev/null # Replace what our programs will consider stdin with /dev/null

# Protect stdout so we only write to the remote socket when we mean to
exec 11<&1 # Rename our actual stdout to FD11
exec >&2 # Replace what our programs will consider stdout with stderr

if [ "$dataset" = tank/local/junk/send ]; then
    sudo zfs rollback -r tank/local/junk/send@pre
fi

snapname() (
    echo "wint-$(date '+%Y-%m-%dT%H:%m:%S.%N')"
)

currentsnap=""

while true; do
    currentsnap=$(snapname)
    sudo zfs snapshot "$dataset@$currentsnap"
    echo "$currentsnap" >&11
    sudo zfs send -i "$prevsnap" "$dataset@$currentsnap" >&11

    read -r -u 10 resp
    if [ -z "$resp" ]; then
        echo "Empty read"
        exit 0
    elif [ "$resp" == "received" ]; then
        if [ -n "$prevsnap" ] && [ "$prevsnap" != "pre" ]; then
            sudo zfs destroy "$dataset@$prevsnap"
        fi
    fi
    prevsnap=$currentsnap
done
