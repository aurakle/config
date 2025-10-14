{ config, lib, pkgs, ... }:

{
  imports = [ ./themes/sddm.nix ];

  services.libinput.touchpad = {
    disableWhileTyping = true;
    naturalScrolling = true;
  };

  services.displayManager = {
    sddm = {
      enable = true;
      autoNumlock = true;
      wayland.enable = true;
    };

    defaultSession = "none+i3";
  };

  services.xserver = {
    enable = true;
    exportConfiguration = true;

    wacom.enable = true;

    xkb = {
      layout = "us,ca";

      options = "compose:rctrl";
    };

    desktopManager = {
      xterm.enable = false;
    };

    windowManager.i3 = {
      enable = true;

      extraPackages = with pkgs; [
        i3lock
      ];
    };

    excludePackages = with pkgs; [
      xterm
    ];
  };
}
