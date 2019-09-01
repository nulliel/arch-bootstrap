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
        "Select Keymap" "KEYMAP" \
        "Select Editor" "EDITOR"

exit 0

    while :; do
        print.title "Arch Bootstrap"

        show_menu
        print_options
    done
}

main "$@"
