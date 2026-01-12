{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.hyprmon;
  uwsmPrefix = config.home.wayland.uwsm.prefix;
in
with lib;
{
  options = {
    home.hyprmon.enable = mkEnableOption "hyprmon - wlroots wayland compatible color picker";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprmon
    ];

    wayland.windowManager.hyprland.settings = {
      bind = [
        "SUPER, P, exec, ${uwsmPrefix}alacritty -e hyprmon" # F4
      ];
    };
  };
}
