{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.steam;
in
with lib;
{
  options = {
    home.steam.enable = mkEnableOption "steam";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      protonup
    ];
  };
}
