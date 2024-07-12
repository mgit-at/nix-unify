# shellcheck shell=sh

if [ -n "${__ETC_PROFILE_NIX_UNIFY_SOURCED:-}" ]; then return; fi
export __ETC_PROFILE_NIX_UNIFY_SOURCED=1

# Expand $PATH to include the directory where nixos applications go.
nix_bin_path="/run/current-system/sw/bin"
export PATH="$PATH:${nix_bin_path}"

# Ensure base distro defaults xdg path are set if nothing filed up some
# defaults yet.
if [ -z "$XDG_DATA_DIRS" ]; then
    export XDG_DATA_DIRS="/usr/local/share:/usr/share"
fi

# Desktop files (used by desktop environments within both X11 and Wayland) are
# looked for in XDG_DATA_DIRS; make sure it includes the relevant directory for
# nixos applications' desktop files.
nix_xdg_path="/run/current-system/sw/share"
export XDG_DATA_DIRS="${XDG_DATA_DIRS}:${nix_xdg_path}"
