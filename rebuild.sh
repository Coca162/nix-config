#!/usr/bin/env bash

cd $(dirname $0)

# assume that if there are no args, you want to switch to the configuration
cmd=${1:-switch}
shift

machine=${1:-nicetop}
shift

nixpkgs_pin=$(nix eval --raw -f npins/default.nix nixpkgs)
nix_path="nixpkgs=${nixpkgs_pin}:nixos-config=${PWD}/${machine}/default.nix"

# without --no-reexec, nixos-rebuild will compile nix and use the compiled nix to
# evaluate the config, wasting several seconds
sudo env NIX_PATH="${nix_path}" nixos-rebuild "$cmd" --no-reexec "$@" --log-format internal-json -v |& nom --json