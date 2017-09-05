#!/usr/bin/env bash
## Copyright (c) 2017 Stephen Ribich
##
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
##
## The above copyright notice and this permission notice shall be included in
## all copies or substantial portions of the Software.
##
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.

# shellcheck disable=1091

cd "$(dirname "$(readlink -f "$0" || realpath "$0")")" || :

source "./lib/print"
source "./lib/menu"
source "./lib/boot_mode"
source "./lib/network"
source "./lib/control_flow"
source "./lib/misc"

source "./lib/step01_keymap"
source "./lib/step02_editor"

SCRIPT_TITLE="Arch Bootstrap"

## Set up the script for proper execution
##
configure()
{
  print_title "${SCRIPT_TITLE}"

  get_boot_mode
  check_connection
}

## Update the package repository
##
sync()
{
  pacman -Sy
}

## Ran when the script finishes
##
finish()
{
  exit 0
}

main()
{
  configure
  sync

  while :; do
    local option

    print_title "${SCRIPT_TITLE}"

    printf " 1) %s\n" "$(mainmenu_item "${checklist[1]}" "Select Keymap" "${KEYMAP}")"
    printf " 2) %s\n" "$(mainmenu_item "${checklist[2]}" "Select Editor" "${EDITOR}")"

    printf "\n"
    printf " d) %s\n" "Done"
    printf "\n"

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
      d)
        finish
        ;;
      *)
        invalid_option
        ;;
    esac
  done
}

main "$@"
