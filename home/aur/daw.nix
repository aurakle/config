{ config, lib, pkgs, ... }:

let
  makeAudioPluginPath = format:
    (lib.makeSearchPath format [
      "$HOME/.nix-profile/lib"
      "/run/current-system/sw/lib"
      "/etc/profiles/per-user/$USER/lib"
    ]) + ":$HOME/.${format}";
  vst = with pkgs; [
    carla
    bristol
    x42-avldrums
    lsp-plugins
    surge-XT
    vital
  ];
in {
  home.packages = with pkgs; [
    ardour
    musescore
    openutau
    yabridge
    yabridgectl
  ] ++ vst;

  home.sessionVariables = {
    DSSI_PATH = makeAudioPluginPath "dssi";
    LADSPA_PATH = makeAudioPluginPath "ladspa";
    LV2_PATH = makeAudioPluginPath "lv2";
    LXVST_PATH = makeAudioPluginPath "lxvst";
    VST_PATH = makeAudioPluginPath "vst";
    VST3_PATH = makeAudioPluginPath "vst3";
  };
}
