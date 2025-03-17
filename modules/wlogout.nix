{
  config,
  lib,
  ...
}:
let
  cfg = config.home.wlogout;
  wayland = config.home.wayland.enable;
  hyprland = config.home.hyprland.enable;
  shouldConfigure = wayland && hyprland;
  uwsmPrefix = config.home.wayland.uwsm.prefix;
in
with lib;
{
  options = {
    home.wlogout.enable = mkEnableOption "wlogout wayland logout menu";
  };

  config = mkIf cfg.enable {
    programs = {
      wlogout = {
        enable = true;
        layout = [
          {
            "label" = "lock";
            "action" = "which hyprlock &>/dev/null && ${uwsmPrefix}hyprlock || loginctl lock-session";
            "text" = "[L] ock";
            "keybind" = "l";
          }
          {
            "label" = "hibernate";
            "action" = "systemctl hibernate";
            "text" = "[H] ibernate";
            "keybind" = "h";
          }
          {
            "label" = "logout";
            "action" = "loginctl terminate-user $USER";
            "text" = "[T] erminate";
            "keybind" = "t";
          }
          {
            "label" = "shutdown";
            "action" = "systemctl poweroff";
            "text" = "[P] ower off";
            "keybind" = "p";
          }
          {
            "label" = "suspend";
            "action" = "systemctl suspend";
            "text" = "[S] uspend";
            "keybind" = "s";
          }
          {
            "label" = "reboot";
            "action" = "systemctl reboot";
            "text" = "[R] eboot";
            "keybind" = "r";
          }
        ];
      };
    };

    wayland.windowManager.hyprland.settings = mkIf shouldConfigure {
      bind = [
        "SUPER, Q, exec, wlogout"
      ];
    };
  };
}
