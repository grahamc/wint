#!/usr/bin/env bash

set -eux

dataset=${1:-tank/local/junk/recv}

# Protect stdin so we only read from the remote socket when we mean to
exec 10<&0 # Rename our actual stdin to FD10
exec < /dev/null # Replace what our programs will consider stdin with /dev/null

# Protect stdout so we only write to the remote socket when we mean to
exec 11<&1 # Rename our actual stdout to FD11
exec >&2 # Replace what our programs will consider stdout with stderr

if [ "$dataset" = tank/local/junk/recv ]; then
    sudo zfs rollback -r tank/local/junk/recv@pre
fi

prevrecv=""
while read -r -u 10 snapname; do
    echo "Receiving: $dataset@$snapname"
    sudo zfs receive "$dataset" <&10
    echo "received" >&11
    if [ -n "$prevrecv" ]; then
        sudo zfs destroy "$dataset@$prevrecv"
    fi
    prevrecv=$snapname
done
