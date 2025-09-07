{ lib, config, pkgs, ... }:

{
  security.rtkit.enable = true;

  security.pam.services.i3lock.enable = true; # needed so i3lock-color doesn't lock us out

  security.polkit = {
    enable = true;

    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (
          subject.isInGroup("users")
            && (
              action.id == "org.freedesktop.login1.reboot" ||
              action.id == "org.freedesktop.login1.power-off" ||
              action.id == "org.opensuse.policykit.create-ap"
            )
          )
        {
          return polkit.Result.YES;
        }
      })
    '';
  };

  security.pki.certificateFiles = [
    ./ca/local.pem
  ];

  networking.firewall = {
    enable = true;
    allowPing = false;

    allowedTCPPortRanges = [
      { from = 80; to = 80; }
      { from = 443; to = 443; }
      { from = 63063; to = 63073; }
    ];

    allowedUDPPortRanges = [
      { from = 63063; to = 63073; }
    ];
  };
}
