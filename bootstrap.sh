#!/usr/bin/env bash

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

source "${root_dir}/src/util/print"
source "${root_dir}/src/util/menu"
source "${root_dir}/src/util/device"
source "${root_dir}/src/util/control_flow"
source "${root_dir}/src/util/misc"
source "${root_dir}/src/util/system"

source "${root_dir}/src/boot_mode"
source "${root_dir}/src/connection"

source "${root_dir}/src/steps/01_keymap"
source "${root_dir}/src/steps/02_editor"
source "${root_dir}/src/step03_partition_disk"
source "${root_dir}/src/step11_install_bootloader"
source "${root_dir}/src/step12_root_password"

###############################################################################
## Script Configuration
###############################################################################
bootstrap::configure()
{
    ifndev grep "archiso" "/etc/hostname" >/dev/null || {
        print.error "This script will only run from an Arch Linux live image"
        exit 1
    }

    # get_boot_mode
    # check_connection
}

finish()
{
    print_title "Install Completed"

    if confirm "Reboot?"; then
        reboot
    fi

    exit 0
}

###############################################################################
## Main
###############################################################################
main()
{
    print.title "Arch Bootstrap"

    bootstrap::configure

    menu.run \
        "Select Keymap" "KEYMAP" "" \
        "Select Editor" "EDITOR" ""

exit 0

    while :; do
        print.title "Arch Bootstrap"

        show_menu
        print_options
    done
}

main "$@"



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

    read -r -p "Enter your selection: " option

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
