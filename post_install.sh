#!/bin/bash

OPTERR=0

TARGET_USER=
TARGET_HOME=
REPOS_DIR=

help_msg=$(cat <<EOF
post_install.sh - set up your desktop after a fresh Artix install

# ./post_install.sh -u USER [-d HOME_DIR] [-r REPOS_DIR]
$ doas ./post_install.sh [-u USER] [-d HOME_DIR] [-r REPOS_DIR]
$ sudo ./post_install.sh [-u USER] [-d HOME_DIR] [-r REPOS_DIR]
$ ./post_install.sh -h

Description:
    In the first form, the script is run directly as root. It requires the
    username to be passed using the -u option. In the second and third forms,
    the username is taken from DOAS_USER and SUDO_USER, respectively. In all of
    them, you can optionally pass a home directory and a repos directory.
    The fourth form shows this help message.
EOF
)

validate_user() {
	if test "$(id -u)" -ne 0; then
		printf "Error: this script must be run as root\n" >&2
		exit 10
	fi
}

install_packages() {
	PACKAGES="$(< arch_packages)"
	FONTS="$(< arch_fonts)"

	pacman -S ${PACKAGES} ${FONTS}
}

install_suckless() {
	git clone https://github.com/llucasls/$2.git "$1/$2"
	make --file="$1/$2/Makefile" install clean
}

show_help() {
	printf '%s\n' "${help_msg}"
}

set_variables() {
	while getopts 'u:d:r:h' option; do
		case ${option} in
			u)
				TARGET_USER="${OPTARG}"
				;;
			d)
				TARGET_HOME="${OPTARG}"
				;;
			r)
				REPOS_DIR="${OPTARG}"
				;;
			h)
				show_help
				exit 0
				;;
			?)
				show_help
				exit 1
				;;
		esac
	done

	if test -z "${TARGET_USER}" -a -n "${DOAS_USER}"; then
		TARGET_USER="${DOAS_USER}"
	elif test -z "${TARGET_USER}" -a -n "${SUDO_USER}"; then
		TARGET_USER="${SUDO_USER}"
	elif test -z "${TARGET_USER}"; then
		printf "Error: username not provided\n" >&2
		exit 1
	fi

	if test -z "${TARGET_HOME}"; then
		TARGET_HOME="/home/${TARGET_USER}"
	fi

	if test -z "${REPOS_DIR}"; then
		REPOS_DIR="${TARGET_HOME}/.repos"
	fi
}

main() {
	validate_user

	install_packages

	install -o "${TARGET_USER}" -g "${TARGET_USER}" -d "${REPOS_DIR}"

	install_suckless "${REPOS_DIR}" dwm
	install_suckless "${REPOS_DIR}" dmenu
	install_suckless "${REPOS_DIR}" st
	install_suckless "${REPOS_DIR}" tabbed

	runuser -u "${TARGET_USER}" ./install_pipx.py
}

set_variables $@
main
