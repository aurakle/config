{ inputs, config, lib, pkgs, ... }:

let
  editor = "${pkgs.neovim.out}/bin/nvim";
  browser = "${pkgs.firefox.out}/bin/firefox";
  terminal = "${pkgs.kitty.out}/bin/kitty";
  lock = "${pkgs.aurakle.i3lock-blurred.out}/bin/i3lock-blurred";
  screenshotter = "${pkgs.flameshot.out}/bin/flameshot";
  screenshot-gui = "${screenshotter} gui";
  screenshot-full = "${screenshotter} full";
  sswitcher = pkgs.writeShellScriptBin "sswitcher" ''
    exec nix-shell -p indicator-sound-switcher --run indicator-sound-switcher
  '';
  pbar-start = pkgs.writeShellScriptBin "launch" ''
    ${pkgs.polybarFull.out}/bin/polybar-msg cmd quit
    exec ${pkgs.polybarFull.out}/bin/polybar
  '';
  name = "aur";
  dir = "/home/${name}";
in rec {
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = name;
  home.homeDirectory = dir;

  catppuccin = {
    flavor = "mocha";
    accent = "mauve";

    polybar.enable = true;
    kitty.enable = true;
    dunst.enable = true;
    rofi.enable = true;
  };

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    sswitcher
  ] ++ (with pkgs.aurakle; [
    i3lock-blurred
    EternalModManager
    bar
  ]) ++ (with pkgs; [
    (writeShellScriptBin "recon-gdrive" ''
      ${rclone.out}/bin/rclone config reconnect AuraGDrive:
      nohup ${rclone.out}/bin/rclone mount AuraGDrive: ~/CloudData/AuraGDrive &
    '')
    # (writeShellScriptBin "cs-fmt" ''
    #   nix-shell -p dotnet-sdk csharpier --run "dotnet-csharpier $@"
    # '')
    (writeShellScriptBin "hotspot" ''
      pkexec --user root ${linux-wifi-hotspot.out}/bin/create_ap wlan0 wlan0 "solanix" "$1" --mkconfig /etc/create_ap.conf -g 1.1.1.1
    '')
    (writeShellScriptBin "hotspot-gui" ''
      exec ${linux-wifi-hotspot.out}/bin/wihotspot-gui "$@"
    '')
    (writeShellScriptBin "remindme" ''
      time="$1"
      text="$2"

      echo "notify-send --category reminder 'Reminder' '$text'" | at now + "$time"
    '')
    (writeShellScriptBin "litterbox" ''
      link=$(curl -F "reqtype=fileupload" -F "time=72h" -F "fileToUpload=@$1" https://litterbox.catbox.moe/resources/internals/api.php)
      echo "Copying $link to clipboard using xclip"
      echo $link | xclip -selection CLIPBOARD
    '')
    (writeShellScriptBin "wine-set-alsa" ''
      env WINEPREFIX="$1" winetricks -q sound=alsa
    '')
    (writeShellScriptBin "proton-set-alsa" ''
      for app_id in $(protontricks -l | grep -E "\([0-9]+\)" | sed -r 's/[^(]+\(([[:digit:]]+)\)/\1/'); do
        if [[ -z "$app_id" ]]; then
          echo "Done"
        else
          echo "Setting $app_id to use ALSA"
          protontricks $app_id -q sound=alsa
        fi
      done
    '')
    (writeShellScriptBin "rec-sed" ''
      find ./ -type f -exec sed -i -e "$1" {} \;
    '')
    (writeShellScriptBin "md2pdf" ''
      pandoc --pdf-engine=xelatex --from=markdown+hard_line_breaks --to pdf "$1.md" -o "$1.pdf"
    ''
    )
    (writeShellScriptBin "mcdev-open-all" ''
      nvim $(find src/main/java -type f) $(find src/client/java -type f)
    '')
    (unstable.vesktop.overrideAttrs (old: {
      postFixup = old.postFixup + ''
        wrapProgram $out/bin/vesktop --add-flags \"--disable-features=WebRtcAllowInputVolumeAdjustment\"
      '';
    }))
    unstable.neovide
    unstable.olympus
    iamb
    signal-desktop
    magic-wormhole
    octave
    komorebi
    xwinwrap
    libqalculate
    firefox
    soulseekqt
    speedtest-cli
    handbrake
    vlc
    tenacity
    puddletag
    inkscape
    gitnr
    aseprite
    krita
    lmms
    ffmpeg
    pandoc
    miktex
    fastfetch
    calibre
    zathura
    r2modman
    cemu
    kdePackages.kdenlive
    simplescreenrecorder
    freetube
    cava
    heroic
    cookiecutter
    firefox
    libreoffice
    lazygit
    hunspell
    tree
    blockbench
    thunderbird
    birdtray # for thunderbird to support system tray
    git
    gitAndTools.gh
    hunspellDicts.en_GB-ise
    hunspellDicts.fr-any
    hunspellDicts.tok
    airshipper
    fzf
    itch
    yt-dlp
    multiplex
    mpv
    osu-lazer-bin
    the-powder-toy
    celeste64
    bottom
    btop
    sirikali
    dig
    flameshot
    qbittorrent
    openrgb
    rclone
    bespokesynth
    picom
    dunst
    blueman
    linux-wifi-hotspot
    prismlauncher
    lxqt.lxqt-policykit
    autorandr
    obs-studio
    with-shell
    wl-clipboard
    mpvpaper
    papirus-icon-theme
    networkmanagerapplet
    mindustry-server
    pavucontrol
    nix-output-monitor
    xclip
    glances
    keepassxc
    hyfetch
    bruno
    xdragon
    dua
    fzf
    trash-cli
    pistol
    ghostie
    ouch
    obsidian
    #TODO: insecure
    # ventoy-full
  ]) ++ programs.rofi.plugins;

  xsession = {
    enable = true;
    numlock.enable = true;

    windowManager.i3 = import ./i3 {
      inherit lib config pkgs dir lock terminal browser editor sswitcher pbar-start screenshot-full screenshot-gui;
    };
  };

  age = {
    identityPaths = [ "${dir}/.ssh/key" ];
    secretsDir = "${dir}/.local/share/agenix/agenix";
    secretsMountPoint = "${dir}/.local/share/agenix/agenix.d";

    secrets = {
      clickr-mine.file = ./secrets/clickr-mine.age;
      clickr-evy.file = ./secrets/clickr-evy.age;
    };
  };

  programs.bash = {
    enable = true;

    bashrcExtra = ''
      # If not running interactively, don't do anything
      [[ $- != *i* ]] && return

      # If root, don't do anything
      [[ "$(whoami)" = "root" ]] && return

      # limits recursive functions, see 'man bash'
      [[ -z "$FUNCNEST" ]] && export FUNCNEST=100

      ## Use the up and down arrow keys for finding a command in history
      ## (you can write some initial letters of the command first).
      bind '"\e[A":history-search-backward'
      bind '"\e[B":history-search-forward'

      alias :q='exit'
      alias ..='cd ..'
      alias ls='ls -lav --color=auto --ignore=..'
      alias l='ls -lav --color=auto --ignore=.. | grep '
      alias invidtui="invidtui --close-instances"
      alias miniarch="~/connect aurora nova711.asuscomm.com"
      alias update-clean="home-clean && sys-clean && sys-switch && switch"

      alias nix-shell="nix-shell --log-format bar-with-logs"
      alias nix-build="nix-build --log-format bar-with-logs"
      alias nix-store="nix-store --log-format bar-with-logs"
      alias nixos-rebuild="nixos-rebuild --log-format bar-with-logs"
      alias nix="nix --extra-experimental-features nix-command --extra-experimental-features flakes"

      alias xcd="cd \$(xplr)"
      alias i2pbit="qbittorrent --configuration=I2P"

      alias bitch=sudo

      ${pkgs.meow.out}/bin/meow
    '';
  };

  programs.kitty = {
    enable = true;
  };

  programs.eww = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.starship = import ./starship {
    inherit lib;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
  };

  programs.rofi = {
    enable = true;
    # package = pkgs.rofi-wayland;

    inherit terminal;

    plugins = with pkgs; [
      (rofi-power-menu.overrideAttrs (old: {
        src = pkgs.fetchFromGitHub {
          owner = "aurakle";
          repo = "rofi-power-menu";
          rev = "59628e017a8f5b6261b28930e7f267e512008fd3";
          hash = "sha256-ptaU0kspr0mfYDS4UZ1pFvCTod3SihS1z8Qcqr4a8Tw=";
        };
      }))
      rofi-calc
      rofi-bluetooth
      rofi-file-browser
      keepmenu
    ];
  };

  programs.git = {
    enable = true;
    userName = "Aurora Dawn";
    userEmail = "aurora.dawn@trans.fish";

    signing = {
      signByDefault = true;
      key = "28ABC7A43E95C82B";
    };

    extraConfig = {
      commit.gpgsign = true;
      init.defaultBranch = "main";
    };
  };

  programs.xplr = {
    enable = true;

    plugins = with pkgs; {
      zoxide = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "zoxide.xplr";
        rev = "e50fd35db5c05e750a74c8f54761922464c1ad5f";
        hash = "sha256-ZiOupn9Vq/czXI3JHvXUlAvAFdXrwoO3NqjjiCZXRnY=";
      };

      trash-cli = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "trash-cli.xplr";
        rev = "2c5c8c64ec88c038e2075db3b1c123655dc446fa";
        hash = "sha256-Yb6meF5TTVAL7JugPH/znvHhn588pF5g1luFW8YYA7U=";
      };

      dua-cli = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "dua-cli.xplr";
        rev = "66ccf983fab7f67d6b00adc0365a2b26550e7f81";
        hash = "sha256-XDhXaS8GuY3fuiSEL0WcLFilZ72emmjTVi07kv5c8n8=";
      };

      dragon = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "dragon.xplr";
        rev = "5fbddcb33f7d75a5abd12d27223ac55589863335";
        hash = "sha256-FJbyu5kK78XiTJl0NNXcI0KPOdXOPwpbBCWPUEpu5zA=";
      };

      fzf = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "fzf.xplr";
        rev = "c8991f92946a7c8177d7f82ed939d845746ebaf5";
        hash = "sha256-dpnta67p3fYEO3/GdvFlqzdyiMaJ9WbsnNmoIRHweMI=";
      };

      xclip = fetchFromGitHub {
        owner = "sayanarijit";
        repo = "xclip.xplr";
        rev = "ddbcce2a255537ce8e3680575bbe964b49d05979";
        hash = "sha256-9WYT52H6vfqTGos57/Um/UqVCkteTAbnUSQ5xDb+JrY=";
      };

      ouch = fetchFromGitHub {
        owner = "dtomvan";
        repo = "ouch.xplr";
        rev = "375edf19ff3e0286bd7a101b9e4dd24fa5abaeb8";
        hash = "sha256-YGFQKzIYIlL+UW2Nel2Tw7WC3MESaVbWYlpj5o2FfLs=";
      };

      nuke = fetchFromGitHub {
        owner = "Junker";
        repo = "nuke.xplr";
        rev = "f83a7ed58a7212771b15fbf1fdfb0a07b23c81e9";
        hash = "sha256-k/yre9SYNPYBM2W1DPpL6Ypt3w3EMO9dznHwa+fw/n0=";
      };
    };

    extraConfig = ''
      require("zoxide").setup({
        bin = "zoxide",
        mode = "default",
        key = "Z",
      })

      require("trash-cli").setup({

        -- Empty trash
        empty_bin = "trash-empty",
        empty_mode = "delete",
        empty_key = "E",

        -- Interactive selector
        trash_list_bin = "trash-list",
        trash_list_selector = "fzf -m | cut -d' ' -f3-",

        -- Restore file(s)
        restore_bin = "trash-restore",

        -- Restore files deleted from $PWD only
        restore_mode = "delete",
        restore_key = "r",

        -- Restore files deleted globally
        global_restore_mode = "delete",
        global_restore_key = "R",
      })

      require("dua-cli").setup({
        mode = "action",
        key = "u",
      })

      require("dragon").setup({
        mode = "selection_ops",
        key = "D",
        drag_args = "",
        drop_args = "",
        keep_selection = false,
        bin = "dragon",
      })

      require("fzf").setup({
        mode = "default",
        key = "ctrl-f",
        bin = "fzf",
        args = "--preview 'pistol {}'",
        recursive = true, -- If true, search all files under $PWD
        enter_dir = true, -- Enter if the result is directory
      })

      require("xclip").setup{
        copy_command = "xclip-copyfile",
        copy_paths_command = "xclip -sel clip",
        paste_command = "xclip-pastefile",
        keep_selection = false,
      }

      require("ouch").setup{
        mode = "action",
        key = "o",
      }

      require("nuke").setup()
    '';
  };

  programs.spicetify = let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.stdenv.system};
  in {
    enable = true;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";

    enabledExtensions = with spicePkgs.extensions; [
      adblock
    ];
  };

  programs.nixvim = import ./neovim {
    inherit config lib pkgs;
  };

  services.ssh-agent = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    enableSshSupport = false;
    defaultCacheTtl = 1800;
  };

  services.polybar = import ./polybar {
    inherit pkgs;
  };

  services.dunst = {
    enable = true;
    configFile = "${dir}/.config/dunst/dunstrc";

    settings = {
      global = {
        ignore_dbusclose = true;
      };

      remindme = {
        category = "reminder";
        background = "#333333";
        foreground = "#ff7f7f";
        timeout = 0;
      };
    };
  };

  systemd.user.services = {
    clean = {
      Unit = {
        Description = "clean old home-manager generations";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        ExecStart = "${lib.getExe pkgs.aurakle.trim-generations} 3 0 home-manager";
        StandardInputText = "y\n";
      };
    };

    clickrtraining = {
      Unit = {
        Description = "clickrtraining client";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };

      Service = {
        ExecStart = "${(pkgs.writeShellScriptBin "clickrtraining-service" ''
          ${pkgs.aurakle.clickrtraining.out}/bin/clickrtraining listen --addr clickertrain.ing --id $(cat ${config.age.secrets.clickr-mine.path})
        '').out}/bin/clickrtraining-service";
      };
    };
  };

  gtk = {
    enable = true;

    theme = {
      name = "Catppuccin-GTK-Purple-Dark";
      package = pkgs.magnetic-catppuccin-gtk.override {
        accent = [ "purple" ];
      };
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    gtk2.extraConfig = ''
      gtk-application-prefer-dark-theme=true
    '';

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  qt = {
    enable = true;
    style.name = "gtk2";
  };

  dconf = {
    enable = true;

    settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };

  xdg = import ./xdg {
    inherit lib pkgs;
  };

  home.pointerCursor = let
    name = "Future-cyan-cursors";
  in {
    gtk.enable = true;
    x11.enable = true;
    size = 24;

    inherit name;

    package = let
      source = ./cursors/${name};
    in pkgs.runCommand "moveUp" {} ''
      mkdir -p $out/share/icons
      ln -s ${source} $out/share/icons/${name}
    '';
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = let
    mkConf = path: source: {
      ".config/${path}" = {
        inherit source;
      };
    };
    toml = config: {
      generator = pkgs.formats.toml { };
      inherit config;
    };
    ini = config: {
      generator = pkgs.formats.ini { };
      inherit config;
    };
  in {
    ".face".source = ./face.png;
    ".thunderbird_link_because_birdtray_stupid".source = "${pkgs.thunderbird.out}/bin/thunderbird";
    ".config/openxr/1/active_runtime.json".source = "${pkgs.monado.out}/share/openxr/1/openxr_monado.json";
    # The number of threads to use for processing Vulkan shaders when starting a Steam game through Proton.
    # It is very important that this match the amount of threads on the host.
    ".steam/steam/steam_dev.cfg".text = ''
      unShaderBackgroundProcessingThreads 16
    '';
    ".config/openvr/openvrpaths.vrpath".text = ''
      {
        "config" :
        [
          "~/.local/share/Steam/config"
        ],
        "external_drivers" : null,
        "jsonid" : "vrpathreg",
        "log" :
        [
          "~/.local/share/Steam/logs"
        ],
        "runtime" :
        [
          "${pkgs.opencomposite}/lib/opencomposite"
        ],
        "version" : 1
      }
    '';
  } // ((a: lib.attrsets.concatMapAttrs (k: { generator, config, ... }: mkConf k (generator.generate (builtins.baseNameOf k) config)) a) {
    "neovide/config.toml" = toml {
      font = {
        normal = [
          "FiraCode Nerd Font Mono"
        ];

        features = {
          "FiraCode Nerd Font Mono" = [ "-calt" ];
        };

        size = 11;
      };
    };

    "proton.conf" = toml rec {
      data = "${dir}/.proton";
      steam = "${dir}/.steam/root";
      common = "${steam}/steamapps/common";
    };

    "keepmenu/config.ini" = ini {
      dmenu = {
        dmenu_command = "rofi -i";
      };

      dmenu_passphrase = {
        obscure = true;
      };

      database = let
        entries = [
          {
            database = "~/KPXC/data.kdbx";
            keyfile = "";
          }
        ];
      in lib.lists.foldr (a: b: a // b) { } (lib.lists.imap1 (i: { database, keyfile, ... }: { "database_${builtins.toString i}" = database; "keyfile_${builtins.toString i}" = keyfile; }) entries) // {
        pw_cache_period_min = 20;
        autotype_default = "{USERNAME}{TAB}{PASSWORD}{ENTER}";
      };
    };
  });

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/aurora/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    GAMES = "$HOME/Games";
    APPS = "$HOME/Apps";

    PATH = "$PATH:$HOME/.bin:$HOME/.local/bin:$GAMES:$APPS:$HOME/.cargo/bin:$HOME/.nix-profile/bin:/var/lib/snapd/snap/bin:$HOME/.dotnet/tools";

    EDITOR = "${editor}";
    BROWSER = "${browser}";

    HISTCONTROL = "ignoredups:ignorespace";
    HISTTIMEFORMAT = "[%Y/%m/%d @ %H:%M:%S] ";

    QT_QPA_PLATFORMTHEME = "qt5ct";

    _ZO_RESOLVE_SYMLINKS = 1;
    _ZO_ECHO = 1;
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11"; # Please read the comment before changing.
}
