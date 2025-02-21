{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.brightnessctl;
in
with lib;
{
  options = {
    home.brightnessctl.enable = mkEnableOption "brightnessctl";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      brightnessctl
    ];
  };
}
