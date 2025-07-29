#!/usr/bin/env bash

# this is necessary because flake.nix must not contain logic. wtf?
nix run .#genflake flake.nix
