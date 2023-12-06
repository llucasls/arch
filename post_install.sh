#!/bin/bash

OPTERR=0

user=
home=
repos=

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
		printf 'Error: this script must be run as root\n' >&2
		exit 10
	fi
}

install_packages() {
	local PACKAGES="$(< artix_packages)"
	local FONTS="$(< arch_fonts)"
	local MATE="$(< mate_packages)"

	printf '\n%s\n%s\n' '[lib32]' 'Include = /etc/pacman.d/mirrorlist' \
		>> /etc/pacman.conf

	pacman -Sy ${PACKAGES} ${FONTS}
}

install_rust_packages() {
	local PACKAGES="$(< cargo_packages)"

	runuser -u "${user}" cargo install ${PACKAGES}
}

install_suckless() {
	if test ! -d "$1/$2"; then
		runuser -u "${user}" git clone git@github.com:llucasls/$2.git "$1/$2"
		make --directory="$1/$2" install clean
	fi
}

setup_configs() {
	runuser -u "${user}" mkdir -p "${home}/.config"
	cd "${home}/.config"
	runuser -u "${user}" git init
	runuser -u "${user}" git remote add origin https://github.com/llucasls/dotfiles.git
	runuser -u "${user}" git pull origin arch
	chsh -s "$(which fish)" "${user}"
	cd -
}

setup_environment() {
	runuser -u "${user}" fish -c "set -Ux XDG_CONFIG_HOME $home/.config"
	runuser -u "${user}" fish -c "set -Ux XDG_DATA_HOME $home/.local/share"
	runuser -u "${user}" fish -c "set -Ux XDG_STATE_HOME $home/.local/state"
	runuser -u "${user}" fish -c "set -Ux XDG_CACHE_HOME $home/.cache"
}

setup_path() {
	runuser -u "${user}" mkdir -p "${home}/.bin" "${home}/.local/bin" \
		"${home}/.cargo/bin" "${home}/.yarn/bin"
	runuser -u "${user}" fish -c \
		"fish_add_path -Up $home/.bin $home/.local/bin \
		$home/.cargo/bin $home/.yarn/bin"
}

setup_scripts() {
	true
}

show_help() {
	printf '%s\n' "${help_msg}"
}

set_variables() {
	while getopts 'u:d:r:h' option; do
		case ${option} in
			u)
				user="${OPTARG}"
				;;
			d)
				home="${OPTARG}"
				;;
			r)
				repos="${OPTARG}"
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

	if test -z "${user}" -a -n "${DOAS_USER}"; then
		user="${DOAS_USER}"
	elif test -z "${user}" -a -n "${SUDO_USER}"; then
		user="${SUDO_USER}"
	elif test -z "${user}"; then
		printf 'Error: username not provided\n' >&2
		exit 1
	fi

	if test -z "${home}"; then
		home="/home/${user}"
	fi

	if test -z "${repos}"; then
		repos="${home}/.repos"
	fi
}

main() {
	validate_user

	install_packages
	install_rust_packages

	install -o "${user}" -g "${user}" -d "${repos}"

	install_suckless "${repos}" dwm
	install_suckless "${repos}" dmenu
	install_suckless "${repos}" st
	install_suckless "${repos}" tabbed

	runuser -u "${user}" ./install_pipx.py

	setup_configs
	setup_environment
	setup_path
}

set_variables $@
main
