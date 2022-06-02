#!/bin/bash

eval " $(cat /etc/os-release)"
if [ "$NAME" != "Arch Linux" ]; then
    echo "Error: current distribution is not Arch Linux" > /dev/stderr
fi

DEVICE=/dev/sda

# synchronize system time
timedatectl set-ntp true

# partition the disk
sfdisk "${DEVICE}" < tables/partition_table.dump
