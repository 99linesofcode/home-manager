{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.home.slurp;
in
with lib;
{
  options = {
    home.slurp.enable = mkEnableOption "slurp wayland region selector";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      slurp
    ];
  };
}
