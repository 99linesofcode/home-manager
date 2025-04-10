{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.looking-glass;
in
with lib;
{
  options = {
    home.looking-glass.enable = mkEnableOption "looking-glass";
  };

  config = mkIf cfg.enable {
    programs.looking-glass-client.enable = true;
  };
}
