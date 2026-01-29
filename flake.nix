# Do not modify! This file is generated.
# One exception: If you use a different template than "flake.in.nix" set
#                its relative path through the first argument to inputs.flakegen.

{
  inputs = {
    agenix = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:ryantm/agenix";
    };
    aurakle = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:aurakle/nurpkgs";
    };
    catppuccin = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:catppuccin/nix";
    };
    flake-utils.url = "github:numtide/flake-utils";
    flakegen.url = "github:jorsn/flakegen";
    home-manager = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/home-manager/release-25.11";
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";
    nixvim.url = "github:nix-community/nixvim/nixos-25.11";
    nur = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/nur";
    };
  };
  outputs = inputs: inputs.flakegen ./flake.in.nix inputs;
}