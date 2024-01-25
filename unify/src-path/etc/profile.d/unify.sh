# shellcheck shell=sh

# Expand $PATH to include the directory where snappy applications go.
nix_bin_path="/run/current-system/sw/bin"
if [ -n "${PATH##*${nix_bin_path}}" ] && [ -n "${PATH##*${nix_bin_path}:*}" ]; then
    export PATH="$PATH:${nix_bin_path}"
fi

# Ensure base distro defaults xdg path are set if nothing filed up some
# defaults yet.
if [ -z "$XDG_DATA_DIRS" ]; then
    export XDG_DATA_DIRS="/usr/local/share:/usr/share"
fi

# Desktop files (used by desktop environments within both X11 and Wayland) are
# looked for in XDG_DATA_DIRS; make sure it includes the relevant directory for
# snappy applications' desktop files.
nix_xdg_path="/run/current-system/sw/share"
if [ -n "${XDG_DATA_DIRS##*${nix_xdg_path}}" ] && [ -n "${XDG_DATA_DIRS##*${nix_xdg_path}:*}" ]; then
    export XDG_DATA_DIRS="${XDG_DATA_DIRS}:${nix_xdg_path}"
fi
