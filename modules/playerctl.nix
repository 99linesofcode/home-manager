{
  config,
  lib,
  pkgs,
  ...
}:
let
  wayland = config.home.wayland.enable;
  hyprland = config.home.hyprland.enable;
  shouldConfigure = wayland && hyprland;
  cfg = config.home.playerctl;
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
        ", XF86AudioMute, exec, ${config.home.wayland.uwsm.prefix}wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioPrev, exec, ${config.home.wayland.uwsm.prefix}playerctl previous"
        ", XF86AudioPlay, exec, ${config.home.wayland.uwsm.prefix}playerctl play-pause"
        ", XF86AudioNext, exec, ${config.home.wayland.uwsm.prefix}playerctl next"
        ", XF86AudioMedia, exec, ${config.home.wayland.uwsm.prefix}playerctl play-pause"
        ", XF86AudioStop, exec, ${config.home.wayland.uwsm.prefix}playerctl stop"
      ];
    };
  };
}
