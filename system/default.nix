inputs@{ nixpkgs
, nixpkgs-unstable
, nur
, aurakle
, agenix
, ... }:

system: {
  eos = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ./eos
      agenix.nixosModules.default
    ];
  };
}
