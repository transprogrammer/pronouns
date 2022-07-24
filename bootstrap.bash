#!/usr/bin/env bash

# REQ: Installs python. <skr>

set +o braceexpand
set -o errexit
set -o noclobber
set -o noglob
set -o nounset
set -o pipefail

set -o xtrace

readonly archive_type='deb'
readonly repository_url='http://deb.debian.org/debian'
readonly distribution='testing'
readonly component='main'
readonly list_entry="$archive_type $repository_url $distribution $component"

readonly sources_list='/etc/apt/sources.list'

readonly packages=(
  'pkg-config'
  'build-essential'
  'gdb'
  'lcov'
  'pkg-config'
  'libbz2-dev'
  'libffi-dev'
  'libgdbm-dev'
  'libgdbm-compat-dev'
  'liblzma-dev'
  'libncurses5-dev'
  'libreadline6-dev'
  'libsqlite3-dev'
  'libssl-dev'
  'lzma'
  'lzma-dev'
  'tk-dev'
  'uuid-dev'
  'zlib1g-dev'
)

function main {
  if ! grep -qxF "$list_entry" "$sources_list"; then
    echo "$list_entry" >> "$sources_list"
  fi

  apt-get update
  apt-get build-dep python3
  apt-get install "${packages[@]}" 
}

main

