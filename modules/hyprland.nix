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
      configType = "hyprlang"; # TODO: figure out whether lua requires changes to the hyprland module configuration
      # see: https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/#using-the-home-manager-module-with-nixos
      package = null;
      portalPackage = null;
      systemd.enable = false; # disabled as it conflicts with uwsm
    };

    xdg.configFile."uwsm/env" = {
      source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";
    };

    home = {
      sessionVariables = {
        AQ_DRM_DEVICES = "/dev/dri/card1:/dev/dri/card0";
      };

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
