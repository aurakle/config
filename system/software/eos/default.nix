{ inputs, ... }:

{
  imports = [
    inputs.agenix.nixosModules.default
    ./configuration.nix
    ./cachix.nix
    ./packages.nix
    ./services.nix
    ./desktop.nix
    ./security.nix
    ./boot.nix
    ./users.nix
    ./age.nix
  ];
}
