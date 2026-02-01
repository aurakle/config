{ lib
, config
, pkgs
, dir
, lock
, terminal
, browser
, editor
, sswitcher
, pbar-start
, clickr-click
, screenshot-full
, screenshot-gui }:

let
  video-bg = pkgs.writeShellScriptBin "i3-bg" ''
    ${pkgs.aurakle.i3-video-wallpaper.out}/bin/i3-video-wallpaper -bawn ${./bg.mp4}
  '';
in {
  enable = true;

  extraConfig = ''
    include ${./i3-catppuccin}
  '';

  config = let
    mkMenu = args: "${config.programs.rofi.finalPackage}/bin/rofi ${args}";
    drun = mkMenu "-show drun -run-command \"i3-msg exec '{cmd}'\" -show-icons -sidebar-mode -application-fallback-icon ${./rofi-default-icon.png}";
    powermenu = mkMenu "-show power-menu -modi \"power-menu:rofi-power-menu --choices=logout/suspend/shutdown/reboot\"";
    calc = mkMenu "-show calc -modi calc -no-show-match -no-sort -location 7 -calc-command 'printf \"{result}\" | ${pkgs.xclip.out}/bin/xclip -i -selection CLIPBOARD'";
    file-browser = mkMenu "-show file-browser-extended";
    bluetooth = "rofi-bluetooth";
    keepmenu = "keepmenu";
  in rec {
    menu = drun;
    modifier = "Mod4";
    defaultWorkspace = "workspace number 1";

    inherit terminal;

    startup = let
      use-animated-background = false; #TODO: move this out?
      mkCmd = command: always: {
        inherit command always;
        notification = false;
      };
      mkAlways = command: mkCmd command true;
      mkOnce = command: mkCmd command false;
    in [
      (mkAlways "${pbar-start.out}/bin/launch")
      (mkOnce "${sswitcher.out}/bin/sswitcher")
    ] ++ (with pkgs; [
      (if use-animated-background
        then mkAlways "${video-bg.out}/bin/i3-bg"
        else mkAlways "${feh.out}/bin/feh --no-fehbg --bg-scale ${./bg.png}")
      (mkAlways "systemctl --user import-environment PATH")
      (mkOnce "${lxqt.lxqt-policykit.out}/bin/lxqt-policykit-agent")
      (mkOnce "${xorg.xrandr.out}/bin/xrandr --output DisplayPort-0 --off --output DisplayPort-1 --off --output DisplayPort-2 --off --output HDMI-A-0 --mode 1920x1080 --rate 75 --pos 0x0 --rotate normal --output HDMI-A-1-1 --off --output DisplayPort-1-3 --off --output DisplayPort-1-4 --off --output DisplayPort-1-5 --off")
      (mkOnce "${picom.out}/bin/picom -cbf --config ${./picom.conf}")
      (mkOnce "${openrgb.out}/bin/openrgb --startminimized --profile \"Trans-Purple\"")
      (mkOnce "${flameshot.out}/bin/flameshot")
      (mkOnce "${networkmanagerapplet.out}/bin/nm-applet")
      (mkOnce "${sirikali.out}/bin/sirikali")
      (mkOnce "${signal-desktop.out}/bin/signal-desktop")
      (mkOnce "${heroic.out}/bin/heroic")
      (mkOnce "${steam.out}/bin/steam")
      (mkOnce "${birdtray.out}/bin/birdtray")
      (mkOnce "${keepassxc.out}/bin/keepassxc")
      (mkOnce "${qbittorrent.out}/bin/qbittorrent")
      (mkOnce "${blueman.out}/bin/blueman-applet")
      (mkOnce "${warpd.out}/bin/warpd --config ${./warpd.conf}")
      (mkOnce "${rclone.out}/bin/rclone mount AuraGDrive: ${dir}/CloudData/AuraGDrive")
    ]);

    keybindings = let
      mod = modifier;
      mkWorkspaceFocus = last: if last == 0 then { } else {
        "${mod}+Mod2+KP_${builtins.toString last}" = "workspace number ${builtins.toString last}";
      } // mkWorkspaceFocus (last - 1);
      mkWorkspaceMove = last: if last == 0 then { } else {
        "${mod}+Mod1+Mod2+KP_${builtins.toString last}" = "move container to workspace number ${builtins.toString last}";
      } // mkWorkspaceMove (last - 1);
      mkAudioCtrl = args: "exec --no-startup-id ${pkgs.pulseaudio.out}/bin/pactl ${args}";
    in {
      # kill windows
      "${mod}+Delete" = "kill";

      # launch programs
      "${mod}+Return" = "exec ${terminal}";
      "${mod}+space" = "exec ${menu}";
      "${mod}+0" = "exec ${browser}";

      # screenshot
      "Print" = "exec --no-startup-id ${screenshot-full}";
      "${mod}+Print" = "exec --no-startup-id ${screenshot-gui}";

      # lock screen
      "${mod}+l" = "exec --no-startup-id ${lock}";

      # reload monitor config with autorandr
      "${mod}+z" = "exec --no-startup-id ${pkgs.autorandr.out}/bin/autorandr -c";

      # modify audio settings
      "${mod}+k" = mkAudioCtrl "set-sink-volume @DEFAULT_SINK@ +10%";
      "${mod}+j" = mkAudioCtrl "set-sink-volume @DEFAULT_SINK@ -10%";
      "${mod}+n" = mkAudioCtrl "set-sink-mute @DEFAULT_SINK@ toggle";
      "${mod}+m" = mkAudioCtrl "set-source-mute @DEFAULT_SOURCE@ toggle";

      # clipboard management
      "${mod}+p" = "exec --no-startup-id ${pkgs.aurakle.dont-repeat-yourself.out}/bin/dont-repeat-yourself load";
      "${mod}+Shift+p" = "exec --no-startup-id ${pkgs.aurakle.dont-repeat-yourself.out}/bin/dont-repeat-yourself save";

      # calculator
      "${mod}+o" = "exec --no-startup-id ${calc}";

      # file browser
      "${mod}+i" = "exec --no-startup-id ${file-browser}";

      # password manager
      "${mod}+u" = "exec --no-startup-id ${keepmenu}";

      # bluetooth
      "${mod}+b" = "exec --no-startup-id ${bluetooth}";

      # Evelyn's clicker <3
      "${mod}+c" = "exec --no-startup-id ${clickr-click.out}/bin/clickr-click evy.clickr";

      # keyboard layout
      "${mod}+g" = "exec --no-startup-id ${pkgs.xorg.setxkbmap.out}/bin/setxkbmap us";
      "${mod}+t" = "exec --no-startup-id ${pkgs.xorg.setxkbmap.out}/bin/setxkbmap ca";

      # change focus
      "${mod}+Left" = "focus left";
      "${mod}+Down" = "focus down";
      "${mod}+Right" = "focus right";
      "${mod}+Up" = "focus up";

      # move window
      "${mod}+Mod1+Left" = "move left";
      "${mod}+Mod1+Down" = "move down";
      "${mod}+Mod1+Right" = "move right";
      "${mod}+Mod1+Up" = "move up";

      # split horizontal
      "${mod}+h" = "split h";

      # split vertical
      "${mod}+v" = "split v";

      # fullscreen
      "${mod}+f" = "fullscreen toggle";

      # change layout
      "${mod}+a" = "layout stacking";
      "${mod}+s" = "layout tabbed";
      "${mod}+d" = "layout toggle split";

      # reload config
      "${mod}+Shift+c" = "reload";

      # restart i3 inplace
      "${mod}+Shift+r" = "restart";

      # scratchpad
      "${mod}+Mod2+KP_0" = "scratchpad show; floating disable";
      "${mod}+Mod1+Mod2+KP_0" = "move scratchpad";

      # floating windows are the worst
      "${mod}+End" = "floating toggle";

      # powermenu
      "${mod}+BackSpace" = "exec ${powermenu}";
    } // mkWorkspaceFocus 9 // mkWorkspaceMove 9;

    modes = {
      #TODO: add resizing mode
    };

    floating = {
      titlebar = true;
      border = 2;
      inherit modifier;

      criteria = [
        {
          class = "dont-repeat-yourself";
        }
      ];
    };

    focus = {
      followMouse = true;
      mouseWarping = true;
    };

    window = {
      titlebar = false;
      border = 2;

      commands = [
        {
          command = "kill";

          criteria = {
            class = ".blueman-applet-wrapped";
          };
        }
        {
          command = "focus";

          criteria = {
            class = "vesktop";
          };
        }
        {
          command = "focus";

          criteria = {
            class = "firefox";
          };
        }
        {
          command = "focus";

          criteria = {
            class = "FreeTube";
          };
        }
        {
          command = "focus";

          criteria = {
            class = "dont-repeat-yourself";
          };
        }
      ];
    };

    assigns = {
      "1" = [
        {
          class = "vesktop";
        }
      ];
      "2" = [
        {
          class = "firefox";
        }
      ];
      "3" = [
        {
          class = "steam";
        }
        {
          class = "heroic";
        }
      ];
      "9" = [
        {
          class = "Spotify";
        }
        {
          class = "FreeTube";
        }
      ];
    };

    gaps = {
      smartBorders = "on";
      inner = 6;
      outer = 2;
    };

    fonts = {
      names = [ "pango" ];
      style = "monospace";
      size = 8.0;
    };

    bars = lib.mkForce [ ];
  };
}
