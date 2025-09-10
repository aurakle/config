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
      ./hardware/eos
      ./software/eos
    ];
  };

  eos-intel-nvidia = nixpkgs.lib.nixosSystem {
    inherit system;
    specialArgs = { inherit inputs; };
    modules = [
      ./hardware/eos-intel-nvidia
      ./software/eos
    ];
  };
}
