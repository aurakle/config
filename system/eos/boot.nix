{ config, pkgs, ... }:

{
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    plymouth = {
      enable = true;
      theme = "catppuccin-mocha";

      themePackages = with pkgs; [
        (catppuccin-plymouth.override { variant = "mocha"; })
        plymouth-matrix-theme
      ];
    };

    # Enable "Silent boot"
    initrd.verbose = false;
    consoleLogLevel = 3;

    # Hide the OS choice for bootloaders.
    # It's still possible to open the bootloader list by pressing any key
    # It will just not appear on screen unless a key is pressed
    loader.timeout = 0;

    # Load wifi adapter driver
    extraModulePackages = with config.boot.kernelPackages; [
      #rtl8812au
    ];

    kernelModules = [ "i2c-dev" "i2c-piix4" ];
    kernelParams = [
      "preempt=full"
      "quiet"
      "splash"
      "boot.shell_on_fail"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
    ];
  };
}
