#!/bin/bash

source /etc/os-release
if [ "${ID}" != "arch" ]; then
    echo "Error: current distribution is not Arch Linux" >&2
    exit 1
fi

lsblk -o name,fstype,size,label,mountpoints,path

echo "Please, state the path of the device to be partitioned."
read -er -p "device: " DEVICE

if test ! -b ${DEVICE}; then
    echo "The file ${DEVICE} is not a valid device" >&2
    exit 2
fi

if test ${DEVICE} != /dev/sda; then
  PATTERN=${DEVICE//\//\\\/}
  sed -i -e "s/\/dev\/sda/${PATTERN}/g" tables/partition_table.dump
fi

# partition the disk
sfdisk "${DEVICE}" < tables/partition_table.dump

BOOT_PART="${DEVICE}1"
ROOT_PART="${DEVICE}2"
HOME_PART="${DEVICE}5"
SWAP_PART="${DEVICE}6"

# create filesystems
mkfs.ext4 ${BOOT_PART}
mkfs.ext4 ${ROOT_PART}
mkfs.ext4 ${HOME_PART}
mkswap ${SWAP_PART}

# mount partitions
mount ROOT_PART /mnt
mount BOOT_PART /mnt/boot
mount HOME_PART /mnt/home
swapon SWAP_PART

# My system clock is wonky, so this is a workaround
DATETIME="$(curl -IL https://thecliwizard.xyz | grep -iE '^date' | cut -d ' ' -f 3-6)"

declare -A MONTH_LIST=(
  [Jan]=01
  [Feb]=02
  [Mar]=03
  [Apr]=04
  [May]=05
  [Jun]=06
  [Jul]=07
  [Aug]=08
  [Sep]=09
  [Oct]=10
  [Nov]=11
  [Dec]=12
)

UTC="Etc/UTC"
BRASILIA_TIME_ZONE="America/Sao_Paulo"

MONTH_STR=${DATETIME:3:3}

DAY=${DATETIME:0:2}
MONTH=${MONTH_LIST[${MONTH_STR}]}
YEAR=${DATETIME:7:4}
TIME=${DATETIME:12}

DATE="${YEAR}-${MONTH}-${DAY}"

# synchronize system time
update_clock() {
  timedatectl set-ntp false
  sleep 0.25
  timedatectl set-timezone ${UTC}
  sleep 0.25
  timedatectl set-time "${DATE} ${TIME}"
  sleep 0.25
  timedatectl set-timezone ${BRASILIA_TIME_ZONE}
  sleep 0.25
  timedatectl set-ntp true
}

# install everything you need
pacstrap -K /mnt base base-devel linux-lts linux-firmware

arch-chroot /mnt update_clock
arch-chroot /mnt pacman -S grub
