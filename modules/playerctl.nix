{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.playerctl;
  wayland = config.home.wayland.enable;
  hyprland = config.home.hyprland.enable;
  shouldConfigure = wayland && hyprland;
  uwsmPrefix = config.home.wayland.uwsm.prefix;
in
with lib;
{
  options = {
    home.playerctl.enable = mkEnableOption "playerctl control media keys";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      playerctl
    ];

    wayland.windowManager.hyprland.settings = mkIf shouldConfigure {
      bindl = [
        ", XF86AudioPrev, exec, ${uwsmPrefix}playerctl previous"
        ", XF86AudioPlay, exec, ${uwsmPrefix}playerctl play-pause"
        ", XF86AudioNext, exec, ${uwsmPrefix}playerctl next"
        ", XF86AudioMedia, exec, ${uwsmPrefix}playerctl play-pause"
        ", XF86AudioStop, exec, ${uwsmPrefix}playerctl stop"
      ];
    };
  };
}
