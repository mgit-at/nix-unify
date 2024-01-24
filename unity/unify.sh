#!/bin/bash

set -euxo pipefail

toplevel=@@toplevel@@
etc=@@etc@@
path=@@path@@

cmd="$1"

state="/var/nix-unity"

mkdir -p "$state"

if [ "$cmd" = "boot" ]; then
  ln -sf "$toplevel" /run/booted-system
fi

ln -sf "$toplevel" /run/current-system

# lib

handler() {
  PLUGIN="$1"
  MARKER="$state/_installed_$PLUGIN"
  ACTION="$2"

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

# MergePath: Append /run/current-system/sw/bin to PATH

install_mergePath() {

}

uninstall_mergePath() {

}

execute_etcMerge() {
  ln -sf "$etc" /etc/static
}

# Execute (todo: autogenerate)

handler mergePath install 1
handler etcMerge install 1

# TODO
# symlink everything, add to db, purge old
# systemctl daemon-reload
# restart services based on triggers
