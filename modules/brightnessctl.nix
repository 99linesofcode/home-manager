{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.brightnessctl;
  uwsmPrefix = config.home.wayland.uwsm.prefix;
in
with lib;
{
  options = {
    home.brightnessctl.enable = mkEnableOption "brightnessctl";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      brightnessctl
    ];

    wayland.windowManager.hyprland.settings = mkIf config.home.hyprland.enable {
      bindel = [
        ", XF86MonBrightnessDown, exec, ${uwsmPrefix}brightnessctl s 10%-"
        ", XF86MonBrightnessUp, exec, ${uwsmPrefix}brightnessctl s 10%+"
      ];
    };
  };
}
