#!/usr/bin/env bash
##
## Author: Stephen Ribich <stephen@ribich.dev>
## URL:    https://github.com/sribich/bash-starter
##
## ______           _       _____ _             _
## | ___ \         | |     /  ___| |           | |
## | |_/ / __ _ ___| |___  \ `--.| |_ __ _ _ __| |_ ___ _ __
## | ___ \/ _` / __| '_  \  `--. \ __/ _` | '__| __/ _ \ '__|
## | |_/ / (_| \__ \ | | | /\__/ / || (_| | |  | ||  __/ |
## \____/ \__,_|___/_| |_| \____/ \__\__,_|_|   \__\___|_|
##
## License: MIT

################################################################################
## Configs
################################################################################
declare -Ag BASH_STARTER=(
    [VERSION]="master"
    [LIB_DIR]="lib"

    ## Do not change any variables past this in the BASH_STARTER
    ## array unless you know what you are doing
    [GIT_URL]="https://raw.githubusercontent.com/sribich/bash-starter"
    [LIB_URL]="${BASH_STARTER[GIT_URL]}/${BASH_STARTER[VERSION]}/lib"
)

declare -a BASH_STARTER_IMPORT_SOURCES=(
    "./../bash-starter/lib/modules"
    # "${BASH_STARTER[LIB_URL]}/modules"
)

declare -a BASH_STARTER_DEFAULT_MODULES=(

)

################################################################################
## Bootstrap
################################################################################
set -o errexit  # Exit when a command returns a non-zero status code
set -o nounset  # Exit when an unset variable is used
set -o pipefail # Exit when a command fails in a pipe

declare -g BOOTSTRAP_DIR                                       \
        && BOOTSTRAP_DIR="$(cd "${BASH_SOURCE[0]%/*}" && pwd)" \
        && BOOTSTRAP_DIR="${BOOTSTRAP_DIR}/${BASH_STARTER[LIB_DIR]}"

mkdir -p "${BOOTSTRAP_DIR}"

if [[ ! -f "${BOOTSTRAP_DIR}/bootstrap" ]]; then
    if command -v wget 1>/dev/null 2>&1; then
        wget -O "${BOOTSTRAP_DIR}/bootstrap" "${BASH_STARTER[LIB_URL]}/bootstrap"
    elif command -v curl 1>/dev/null 2>&1; then
        curl -fsLo "${BOOTSTRAP_DIR}/bootstrap" "${BASH_STARTER[LIB_URL]}/bootstrap"
    else
        printf "Bash Starter requires either wget or curl to be installed\n" 1>&2
        exit 1
    fi
fi

# shellcheck source=lib/bootstrap
source "${BOOTSTRAP_DIR}/bootstrap"

##############
## Your Script
##############
display_logo()
{
    # shellcheck disable=2016
    local arch_logo=(
        '                   -`                 '
        '                  .o+`                '
        '                 `ooo/                '
        '                `+oooo:               '
        '               `+oooooo:              '
        '               -+oooooo+:             '
        '             `/:-:++oooo+:            '
        '            `/++++/+++++++:           '
        '           `/++++++++++++++:          '
        '          `/+++ooooooooooooo/`        '
        '         ./ooosssso++osssssso+`       '
        '        .oossssso-````/ossssss+`      '
        '       -osssssso.      :ssssssso.     '
        '      :osssssss/        osssso+++.    '
        '     /ossssssss/        +ssssooo/-    '
        '   `/ossssso+/:-        -:/+osssso+-  '
        '  `+sso+:-`                 `.-/+oso: '
        ' `++:.                           `-/+/'
        ' .`                                 ` '
    )

    local arch_logo_y="${#arch_logo[@]}"
    local arch_logo_x="${#arch_logo[0]}"

    local screen_y && screen_y=$(tput lines)
    local screen_x && screen_x=$(tput cols)

    local y_mod=0

    clear
    tput civis

    printf "\e[1;96m"

    for i in "${!arch_logo[@]}"; do
        y_mod=$(( i - (arch_logo_y / 2) ))

        tput cup                           \
             $(( (screen_y / 2) + y_mod )) \
             $(( (screen_x - arch_logo_x) / 2 ))

        printf "%b\n" "${arch_logo[$i]}"
        sleep 0.05
    done

    printf "\e[0m\n"

    sleep 1

    tput cvvis
    clear
}

main()
{
    # display_logo

    import param
    import menu

    import exception

    Menu::Create test

    Menu::Item test b c

    Menu::Item test "Display" "Function" "Display"
    Menu::Item test "names" "Function"
    Menu::Run test
}

main "$@"
exit 0





source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/lib/bootstrap"

if [[ -n "${DEBUG:-}" ]]; then
    activate_module debug
fi

activate_module array
activate_module runtime
activate_module selection
activate_module menu

###############################################################################
## Imports
###############################################################################

##
# When scripts are executed, they run under the directory in which they
# were called. This command remedies that by changing the directory to the
# folder in which the executed file resides.
##
declare -rg root_dir="$(dirname "$(readlink -f "$0" || realpath "$0")")" || exit

source "${root_dir}/src/config"

source "${root_dir}/src/boot_mode"
source "${root_dir}/src/connection"

source "${root_dir}/src/util/system"

source "${root_dir}/src/steps/01/keymap"
source "${root_dir}/src/steps/02/editor"
source "${root_dir}/src/steps/03/partition_disk"
source "${root_dir}/src/steps/04/base_system"
source "${root_dir}/src/steps/05/fstab"
source "${root_dir}/src/steps/06/hostname"
source "${root_dir}/src/steps/07/timezone"
source "${root_dir}/src/steps/08/locale"
source "${root_dir}/src/steps/09/mkinitcpio"
source "${root_dir}/src/steps/10/bootloader"
source "${root_dir}/src/steps/11/root_password"

###############################################################################
## Script Configuration
###############################################################################
bootstrap::configure()
{
    if ! grep "archiso" "/etc/hostname" >/dev/null; then
        print.error "This script will only run from an Arch Linux live image"
        exit 1
    fi

    get_boot_mode

    if is_bios; then
        print.error "BIOS mode is currently not supported"
        exit 1
    fi

    check_connection

    # timedatectl set-ntp true
}

print_title()
{
    print.title "Arch Bootstrap"
}

finish()
{
    print_title "Install Completed"

    if confirm "Reboot?"; then
        reboot
    fi

    exit 0
}

declare MOUNTPOINT=/mnt

###############################################################################
## Main
###############################################################################
mains()
{
    print.title "Arch Bootstrap"

    if [[ -f "${root_dir}/bootstrap_config" ]]; then
        source "${root_dir}/bootstrap_config"
    fi

    bootstrap::configure

    local EMPTY=""

    menu.run \
        "print_title"                            \
        "Select Keymap" "KEYMAP" "select_keymap" \
        "Select Editor" "EDITOR" "select_editor" \
        "Partition Disk" "PARTITION_DEVICE" "partition_disk" \
        "Install Base System" "EMPTY" "install_base_system" \
        "Configure Fstab" "EMPTY" "configure_fstab" \
        "Configure Hostname" "HOSTNAME" "configure_hostname" \
        "Configure Timezone" "TIMEZONE" "configure_timezone" \
        "Configure Locale" "LOCALE" "configure_locale" \
        "Configure Mkinitcpio" "EMPTY" "configure_mkinitcpio" \
        "Configure Bootloader" "BOOTLOADER" "configure_bootloader" \
        "Root Password" "EMPTY" "configure_root_password"

    finish
}


