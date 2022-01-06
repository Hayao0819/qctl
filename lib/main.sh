#!/usr/bin/env bash

# POSIX compliant version
readlinkf_posix() {
  [ "${1:-}" ] || return 1
  max_symlinks=40
  CDPATH='' # to avoid changing to an unexpected directory

  target=$1
  [ -e "${target%/}" ] || target=${1%"${1##*[!/]}"} # trim trailing slashes
  [ -d "${target:-/}" ] && target="$target/"

  cd -P . 2>/dev/null || return 1
  while [ "$max_symlinks" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do
    if [ ! "$target" = "${target%/*}" ]; then
      case $target in
        /*) cd -P "${target%/*}/" 2>/dev/null || break ;;
        *) cd -P "./${target%/*}" 2>/dev/null || break ;;
      esac
      target=${target##*/}
    fi

    if [ ! -L "$target" ]; then
      target="${PWD%/}${target:+/}${target}"
      printf '%s\n' "${target:-/}"
      return 0
    fi

    # `ls -dl` format: "%s %u %s %s %u %s %s -> %s\n",
    #   <file mode>, <number of links>, <owner name>, <group name>,
    #   <size>, <date and time>, <pathname of link>, <contents of link>
    # https://pubs.opengroup.org/onlinepubs/9699919799/utilities/ls.html
    link=$(ls -dl -- "$target" 2>/dev/null) || break
    target=${link#*" $target -> "}
  done
  return 1
}

# readlink version
readlinkf_readlink() {
  [ "${1:-}" ] || return 1
  max_symlinks=40
  CDPATH='' # to avoid changing to an unexpected directory

  target=$1
  [ -e "${target%/}" ] || target=${1%"${1##*[!/]}"} # trim trailing slashes
  [ -d "${target:-/}" ] && target="$target/"

  cd -P . 2>/dev/null || return 1
  while [ "$max_symlinks" -ge 0 ] && max_symlinks=$((max_symlinks - 1)); do
    if [ ! "$target" = "${target%/*}" ]; then
      case $target in
        /*) cd -P "${target%/*}/" 2>/dev/null || break ;;
        *) cd -P "./${target%/*}" 2>/dev/null || break ;;
      esac
      target=${target##*/}
    fi

    if [ ! -L "$target" ]; then
      target="${PWD%/}${target:+/}${target}"
      printf '%s\n' "${target:-/}"
      return 0
    fi

    target=$(readlink -- "$target" 2>/dev/null) || break
  done
  return 1
}

readlinkf(){
  readlinkf_posix "${@}"
}

# LoadShellFIles <file1> <file2> ...
LoadShellFIles(){
    local _file
    for _file in "${@}"; do
        if [[ -e "${_file}" ]]; then 
          typeset -f MsgDebug &> /dev/null && MsgDebug "Loaded script: ${_file}"
          source "${_file}"
        else
          typeset -f MsgDebug &> /dev/null && MsgDebug "${_file} was not found"
        fi
    done
}

#QctlLibDir="$(readlinkf "${0}")"

WorkInProgress(){
  MsgError "I'm sorry this feature is work in progress."
  return 1
}

: "${ShowDebugMsg=false}"

Librarys=(
    "${QctlLibDir}/msg.sh"
    "${QctlLibDir}/shellfunc.sh"
    "${QctlLibDir}/parseopt.sh"
    "${QctlLibDir}/trap.sh"
    "${QctlLibDir}/config.sh"
    "${QctlLibDir}/prepare.sh"
    "$QctlLibDir/add.sh"
    "$QctlLibDir/getoptses/getoptses.sh"
    "${QctlLibDir}/list.sh"
    "$QctlLibDir/power.sh"
    "$QctlLibDir/vm.sh"

)

LoadShellFIles "${Librarys[@]}"
CheckBashVersion
