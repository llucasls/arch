#!/bin/bash

eval " $(cat /etc/os-release)"
if [ "$NAME" != "Arch Linux" ]; then
    echo "Error: current distribution is not Arch Linux" > /dev/stderr
fi

timedatectl set-ntp true
