{
  config,
  lib,
  ...
}:
let
  cfg = config.home.alacritty;
  uwsmPrefix = config.home.wayland.uwsm.prefix;
in
with lib;
{
  options = {
    home.alacritty.enable = mkEnableOption "alacritty";
  };

  config = mkIf cfg.enable {
    programs = {
      alacritty = {
        enable = true;
        settings = {
          font.offset.y = 8;
        };
      };
    };

    wayland.windowManager.hyprland.settings = mkIf config.home.hyprland.enable {
      bind = [
        "SUPER, Return, exec, ${uwsmPrefix} alacritty"
      ];
    };
  };
}
