{ config, lib, pkgs, ... }:

{
  users = {
    mutableUsers = true;

    users.aur = {
      isNormalUser = true;
      uid = 1000;
      home = "/home/aur";
      description = "Aurora Dawn";
      extraGroups = [ "wheel" "vboxusers" "docker" ];
    };
  };
}
