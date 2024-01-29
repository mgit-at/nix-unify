#!/bin/sh

set -eu

export PATH="x"
source /etc/environment # load system path
# banish nix
PATH=${PATH//":/run/current-system/sw/bin"/""}
export PATH="$PATH"

if [ "$PATH" = "x" ]; then
  export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
fi

# call exec
exec "@exec@" "$@"
