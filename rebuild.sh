#!/usr/bin/env bash

cd $(dirname $0)

# assume that if there are no args, you want to switch to the configuration
cmd=${1:-switch}
shift

machine=${1:-nicetop}
shift

# without --no-reexec, nixos-rebuild will compile nix and use the compiled nix to
# evaluate the config, wasting several seconds
run0 --background="" nixos-rebuild "$cmd" -f ./hosts.nix -A "$machine" --no-reexec "$@" --log-format internal-json -v |& nom --json
