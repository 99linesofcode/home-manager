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
    home.packages = with pkgs; [
      polkit
      wl-clipboard
      xdg-utils # command line tools that assist applications with a variety of desktop integration tasks
    ];

    services = {
      cliphist.enable = true;
      mpris-proxy.enable = true; # see: https://wiki.nixos.org/wiki/Bluetooth#Using_Bluetooth_headset_buttons_to_control_media_player
      udiskie.enable = true; # automount removable media
    };
  };
}
