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

source "${root_dir}/src/config"

source "${root_dir}/src/boot_mode"
source "${root_dir}/src/connection"

source "${root_dir}/src/steps/01/keymap"
source "${root_dir}/src/steps/02/editor"
source "${root_dir}/src/steps/03/partition_disk"
source "${root_dir}/src/steps/04/base_system"
source "${root_dir}/src/steps/05/fstab"
source "${root_dir}/src/steps/06/hostname"
source "${root_dir}/src/steps/07/timezone"
source "${root_dir}/src/steps/08/locale"

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

###############################################################################
## Main
###############################################################################
main()
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
        "Configure Locale" "LOCALE" "configure_locale"
        # "Partition Disk" "PARTITION_DEVICE" "partition_disk" \
        # "Bootloader" "ROOT_PASSWORD_STATUS" "select_bootloader" \
        # "Fstab" "ROOT_PASSWORD_STATUS" "configure_fstab" \
        # "Root Password" "ROOT_PASSWORD_STATUS" "root_password"

    finish
}

main "$@"


