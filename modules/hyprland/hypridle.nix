{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.hypridle;
in
with lib;
{
  options = {
    home.hypridle.enable = mkEnableOption "hypridle daemon";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hypridle
    ];
  };
}
