#!/bin/bash

set -euxo pipefail

toplevel=@toplevel@
etc=@etc@
path=@path@

cmd="$1"

state="/var/nix-unify"

mkdir -p "$state"

if [ "$cmd" = "at_boot" ] || [ ! -e /run/booted-system ]; then
  ln -sf "$toplevel" /run/booted-system
fi

ln -sf "$toplevel" /run/current-system

# lib

handler() {
  PLUGIN="$1"
  MARKER="$state/_installed_$PLUGIN"
  ACTION="$2"
  VERSION="$3"

  if [ "$ACTION" = "uninstall" ] && ([ -e "$MARKER" ] || [ "$(cat "$MARKER")" != "$VERSION" ]) && fnc "uninstall_$PLUGIN"; then
    "uninstall_$PLUGIN"
    rm -f "$MARKER"
  fi

  if [ "$ACTION" = "install" ] && ([ ! -e "$MARKER" ] || [ "$(cat "$MARKER")" != "$VERSION" ]) && fnc "install_$PLUGIN"; then
    "install_$PLUGIN"
    echo "$VERSION" > "$MARKER"
  fi

  if [ "$ACTION" = "install" ] && fnc "execute_$PLUGIN"; then
    "execute_$PLUGIN"
  fi
}

fnc() {
  if [ -n "$(LC_ALL=C type -t "$1")" ] && [ "$(LC_ALL=C type -t "$1")" = function ]; then
    return 0
  else
    return 1
  fi
}

# mergePath: Append /run/current-system/sw/bin to PATH

install_mergePath() {
  #if cat /etc/environment | grep PATH; then
  #  sed "s|"
  #fi
  # HACK: append properly
  sed "s|/snap/bin|/snap/bin:/run/current-system/sw/bin|" -i /etc/environment
  sed "s|/snap/bin|/snap/bin:/run/current-system/sw/bin|" -i /etc/sudoers
}

uninstall_mergePath() {
  true
}

# etcMerge: Link some files into host's etc

install_etcMerge() {
  touch "$state/etcMerge"
}

execute_etcMerge() {
  ln -sf "$etc" /etc/static
  # link files, write db into $state/etcMerge
}

uninstall_etcMerge() {
  # remove all files
  rm -f /etc/static
}

# Execute (todo: autogenerate)

handler mergePath install 0
handler etcMerge install 1

# TODO
# symlink everything, add to db, purge old
# systemctl daemon-reload
# restart services based on triggers