#!/usr/bin/env bash

## Copyright (c) 2017 helmuthdu <helmuthdu@gmail.com>
## Copyright (c) 2017 Stephen Ribich <stephen.ribich@gmail.com>
##
## This program is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program.  If not, see <http://www.gnu.org/licenses/>.

################################################################################## Debugging
################################################################################
export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'

set -e

if [[ -n "${DEBUG}" ]]; then
    set -o verbose # set -v
    set -o xtrace  # set -x
fi

################################################################################## Imports
################################################################################
## When scripts are executed, they run under the directory in which they
## were called. This command remedies that by changing the directory to the
## folder in which the executed file resides.
cd "$(dirname "$(readlink -f "$0" || realpath "$0")")" || exit

source "./lib/util/print"
source "./lib/util/menu"
source "./lib/util/device"
source "./lib/util/control_flow"
source "./lib/util/misc"
source "./lib/util/selection"
source "./lib/util/system"

source "./lib/boot_mode"
source "./lib/connection"

source "./lib/step01_keymap"
source "./lib/step02_editor"
source "./lib/step03_partition_disk"
source "./lib/step11_install_bootloader"
source "./lib/step12_root_password"

################################################################################## Script Configuration
################################################################################

configure()
{
    if [[ "${SKIP_ARCHISO_CHECK}" -ne 1 ]] && \
           ! ifndev grep "archiso" "/etc/hostname" 1>/dev/null 2>&1; then
        print_error "This script will only run from an Arch Linux live image"
        exit 1
    fi

    get_boot_mode
    check_connection
}

finish()
{
    print_title "Install Completed"

    if confirm "Reboot?"; then
        reboot
    fi

    exit 0
}

################################################################################
## Menu Selection
################################################################################

print_menu()
{
    printf " 1) %s\n" "$(mainmenu_item                  \
                             "${checklist[1]}"          \
                             "Select Keymap"            \
                             "${KEYMAP}")"
    printf " 2) %s\n" "$(mainmenu_item                  \
                             "${checklist[2]}"          \
                             "Select Editor"            \
                             "${EDITOR}")"
    printf " 3) %s\n" "$(mainmenu_item                  \
                             "${checklist[3]}"          \
                             "Partition Disk"           \
                             "")"
    printf " 4) %s\n" "$(mainmenu_item                  \
                             "${checklist[4]}"          \
                             "Install Base System"      \
                             "")"
    printf " 5) %s\n" "$(mainmenu_item                  \
                             "${checklist[5]}"          \
                             "Configure Fstab"          \
                             "")"
    printf " 6) %s\n" "$(mainmenu_item                  \
                             "${checklist[6]}"          \
                             "Configure Hostname"       \
                             "")"
    printf " 7) %s\n" "$(mainmenu_item                  \
                             "${checklist[7]}"          \
                             "Configure Timezone"       \
                             "")"
    printf " 8) %s\n" "$(mainmenu_item                  \
                             "${checklist[8]}"          \
                             "Configure Hardware Clock" \
                             "")"
    printf " 9) %s\n" "$(mainmenu_item                  \
                             "${checklist[9]}"          \
                             "Configure Locale"         \
                             "")"
    printf "10) %s\n" "$(mainmenu_item                  \
                             "${checklist[10]}"         \
                             "Configure Mkinitcpio"     \
                             "")"
    printf "11) %s\n" "$(mainmenu_item                  \
                             "${checklist[11]}"         \
                             "Install Bootloader"       \
                             "")"
    printf "12) %s\n" "$(mainmenu_item                  \
                             "${checklist[12]}"         \
                             "Configure Root Password"  \
                             "")"

    printf "\n"
    printf " d) %s\n" "Done"
    printf "\n"
}

print_options()
{
    local option

    read -r -p "${SELECTION_PROMPT}" option

    case "${option}" in
        1)
            select_keymap
            checklist[1]=1
            ;;
        2)
            select_editor
            checklist[2]=1
            ;;
        3)
            partition_disk
            checklist[3]=1
            ;;
        4)
            install_base_system
            configure_keymap
            configure_dns
            checklist[4]=1
            ;;
        5)
            configure_fstab
            checklist[5]=1
            ;;
        11)
            install_bootloader
            checklist[11]=1
            ;;
        12)
            configure_root_password
            checklist[12]=1
            ;;
        d)
            finish
            ;;
        *)
            invalid_option
            ;;
    esac
}

################################################################################## Main
################################################################################

main()
{
    print_title "Arch Bootstrap"

    configure

    while :; do
        print_title "Arch Bootstrap"

        print_menu
        print_options
    done
}

main "$@"

exit
