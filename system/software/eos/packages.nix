{ inputs, config, lib, pkgs, ... }:

{
  nixpkgs = {
    config.allowUnfree = true;

    overlays = [
      inputs.nur.overlays.default
      inputs.nixpkgs-xr.overlays.default
      (final: prev: {
        wine = prev.wineWowPackages.stable;

        unstable = import inputs.nixpkgs-unstable {
          system = prev.system;

          config.allowUnfree = true;
        };

        aurakle = inputs.aurakle.legacyPackages.${prev.system};
      })
    ];
  };

  programs = {
    niri.enable = true;

    steam = {
      enable = true;

      package = with pkgs; steam.override {
        extraPkgs = pkgs: [
          jq
          cabextract
          wget
          git
        ];
      };

      extraCompatPackages = with pkgs; [ proton-ge-bin ];
    };

    corectrl = {
      enable = true;
    };

    dconf = {
      enable = true;
    };

    xfconf = {
      enable = true;
    };

    gnupg.agent = {
      enable = true;
      enableSSHSupport = false;
      pinentryPackage = pkgs.pinentry-tty;
    };
  };

  environment.systemPackages = with pkgs; [
    aurakle.easy-nixos
    #rippkgs
    #rippkgs-index
    nix-output-monitor
    libnotify
    glib
    exfatprogs
    lshw
    wine
    winetricks
    proton-caller
    protontricks
    # certbot-full
    pciutils
    cachix
    git
    lazygit
    git-extras
    smartmontools
    libgsf
    mycli
    xplr
    bottom
    glances
    nano
    wget
    usbutils
    gnupg
    networkmanager
    networkmanager-openvpn
    gparted
    xwayland-satellite
  ];

  fonts.packages = with pkgs; [
    dejavu_fonts
    font-awesome
    comic-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
    liberation_ttf
    fira-code
    fira-code-symbols
    mplus-outline-fonts.githubRelease
    dina-font
    proggyfonts
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
