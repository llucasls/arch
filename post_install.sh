#!/bin/bash

PACKAGES=$(< arch_packages)
FONTS=$(< arch_fonts)

pacman -S ${PACKAGES} ${FONTS}

USER=lucas
HOME=/home/${USER}
REPOS_DIR=${HOME}/.repos

mkdir -p ${REPOS_DIR}

git clone https://github.com/llucasls/dwm.git ${REPOS_DIR}/dwm
make --file=${REPOS_DIR}/dwm/Makefile install clean

git clone https://github.com/llucasls/dmenu.git ${REPOS_DIR}/dmenu
make --file=${REPOS_DIR}/dmenu/Makefile install clean

git clone https://github.com/llucasls/st.git ${REPOS_DIR}/st
make --file=${REPOS_DIR}/st/Makefile install clean

git clone https://github.com/llucasls/tabbed.git ${REPOS_DIR}/tabbed
make --file=${REPOS_DIR}/tabbed/Makefile install clean

chown -R ${USER}:${USER} ${HOME}
