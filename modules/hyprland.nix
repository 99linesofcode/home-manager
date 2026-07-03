{
  config,
  lib,
  ...
}:
let
  cfg = config.home.hyprland;
  wayland = config.home.wayland.enable;
  hyprland = config.home.hyprland.enable;
  shouldConfigure = wayland && hyprland;
in
with lib;
{
  imports = [
    ./hyprland
  ];

  options = {
    home.hyprland = with types; {
      uwsm.extraLines = mkOption {
        type = lines;
        default = "";
        description = "Additional UWSM configuration options to append to the env file.";
      };
      enable = mkEnableOption "hyprland";
    };
  };

  config = mkIf shouldConfigure {
    wayland.windowManager.hyprland = {
      enable = true;
      configType = "hyprlang"; # TODO: figure out whether lua requires changes to the hyprland module configuration
      # see: https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#using-the-home-manager-module-with-nixos
      package = null;
      portalPackage = null;
      systemd.enable = false; # disabled as it conflicts with uwsm
    };

    xdg.configFile."uwsm/env".text = # sh
      ''
        export AQ_DRM_DEVICES="/dev/dri/card1:/dev/dri/card0"
        export CLUTTER_BACKEND="wayland"
        export ELECTRON_OZONE_PLATFORM_HINT="auto"
        export GDK_SCALE=2
        export GDK_BACKEND="wayland,x11,*"
        export GTK_USE_PORTAL=1
        export QT_AUTO_SCREEN_SCALE_FACTOR=1
        export QT_QPA_PLATFORM="waylandxcb"
        export QT_QPA_PLATFORMTHEME="qt6ct"
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export SDL_VIDEODRIVER="wayland"
        export NIXOS_OZONE_WL=1

        ${cfg.uwsm.extraLines}
      '';

    home = {
      pointerCursor = {
        enable = true;
        hyprcursor = {
          enable = true;
          size = 24;
        };
      };

      hypridle.enable = true;
      hyprlock.enable = true;
      hyprmon.enable = true;
      hyprpaper.enable = true;
      hyprpicker.enable = true;
      hyprpolkitagent.enable = true;
    };
  };
}
