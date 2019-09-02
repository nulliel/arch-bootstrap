# arch-bootstrap

[![Build Status](https://img.shields.io/travis/nulliel/arch-bootstrap/master.svg?style=flat-square)]()

## Prerequisites
* A working internet connection
* Logged in as `root`

## Usage

1. `mount -o remount,size=2G /run/archiso/cowspace`
2. `wget https://github.com/nulliel/arch-bootstrap/tarball/master -O - | tar xz`
3. `./bootstrap`

### Automatic Setup

Every time this script runs, an `arch_bootstrap.config` file is placed

## 
`docker-compose run test`
`pacman -Syu awk grep sed`

## Contributors
- [helmuthdu](https://github.com/helmuthdu) ([aui](https://github.com/helmuthdu/aui))

## License
[GNU GPLv3](https://www.gnu.org/licenses/gpl-3.0.en.html)
