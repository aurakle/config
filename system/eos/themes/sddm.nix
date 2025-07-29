# https://discourse.nixos.org/t/sddm-background-image/5495/2
{ config, lib, pkgs, ... }:

let
  buildTheme = { name, version, src, themeIni ? [] }:
    pkgs.stdenv.mkDerivation rec {
      pname = "sddm-theme-${name}";
      inherit version src;

      buildCommand = ''
        dir=$out/share/sddm/themes/${name}
        doc=$out/share/doc/${pname}

        mkdir -p $dir $doc
        if [ -d $src/${name} ]; then
          srcDir=$src/${name}
        else
          srcDir=$src
        fi
        cp -r $srcDir/* $dir/ #*/
        for f in $dir/{AUTHORS,COPYING,LICENSE,README,*.md,*.txt}; do
          test -f $f && mv $f $doc/
        done
        chmod 444 $dir/theme.conf

        ${lib.concatMapStringsSep "\n" (e: ''
          ${pkgs.crudini}/bin/crudini --set --inplace $dir/theme.conf \
            "${e.section}" "${e.key}" "${e.value}"
        '') themeIni}
      '';
    };

  theme = themes.catppuccin-corners;

  customTheme = builtins.isAttrs theme;

  themeName = if customTheme then theme.pkg.name else theme;

  packages = if customTheme then [ (buildTheme theme.pkg) ] ++ theme.deps else [];

  themes = {
    catppuccin-corners = {
      pkg = rec {
        name = "catppuccin";
        version = "aca5af5ce0c9dff56e947938697dec40ea101e3e";
        src = pkgs.fetchFromGitHub {
          owner = "khaneliman";
          repo = "catppuccin-sddm-corners";
          rev = version;
          sha256 = "sha256-xtcNcjNQSG7SwlNw/EkAU93wFaku+cE1/r6c8c4FrBg=";
        };
      };
      deps = with pkgs.libsForQt5.qt5; [
        qtgraphicaleffects
        qtsvg
        qtquickcontrols2
      ];
    };
  };
in {
  environment.systemPackages = packages;
  services.displayManager.sddm.theme = themeName;
}
