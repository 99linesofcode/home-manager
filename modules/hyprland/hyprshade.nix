{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.hyprshade;
in
with lib;
{
  options = {
    home.hyprshade.enable = mkEnableOption "hyprland shader configuration tool";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hyprshade
    ];
  };
}
