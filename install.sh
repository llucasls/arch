#!/bin/bash

eval " $(cat /etc/os-release)"
if [ "$NAME" != "Arch Linux" ]; then
    echo "Error: current distribution is not Arch Linux" > /dev/stderr
fi

DEVICE=/dev/sda

timedatectl set-ntp true

sfdisk "${DEVICE}" < tables/partition_table.dump
