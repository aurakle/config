# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, options, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  hardware.steam-hardware.enable = true; # VR

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  hardware.i2c.enable = true;

  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableKvm = true;
  virtualisation.virtualbox.host.addNetworkInterface = false;
  virtualisation.docker = {
    enable = true;

    rootless = {
      enable = true;
      setSocketVariable = true;
    };
  };

  networking = {
    hostName = "eos"; # Define your hostname.
    extraHosts = "";
    networkmanager.enable = true;
    usePredictableInterfaceNames = false;
    timeServers = options.networking.timeServers.default ++ [ ];
  };

  # Set your time zone.
  time.timeZone = "America/Toronto";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";
  
  console = {
    font = "Lat2-Terminus16";
    keyMap = lib.mkForce "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    #TODO: due to an eval warning, remove and look-up the difference
    config.common.default = "*";

    # gtk portal needed to make gtk apps happy
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
    ];
  };

  qt = {
    enable = true;
    platformTheme = "gtk2";
    style = "gtk2";
  };

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}

