inputs@{ nixpkgs
, nixpkgs-unstable
, nur
, fjord
, aurakle
, home-manager
, nixvim
, catppuccin
, ... }:

system: let
  pkgs = import nixpkgs {
    inherit system;

    config.allowUnfree = true;

    overlays = [
      nur.overlays.default
      fjord.overlays.default
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
      nixvim.homeManagerModules.default
      catppuccin.homeModules.catppuccin
    ];
  };
}
