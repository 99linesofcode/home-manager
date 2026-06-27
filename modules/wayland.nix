{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.wayland;
  uwsmPrefix = "uwsm app --";
in
with lib;
{
  options = {
    home.wayland = {
      enable = mkEnableOption "wayland";
      uwsm.prefix = mkOption {
        default = "${uwsmPrefix} ";
        type = with types; str;
        description = "UWSM prefix";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        polkit
        wl-clipboard
        xdg-utils # command line tools that assist applications with a variety of desktop integration tasks
      ];

      sessionVariables = {
        AQ_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
        CLUTTER_BACKEND = "wayland";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        GDK_SCALE = 2;
        GDK_BACKEND = "wayland,x11,*";
        GTK_USE_PORTAL = 1;
        QT_AUTO_SCREEN_SCALE_FACTOR = 1;
        QT_QPA_PLATFORM = "wayland;xcb";
        QT_QPA_PLATFORMTHEME = "qt6ct";
        QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
        SDL_VIDEODRIVER = "wayland";
        NIXOS_OZONE_WL = 1;
      };
    };

    services = {
      cliphist.enable = true;
      mpris-proxy.enable = true; # see: https://wiki.nixos.org/wiki/Bluetooth#Using_Bluetooth_headset_buttons_to_control_media_player
      udiskie.enable = true; # automount removable media
    };
  };
}
