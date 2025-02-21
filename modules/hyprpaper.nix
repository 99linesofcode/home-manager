{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.hyprpaper;
in
with lib;
{
  options = {
    home.hyprpaper.enable = mkEnableOption "hyprpaper wayland wallpaper utility";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpaper
    ];

    services = {
      hyprpaper.enable = true;
    };
  };
}
