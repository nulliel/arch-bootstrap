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

# shellcheck disable=2068

## Start the script by changing the directory of the current shell to the proper
## directory. This lets path resolution work properly
##
cd "$(dirname "$(readlink -f "$0" || realpath "$0")")" || exit

declare -a bats_args=()

build_path()
{
    if compgen -G "./test/*.bats" 1>/dev/null 2>&1; then
        bats_args+=( "./test/*.bats" )
    fi

    if compgen -G "./test/util/*.bats" 1>/dev/null 2>&1; then
        bats_args+=( "./test/util/*.bats" )
    fi
}

main()
{
    build_path
    ./test/test_helper/bats/bin/bats ${bats_args[@]}
}

main
