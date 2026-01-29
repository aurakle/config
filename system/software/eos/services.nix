{ config, lib, pkgs, ... }:

{
  systemd.user = {
    services.monado.environment = {
      STEAMVR_LH_ENABLE = "1";
      XRT_COMPOSITOR_COMPUTE = "1";
    };

    extraConfig = ''
      DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
    '';
  };

  services = {
    blueman.enable = true;
    dbus.enable = true;
    pcscd.enable = true;
    hardware.openrgb.enable = true;

    openssh = {
      enable = true;
      ports = [ 24024 ];
    };

    mysql = {
      enable = true;
      package = pkgs.mariadb;
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      jack.enable = true;

      alsa = {
        enable = true;
        support32Bit = true;
      };
    };

    keyd = {
      enable = true;

      keyboards = {
        default = {
          ids = [ "*" ];

          settings = {
            main = {
              capslock = "overload(control, esc)";
            };

            # unused for now
            symbols = {
              a = "~";
              s = "!";
              d = "@";
              f = "#";
              g = "$";
              h = "%";
              j = "^";
              k = "&";
              l = "*";
              ";" = "(";
              "'" = ")";
            };
          };
        };
      };
    };

    # xrdp = {
    #   enable = true;
    #   openFirewall = true;
    #   defaultWindowManager = "i3";
    # };

    # monado = {
    #   enable = true;
    #   defaultRuntime = true; # Register as default OpenXR runtime
    # };

    i2pd = {
      enable = true;
      upnp.enable = true;
      port = 7656;

      proto = {
        httpProxy = {
          enable = true;
        };
      };
    };

    atd = {
      enable = true;
    };

    udev = {
      enable = true;
      packages = [ pkgs.openrgb ];
    };

    gvfs = {
      enable = true;
    };

    tumbler = {
      enable = true;
    };
  };
}
