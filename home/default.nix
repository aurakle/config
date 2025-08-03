inputs@{ nixpkgs
, nixpkgs-unstable
, nur
, aurakle
, home-manager
, agenix
, nixvim
, spicetify-nix
, catppuccin
, ... }:

system: let
  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;

    overlays = [
      nur.overlays.default
      (final: prev: {
        wine = prev.wineWowPackages.stable;

        unstable = import nixpkgs-unstable {
          system = prev.system;

          config.allowUnfree = true;
        };

        aurakle = aurakle.legacyPackages.${prev.system};
      })
    ];
  };
in {
  aur = home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = { inherit inputs; };
    modules = [
      ./aur
      agenix.homeManagerModules.default
      nixvim.homeManagerModules.default
      spicetify-nix.homeManagerModules.default
      catppuccin.homeModules.catppuccin
    ];
  };
}
