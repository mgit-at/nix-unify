#!/bin/sh

set -eu

if [ -e /nix/store ] || type -Pf nix >/dev/null 2>/dev/null; then
  # nix is most likely installed, use that
  exec "$@"
else
  # nix is most likely not installed, use nix-portable
  exec ./nix-portable "$@"
fi
