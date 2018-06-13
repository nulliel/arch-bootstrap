#!/usr/bin/env bash

##
##
##
Bootstrap::setBootstrapRoot()
{

}

############
## Bootstrap
############

declare -g __bb__root="$(dirname "$(readlink -f "$0" || realpath "$0")")" || {
    printf "System must provide dirname, readlink (or realpath) utils\n"
    exit 1
}
