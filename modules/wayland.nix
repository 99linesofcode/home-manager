{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.wayland;
in
with lib;
{
  options = {
    home.wayland.enable = mkEnableOption "wayland";
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
