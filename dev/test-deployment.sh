#!/bin/bash

IP=$(lxc info unify-ubuntu | grep "inet" | grep 10. | grep "[0-9.]*" -o | head -n 1)
nixos-rebuild --flake ".#test" --target-host "root@$IP" switch
