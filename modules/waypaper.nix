{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.waypaper;
in
with lib;
{
  options = {
    home.waypaper.enable = mkEnableOption "waypaper GUI wallpaper manager";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      waypaper
    ];
  };
}
