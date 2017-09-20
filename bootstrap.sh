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

cd "$(dirname "$(readlink -f "$0" || realpath "$0")")" || :

source "./lib/util/print"
source "./lib/util/menu"
source "./lib/util/device"
source "./lib/util/control_flow"
source "./lib/util/misc"
source "./lib/util/selection"

source "./lib/boot_mode"
source "./lib/connection"

source "./lib/step01_keymap"
source "./lib/step02_editor"
source "./lib/step03_partition_disk"

SCRIPT_TITLE="Arch Bootstrap"

################################################################################
## Script Configuration
################################################################################

configure()
{
    get_boot_mode

    if is_bios; then
        print_warning "BIOS mode is not currently supported in this script"
        exit 1
    fi

    check_connection
}

sync()
{
    pacman -Sy
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
                             "Root Password"            \
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
        d)
            finish
            ;;
        *)
            invalid_option
            ;;
    esac
}

################################################################################
## Main
################################################################################
main()
{
    print_title "${SCRIPT_TITLE}"

    configure
    sync

    while :; do
        print_title "${SCRIPT_TITLE}"

        print_menu
        print_options
    done
}

main "$@"
