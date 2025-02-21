{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.qalculate-gtk;
in
with lib;
{
  options = {
    home.qalculate-gtk.enable = mkEnableOption "qalculate-gtk";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      qalculate-gtk
    ];

    wayland.windowManager.hyprland.settings = mkIf config.home.hyprland.enable {
      bind = [
        "SUPER, C, exec, qalculate-gtk"
      ];
    };
  };
}
