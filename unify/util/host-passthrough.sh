#!/bin/sh

set -eu

source /etc/environment # load system path
# banish nix
PATH=${PATH//":/run/current-system/sw/bin"/""}
export PATH="$PATH"

# call exec
exec "@exec@" "$@"
