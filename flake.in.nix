{
  inputs = let
    version = "25.05";
    dep = url: {
      inherit url;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  in {
    flake-utils.url = "github:numtide/flake-utils";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-${version}";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-xr.url = "github:nix-community/nixpkgs-xr";

    nur = dep "github:nix-community/nur";
    aurakle = dep "github:aurakle/nurpkgs";
    agenix = dep "github:ryantm/agenix";
    home-manager = dep "github:nix-community/home-manager/release-${version}";
    nixvim = dep "github:nix-community/nixvim/nixos-${version}";
    spicetify-nix = dep "github:Gerg-L/spicetify-nix";
    catppuccin = dep "github:catppuccin/nix";
  };

  outputs = inputs@{ flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages = {
        nixosConfigurations = import ./system inputs system;

        homeConfigurations = import ./home inputs system;
      };
    });
}
