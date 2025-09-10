{ config, ... }:

{
  networking.hostName = "eos-intel-nvidia";

  hardware.nvidia.open = false;
  services.xserver.videoDrivers = [ "nvidia" ];
  
  # Load wifi adapter driver
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8812au
  ];
}
