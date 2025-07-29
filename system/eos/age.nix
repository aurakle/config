{ lib, config, pkgs, ... }:

{
  age = {
    secrets = {
      "local.key" = {
        file = ./secrets/local.key.age;
        owner = "root";
        group = "root";
      };
    };
  };
}
