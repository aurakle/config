{ config, ... }:

{
  networking.hostName = "eos-intel-nvidia";

  hardware.nvidia.open = false;
  services.xserver.videoDrivers = [ "nvidia" ];

  networking = {
    interfaces.wlan0 = {
      ipv4.addresses = [{
        address = "1.1.1.80";
        prefixLength = 24;
      }];
      ipv6.addresses = [];
    };
    defaultGateway = {
      address = "1.1.1.1";
      interface = "wlan0";
    };
    nameservers = [
      "8.8.8.8"
    ];
  };

  # Load wifi adapter driver
  boot.extraModulePackages = with config.boot.kernelPackages; [
    rtl8812au
  ];
}
