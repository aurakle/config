{ config, ... }:

{
  networking.hostName = "eos-intel-nvidia";
  
  # Load wifi adapter driver
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8812au
  ];
}
