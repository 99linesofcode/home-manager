{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.obs;
in
with lib;
{
  options = {
    home.obs.enable = mkEnableOption "OBS studio";
  };

  config = mkIf cfg.enable {
    programs = {
      obs-studio = {
        enable = true;
        plugins = with pkgs.obs-studio-plugins; [
          droidcam-obs
          input-overlay
          obs-pipewire-audio-capture
        ];
      };
    };

    wayland.windowManager.hyprland.settings = mkIf config.home.hyprland.enable {
      bind = [
        "SUPER_ALT, P, pass, ^(com\.obsproject\.Studio)$" # pause
        "SUPER_ALT, S, pass, ^(com\.obsproject\.Studio)$" # stop
        "SUPER_ALT, R, pass, ^(com\.obsproject\.Studio)$" # record
        "SUPER_ALT, U, pass, ^(com\.obsproject\.Studio)$" # unpause
      ];
    };
  };
}
