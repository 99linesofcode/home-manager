{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.hyprpicker;
  uwsmPrefix = config.home.wayland.uwsm.prefix;
in
with lib;
{
  options = {
    home.hyprpicker.enable = mkEnableOption "hyprpicker - wlroots wayland compatible color picker";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprpicker
    ];

    wayland.windowManager.hyprland.settings = {
      bind = [
        "SUPER, D, exec, ${uwsmPrefix} hyprpicker -na"
      ];
    };
  };
}
