{
  config,
  lib,
  ...
}:
let
  wayland = config.home.wayland.enable;
  hyprland = config.home.hyprland.enable;
  shouldConfigure = wayland && hyprland;
  cfg = config.home.wlogout;
in
with lib;
{
  options = {
    home.wlogout.enable = mkEnableOption "wlogout wayland logout menu";
  };

  config = mkIf cfg.enable {
    programs = {
      wlogout.enable = true;
    };

    wayland.windowManager.hyprland.settings = mkIf shouldConfigure {
      bind = [
        "SUPER, Q, exec, wlogout"
      ];
    };
  };
}
