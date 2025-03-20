{
  config,
  lib,
  ...
}:
let
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
    home.hyprland.enable = mkEnableOption "hyprland";
  };

  config = mkIf shouldConfigure {
    wayland.windowManager.hyprland = {
      enable = true;
      # see: https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#using-the-home-manager-module-with-nixos
      package = null;
      portalPackage = null;
      systemd.enable = false; # uwsm
    };

    xdg.configFile = {
      "hypr/state.conf" = {
        source = ../dotfiles/hypr/state.conf;
        force = true;
      };
      "hypr/scripts/bluetooth-toggle.sh".source = ../dotfiles/hypr/scripts/bluetooth-toggle.sh;
      "hypr/scripts/display-toggle.sh".source = ../dotfiles/hypr/scripts/display-toggle.sh;
      # TODO: figure out how to extract to modules and append to file instead
      "uwsm/env".text = ''
        export AQ_DRM_DEVICES="/dev/dri/card1:/dev/dri/card0"
        export CLUTTER_BACKEND="wayland"
        export ELECTRON_OZONE_PLATFORM_HINT="auto"
        export GDK_BACKEND="wayland,x11,*"
        export MOZ_ENABLE_WAYLAND=1
        export MOZ_DISABLE_RDD_SANDBOX=1
        export MOZ_DRM_DEVICE=/dev/dri/card0
        export NIXOS_OZONE_WL=1
        export QT_AUTO_SCREEN_SCALE_FACTOR=1
        export QT_QPA_PLATFORM="wayland;xcb"
        export QT_QPA_PLATFORMTHEME=qt6ct
        export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
        export SDL_VIDEODRIVER="wayland"
      '';
    };

    home.hypridle.enable = true;
    home.hyprlock.enable = true;
    home.hyprpaper.enable = true;
    home.hyprpolkitagent.enable = true;
    # home.hyprshade.enable = true;
    # home.nwg-docker-hyprland.enable = true;
  };
}
