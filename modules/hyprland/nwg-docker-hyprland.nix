{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.nwg-dock-hyprland;
in
with lib;
{
  options = {
    home.nwg-dock-hyprland.enable = mkEnableOption "nwg-dock-hyprland";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      nwg-dock-hyprland
    ];
  };
}
