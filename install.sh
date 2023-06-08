#!/bin/bash

source /etc/os-release
if [ "${ID}" != "arch" ]; then
    echo "Error: current distribution is not Arch Linux" >&2
    exit 1
fi

DEVICE=/dev/sda

# synchronize system time
timedatectl set-ntp true

# partition the disk
sfdisk "${DEVICE}" < tables/partition_table.dump
