#!/bin/bash

PACKAGES=$(< arch_packages)
FONTS=$(< arch_fonts)

pacman -S ${PACKAGES} ${FONTS}
