{
  config,
  lib,
  ...
}:
let
  cfg = config.home.hyprlock;
in
with lib;
{
  options = {
    home.hyprlock.enable = mkEnableOption "hyprlock hyprland screen lock utility";
  };

  config = mkIf cfg.enable {
    programs = {
      hyprlock.enable = true;
    };
  };
}
