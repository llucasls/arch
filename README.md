This repo is for implementing my own install script. If you're looking for a
script made for you, I recommend you look into Arch's official `archinstall`.

Steps for installation:

1. Boot into the Arch Linux installation media.
2. Set the keyboard layout using the loadkeys command.
3. Verify the boot mode by checking if the /sys/firmware/efi/efivars directory exists. If it does, you are in UEFI mode; otherwise, you are in BIOS mode.
4. Connect to the internet, if necessary, using either Ethernet or Wi-Fi.
5. Update the system clock with the command timedatectl set-ntp true.
6. Partition the disk using a partitioning tool like fdisk, cfdisk, or parted. Create the necessary partitions for the root filesystem, boot partition (if using BIOS), and the EFI system partition (if using UEFI).
7. Format the partitions using appropriate filesystems (e.g., ext4 for root partition, vfat for EFI partition).
8. Mount the partitions using the mount command. Mount the root partition to /mnt and the EFI partition to /mnt/boot/efi (if using UEFI).
9. Install essential packages and base system using the pacstrap command. For example: pacstrap /mnt base base-devel.
10. Generate an fstab file with the command genfstab -U /mnt >> /mnt/etc/fstab.
11. Chroot into the installed system using the arch-chroot command: arch-chroot /mnt.
12. Set the system language by uncommenting the desired locale(s) in /etc/locale.gen and generating them with locale-gen.
13. Set the system's timezone by creating a symlink to the appropriate timezone file in /usr/share/zoneinfo.
14. Configure the hardware clock to use UTC with the command hwclock --systohc --utc.
15. Set the hostname by editing /etc/hostname and adding the desired hostname.
16. Edit the /etc/hosts file and add an entry for the hostname and its corresponding IP address (usually 127.0.0.1).
17. Set the root password using the passwd command.
18. Install and configure a bootloader (e.g., GRUB or systemd-boot) to make the system bootable. Refer to the Arch Linux Wiki for detailed instructions on setting up the bootloader of your choice.
19. Exit the chroot environment with the exit command.
20. Unmount the partitions using the umount command: umount -R /mnt.
21. Reboot the system with the reboot command.
