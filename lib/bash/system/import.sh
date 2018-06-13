#!/usr/bin/env bash

## A sourcing wrapper.
##
## $@ - Space separated string of imports.
##
System::Import()
{
    local libPath

    for libPath in "$@"; do
        System::ImportOne "$libPath"
    done
}

System::ImportOne()
{
    local libPath="$1"


}
