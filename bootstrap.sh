#!/usr/bin/env bash

## Copyright (c) 2017 helmuthdu <helmuthdu@gmail.com>
## Copyright (c) 2019 Stephen Ribich <stephen.ribich@gmail.com>
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

source "$(cd "${BASH_SOURCE[0]%/*}" && pwd)/lib/bootstrap"

if [[ -n "${DEBUG:-}" ]]; then
    activate_module debug
fi

activate_module array

###############################################################################
## Imports
###############################################################################

##
# When scripts are executed, they run under the directory in which they
# were called. This command remedies that by changing the directory to the
# folder in which the executed file resides.
declare -rg root_dir="$(dirname "$(readlink -f "$0" || realpath "$0")")" || exit

source "${root_dir}/src/util/print"
source "${root_dir}/src/util/menu"
source "${root_dir}/src/util/device"
source "${root_dir}/src/util/control_flow"
source "${root_dir}/src/util/misc"
source "${root_dir}/src/util/selection"
source "${root_dir}/src/util/system"

source "${root_dir}/src/boot_mode"
source "${root_dir}/src/connection"

source "${root_dir}/src/steps/step01_keymap"
source "${root_dir}/src/step02_editor"
source "${root_dir}/src/step03_partition_disk"
source "${root_dir}/src/step11_install_bootloader"
source "${root_dir}/src/step12_root_password"

###############################################################################
## Script Configuration
###############################################################################
bootstrap::configure()
{
    ifndev grep "archiso" "/etc/hostname" || {
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

    while :; do
        print.title "Arch Bootstrap"

        show_menu
        print_options
    done
}

main "$@"
